set shell := ["bash", "-euo", "pipefail", "-c"]

project_root := justfile_directory()
build_dir := project_root / "build"
arch_dir := build_dir / "arch-package"
native_dir := build_dir / "native-package"
package_dir := build_dir / "packages"
family_script := project_root / "packaging" / "distro-family.sh"

# Show the available developer commands.
default:
    @just --list

# Compile Projecteur.
build: deps
    cmake -S "{{ project_root }}" -B "{{ build_dir }}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DPACKAGE_TARGETS=OFF
    cmake --build "{{ build_dir }}" --parallel

# Build a native package (Arch, Fedora, Debian/Ubuntu) from the current working tree.
package: deps
    #!/usr/bin/env bash
    set -euo pipefail

    case "$(bash "{{ family_script }}")" in
        arch)
            just --justfile "{{ justfile() }}" \
                arch_dir="{{ arch_dir }}" package_dir="{{ package_dir }}" _package-arch
            ;;
        fedora|debian)
            just --justfile "{{ justfile() }}" \
                native_dir="{{ native_dir }}" package_dir="{{ package_dir }}" _package-native
            ;;
    esac

# Build an Arch Linux package with makepkg.
_package-arch: _require-arch
    #!/usr/bin/env bash
    set -euo pipefail

    if (( EUID == 0 )); then
        echo "error: makepkg must be run as a regular user, not root." >&2
        exit 1
    fi

    root="{{ project_root }}"
    stage="{{ arch_dir }}"
    packages="{{ package_dir }}"

    mkdir -p "$stage" "$packages"
    install -m 0644 "$root/packaging/arch/PKGBUILD" "$stage/PKGBUILD"

    cmake -S "$root" -B "$stage/version-build" -DPACKAGE_TARGETS=OFF
    cp "$stage/version-build/version-string.archlinux" "$stage/projecteur-pkgver"

    git -C "$root" ls-files --cached --others --exclude-standard -z \
        | while IFS= read -r -d '' path; do
            if [[ -e "$root/$path" || -L "$root/$path" ]]; then
                printf '%s\0' "$path"
            fi
        done \
        | tar -C "$root" --null --no-recursion --files-from=- \
            --transform='s,^,projecteur-local/,' \
            -czf "$stage/projecteur-local.tar.gz"

    (
        cd "$stage"
        updpkgsums
        BUILDDIR="$stage/work" \
        PKGDEST="$packages" \
        SRCDEST="$stage/sources" \
            makepkg --cleanbuild --clean --force --noconfirm --syncdeps
    )

    echo
    echo "Package created:"
    (
        cd "$stage"
        PKGDEST="$packages" makepkg --packagelist
    )

# Build a .rpm (Fedora) or .deb (Debian/Ubuntu) with the CMake dist-package target.
_package-native:
    #!/usr/bin/env bash
    set -euo pipefail

    stage="{{ native_dir }}"
    packages="{{ package_dir }}"

    rm -rf "$stage/dist-pkg"
    cmake -S "{{ project_root }}" -B "$stage" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_UDEVRULESDIR=/usr/lib/udev/rules.d \
        -DPACKAGE_TARGETS=ON
    cmake --build "$stage" --target dist-package --parallel

    shopt -s nullglob
    created=("$stage"/dist-pkg/*.rpm "$stage"/dist-pkg/*.deb)
    if (( ${#created[@]} == 0 )); then
        echo "error: no .rpm or .deb package was created in $stage/dist-pkg." >&2
        exit 1
    fi
    mkdir -p "$packages"
    cp "${created[@]}" "$packages/"

    echo
    echo "Package created:"
    for file in "${created[@]}"; do echo "$packages/$(basename "$file")"; done

# Build, package, and install Projecteur with the native package manager.
install: _stop-projecteur package
    #!/usr/bin/env bash
    set -euo pipefail

    as_root() {
        if (( EUID == 0 )); then
            "$@"
        elif command -v sudo >/dev/null 2>&1; then
            sudo "$@"
        else
            echo "error: installing the package requires root or sudo." >&2
            exit 1
        fi
    }

    # Authenticate before installing the package.
    if (( EUID != 0 )) && command -v sudo >/dev/null 2>&1; then sudo -v; fi

    family="$(bash "{{ family_script }}")"
    shopt -s nullglob
    case "$family" in
        arch)
            stage="{{ arch_dir }}"
            packages="{{ package_dir }}"
            package_file="$(
                cd "$stage"
                PKGDEST="$packages" makepkg --packagelist | head -n 1
            )"
            if [[ ! -f "$package_file" ]]; then
                echo "error: expected package was not created: $package_file" >&2
                exit 1
            fi
            as_root pacman -U --noconfirm "$package_file"
            ;;
        fedora)
            created=("{{ native_dir }}"/dist-pkg/*.rpm)
            if (( ${#created[@]} != 1 )); then
                echo "error: expected exactly one .rpm in {{ native_dir }}/dist-pkg." >&2
                exit 1
            fi
            package_file="${created[0]}"
            new="$(rpm -qp --qf '%{NEVRA}' "$package_file")"
            old="$(rpm -q --qf '%{NEVRA}' projecteur 2>/dev/null || true)"
            if [[ "$new" == "$old" ]]; then
                # Same version rebuilt from local changes: dnf install would skip it.
                as_root dnf reinstall -y "$package_file"
            else
                as_root dnf install -y "$package_file"
            fi
            ;;
        debian)
            created=("{{ native_dir }}"/dist-pkg/*.deb)
            if (( ${#created[@]} != 1 )); then
                echo "error: expected exactly one .deb in {{ native_dir }}/dist-pkg." >&2
                exit 1
            fi
            # --reinstall also covers a rebuild of the same version.
            as_root env DEBIAN_FRONTEND=noninteractive \
                apt-get install -y --reinstall "${created[0]}"
            ;;
    esac

    if ! systemctl --user restart plasma-plasmashell.service; then
        echo "warning: could not restart plasmashell; log out and in to load the applet." >&2
    fi
    if ! dbus-send --session --print-reply=literal \
        --dest=org.freedesktop.DBus \
        /org/freedesktop/DBus \
        org.freedesktop.DBus.StartServiceByName \
        string:org.projecteur.Projecteur \
        uint32:0 >/dev/null; then
        echo "warning: Projecteur is installed but could not be started; start it from the application menu." >&2
    fi

# Build a .deb into build/packages (in a podman/docker container when not on Debian/Ubuntu).
deb image="ubuntu:devel":
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ "$(bash "{{ family_script }}")" == "debian" ]]; then
        just --justfile "{{ justfile() }}" package_dir="{{ package_dir }}" package
        exit 0
    fi

    if command -v podman >/dev/null 2>&1; then
        engine=podman
    elif command -v docker >/dev/null 2>&1; then
        engine=docker
    else
        echo "error: building a .deb here needs podman or docker." >&2
        exit 1
    fi

    mkdir -p "{{ package_dir }}"
    echo "Building a .deb in a {{ image }} container with $engine ..."
    "$engine" run --rm \
        -v "{{ project_root }}:/src:ro,Z" \
        -v "{{ package_dir }}:/out:Z" \
        -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
        "{{ image }}" bash -euo pipefail -c '
            export DEBIAN_FRONTEND=noninteractive
            apt-get update -qq
            apt-get install -y -qq git just >/dev/null
            # Work on a copy: the build must not write into the read-only checkout.
            cp -a /src /tmp/src
            git config --global --add safe.directory /tmp/src
            cd /tmp/src
            rm -rf build
            just native_dir=/tmp/native package_dir=/out package
            chown "$HOST_UID:$HOST_GID" /out/*.deb
        '

# Install the current build into /usr with cmake, without a package (any distribution).
install-local: _stop-projecteur
    cmake -S "{{ project_root }}" -B "{{ build_dir }}" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DPACKAGE_TARGETS=OFF
    cmake --build "{{ build_dir }}" --parallel
    sudo cmake --install "{{ build_dir }}"

_stop-projecteur:
    #!/usr/bin/env bash
    set -euo pipefail

    service_name="org.projecteur.Projecteur"
    service_has_owner() {
        local reply
        reply="$({
            dbus-send --session --print-reply=literal \
                --dest=org.freedesktop.DBus \
                /org/freedesktop/DBus \
                org.freedesktop.DBus.NameHasOwner \
                string:"$service_name"
        } 2>/dev/null || true)"
        [[ "$reply" == *true* ]]
    }

    if ! service_has_owner; then
        exit 0
    fi

    dbus-send --session --print-reply=literal \
        --dest="$service_name" \
        /org/projecteur/Projecteur/Control \
        org.projecteur.Projecteur.Quit >/dev/null 2>&1 || true

    for (( attempt = 0; attempt < 10; ++attempt )); do
        if ! service_has_owner; then
            exit 0
        fi
        sleep 0.1
    done

    # Older or unhealthy instances may own the well-known name without exporting
    # the control object. Resolve the exact owner and terminate only a Projecteur
    # process, rather than allowing a stale binary to survive the package upgrade.
    owner_pid_reply="$({
        dbus-send --session --print-reply=literal \
            --dest=org.freedesktop.DBus \
            /org/freedesktop/DBus \
            org.freedesktop.DBus.GetConnectionUnixProcessID \
            string:"$service_name"
    } 2>/dev/null || true)"
    if [[ "$owner_pid_reply" =~ uint32[[:space:]]+([0-9]+) ]]; then
        owner_pid="${BASH_REMATCH[1]}"
        if [[ -r "/proc/$owner_pid/comm" ]] \
            && [[ "$(<"/proc/$owner_pid/comm")" == "projecteur" ]]; then
            kill -TERM "$owner_pid"
        fi
    fi

    for (( attempt = 0; attempt < 50; ++attempt )); do
        if ! service_has_owner; then
            exit 0
        fi
        sleep 0.1
    done

    if service_has_owner; then
        owner_pid_reply="$({
            dbus-send --session --print-reply=literal \
                --dest=org.freedesktop.DBus \
                /org/freedesktop/DBus \
                org.freedesktop.DBus.GetConnectionUnixProcessID \
                string:"$service_name"
        } 2>/dev/null || true)"
    fi
    echo "error: Projecteur did not release $service_name (owner: ${owner_pid_reply:-unknown})." >&2
    exit 1

# Install the compiler and Projecteur build dependencies.
deps:
    #!/usr/bin/env bash
    set -euo pipefail

    case "$(bash "{{ family_script }}")" in
        arch) just --justfile "{{ justfile() }}" _deps-arch ;;
        fedora) just --justfile "{{ justfile() }}" _deps-fedora ;;
        debian) just --justfile "{{ justfile() }}" _deps-debian ;;
    esac

_deps-arch: _require-arch
    #!/usr/bin/env bash
    set -euo pipefail

    dependencies=(
        base-devel
        cmake
        extra-cmake-modules
        gettext
        git
        kconfig
        kconfigwidgets
        kcoreaddons
        kdbusaddons
        kglobalaccel
        ki18n
        kpipewire
        knotifications
        kwidgetsaddons
        kwindowsystem
        kxmlgui
        layer-shell-qt
        libplasma
        libglvnd
        pacman-contrib
        qt6-base
        qt6-declarative
        qt6-shadertools
        qt6-wayland
    )

    mapfile -t missing < <(pacman -T "${dependencies[@]}" || true)
    if (( ${#missing[@]} == 0 )); then
        echo "Arch build dependencies are already installed."
        exit 0
    fi

    echo "Installing missing Arch build dependencies: ${missing[*]}"
    if (( EUID == 0 )); then
        pacman -S --needed --noconfirm "${missing[@]}"
    elif command -v sudo >/dev/null 2>&1; then
        sudo pacman -S --needed --noconfirm "${missing[@]}"
    else
        echo "error: installing build dependencies requires root or sudo." >&2
        exit 1
    fi

_require-arch:
    #!/usr/bin/env bash
    set -euo pipefail

    if [[ ! -r /etc/os-release ]]; then
        echo "error: /etc/os-release is unavailable; this workflow requires Arch Linux." >&2
        exit 1
    fi

    # shellcheck disable=SC1091
    source /etc/os-release
    distro_ids=" ${ID:-} ${ID_LIKE:-} "
    if [[ "$distro_ids" != *" arch "* ]]; then
        echo "error: this workflow requires Arch Linux or an Arch-based distribution." >&2
        echo "       detected: ${PRETTY_NAME:-unknown Linux distribution}" >&2
        exit 1
    fi

    if ! command -v pacman >/dev/null 2>&1; then
        echo "error: pacman was not found; this does not look like a usable Arch system." >&2
        exit 1
    fi

# Fedora build dependencies (same list as ci/install-dependencies.sh).
_deps-fedora:
    #!/usr/bin/env bash
    set -euo pipefail

    dependencies=(
        gcc-c++ cmake extra-cmake-modules gettext git pkgconf-pkg-config
        systemd-devel rpm-build qt6-qtbase-devel qt6-qtdeclarative-devel
        qt6-qtshadertools-devel qt6-qtwayland-devel kf6-kconfig-devel
        kf6-kconfigwidgets-devel kf6-kcoreaddons-devel kf6-kdbusaddons-devel
        kf6-kglobalaccel-devel kf6-ki18n-devel kf6-knotifications-devel
        kf6-kpackage-devel kf6-kirigami-devel kf6-kwidgetsaddons-devel
        kf6-kwindowsystem-devel kf6-kxmlgui-devel kpipewire-devel
        libplasma-devel layer-shell-qt-devel
    )

    missing=()
    for dep in "${dependencies[@]}"; do
        rpm -q --whatprovides "$dep" >/dev/null 2>&1 || missing+=("$dep")
    done
    if (( ${#missing[@]} > 0 )); then
        echo "Installing missing Fedora build dependencies: ${missing[*]}"
        if (( EUID == 0 )); then dnf install -y "${missing[@]}"
        else sudo dnf install -y "${missing[@]}"; fi
    else
        echo "Fedora build dependencies are already installed."
    fi

    bash "{{ project_root }}/packaging/check-versions.sh" \
        "$(rpm -q --qf '%{VERSION}' qt6-qtbase-devel)" \
        "$(rpm -q --qf '%{VERSION}' libplasma-devel)"

# Debian/Ubuntu build dependencies (same list as ci/install-dependencies.sh).
_deps-debian:
    #!/usr/bin/env bash
    set -euo pipefail

    dependencies=(
        build-essential cmake dpkg-dev extra-cmake-modules file gettext git
        pkg-config udev libudev-dev qt6-base-dev qt6-declarative-dev
        qt6-shadertools-dev qt6-wayland-dev libkf6config-dev
        libkf6configwidgets-dev libkf6coreaddons-dev libkf6dbusaddons-dev
        libkf6globalaccel-dev libkf6i18n-dev libkf6notifications-dev
        libkf6package-dev libkirigami-dev libkf6widgetsaddons-dev
        libkf6windowsystem-dev libkf6xmlgui-dev libkpipewire-dev
        libplasma-dev liblayershellqtinterface-dev
    )

    installed() {
        dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
    }
    missing=()
    for dep in "${dependencies[@]}"; do
        installed "$dep" || missing+=("$dep")
    done
    if (( ${#missing[@]} > 0 )); then
        echo "Installing missing Debian/Ubuntu build dependencies: ${missing[*]}"
        as_root() { if (( EUID == 0 )); then "$@"; else sudo "$@"; fi; }
        as_root apt-get update
        as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing[@]}"
    else
        echo "Debian/Ubuntu build dependencies are already installed."
    fi

    bash "{{ project_root }}/packaging/check-versions.sh" \
        "$(dpkg-query -W -f='${Version}' qt6-base-dev)" \
        "$(dpkg-query -W -f='${Version}' libplasma-dev)"
