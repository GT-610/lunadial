#!/usr/bin/env bash

set -euo pipefail

: "${PUB_CACHE:?PUB_CACHE must point to the locked Flutter package cache}"

jni_version="$({
  awk '
    /^  jni:[[:space:]]*$/ { in_jni = 1; next }
    in_jni && /^    version:/ {
      gsub(/["\r]/, "", $2)
      print $2
      exit
    }
  ' pubspec.lock
})"

if [[ -z "$jni_version" ]]; then
  echo "Could not read the locked jni package version from pubspec.lock." >&2
  exit 1
fi

mapfile -d '' cmake_files < <(
  find "$PUB_CACHE/hosted" -type f \
    -path "*/jni-$jni_version/src/CMakeLists.txt" -print0
)

if (( ${#cmake_files[@]} == 0 )); then
  echo "Could not find jni $jni_version in PUB_CACHE=$PUB_CACHE." >&2
  exit 1
fi

for cmake_file in "${cmake_files[@]}"; do
  if ! grep -Fq -- 'max-page-size=16384' "$cmake_file"; then
    echo "The expected Android linker option was not found in $cmake_file." >&2
    exit 1
  fi

  if grep -Fq -- '-Wl,--build-id=none' "$cmake_file"; then
    continue
  fi

  sed -i \
    's/"-Wl,-z,max-page-size=16384"/"-Wl,--build-id=none,-z,max-page-size=16384"/' \
    "$cmake_file"

  grep -Fq -- '-Wl,--build-id=none' "$cmake_file"
done
