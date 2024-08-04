#!/bin/bash
cd "$(dirname "$0")"
set -ueo pipefail

platform=$1
target=$2
profile=$3

openwrt_version="23.05.4"

build_dir="_build/${platform}-${target}-${openwrt_version}"
tarball=openwrt-imagebuilder-${openwrt_version}-${platform}-${target}.Linux-x86_64.tar.xz

if [[ ! -f "_build/${tarball}" ]]; then
  mkdir -p "_build"
  curl --retry 2 --fail -o "_build/$tarball" -L "https://downloads.openwrt.org/releases/${openwrt_version}/targets/${platform}/${target}/${tarball}"
fi

rm -rf "$build_dir"
mkdir -p "$build_dir"
tar --strip-components=1 -C "${build_dir}" -Jxvf "_build/$tarball"

for f in $(find files/ -type f); do
  mkdir -p "$(dirname "$build_dir/$f")"
  cp "$f" "$build_dir/$f"
done

for src in $(find files.enc/ -type f); do
  dst=${src/files.enc/files}
  mkdir -p "$(dirname "$build_dir/$dst")"
  sops -d "$src" > "$build_dir/$dst"
done

packages=$(xargs < packages)

# imagebuilder settings
export BIN_DIR="."
export FILES="files"
export DISABLED_SERVICES="dropbear" # using openssh-server instead
export PACKAGES=$packages
export PROFILE=$profile

make -C "$build_dir" image PACKAGES="$PACKAGES"
