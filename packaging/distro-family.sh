#!/usr/bin/env bash
# Print the packaging family of the running distribution: arch, fedora or debian.
# Derivatives are recognized through ID_LIKE (e.g. KDE neon -> debian, Nobara -> fedora).
set -euo pipefail

os_release="${OS_RELEASE_FILE:-/etc/os-release}"
if [[ ! -r "$os_release" ]]; then
  echo "error: $os_release is unavailable, cannot detect the distribution." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$os_release"

for id in ${ID:-} ${ID_LIKE:-}; do
  case "$id" in
    arch|archlinux) echo arch; exit 0 ;;
    fedora) echo fedora; exit 0 ;;
    debian|ubuntu) echo debian; exit 0 ;;
  esac
done

echo "error: unsupported distribution: ${PRETTY_NAME:-unknown}." >&2
echo "       Supported: Arch, Fedora, Debian, Ubuntu and their derivatives." >&2
exit 1
