#!/usr/bin/env bash
# Usage: check-versions.sh QT_VERSION PLASMA_VERSION
# Fails with a clear message when the distribution's Qt or Plasma is older than
# what Projecteur needs (see find_package calls in CMakeLists.txt).
set -euo pipefail

min_qt=6.10
min_plasma=6.7

# "4:6.7.5-0ubuntu1" -> "6.7.5", "6.10.2+dfsg-7" -> "6.10.2"
normalize() {
  local v="${1#*:}"
  echo "${v%%[-+~]*}"
}

# True when version $1 >= version $2.
version_ge() {
  [[ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -n 1)" == "$2" ]]
}

qt="$(normalize "${1:-0}")"
plasma="$(normalize "${2:-0}")"
ok=1

if ! version_ge "$qt" "$min_qt"; then
  echo "error: Qt $qt found, Projecteur needs Qt $min_qt or newer." >&2
  ok=0
fi
if ! version_ge "$plasma" "$min_plasma"; then
  echo "error: Plasma $plasma found, Projecteur needs Plasma $min_plasma or newer." >&2
  ok=0
fi

if (( ! ok )); then
  echo "       This distribution release is too old. Use a release with Plasma $min_plasma," >&2
  echo "       for example Fedora 44, Debian testing or Ubuntu 26.10." >&2
  exit 1
fi

echo "Found Qt $qt and Plasma $plasma."
