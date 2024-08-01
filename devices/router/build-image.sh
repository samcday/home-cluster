#!/bin/bash
cd "$(dirname "$0")"
set -ueo pipefail

usage() {
  echo "$1" >&2
  echo "Usage: ./build-image.sh <name> <platform> <target> <profile>"
  exit 1
}

hostname=$1
platform=$2
target=$3
export PROFILE=$4

export PROFILE=${PROFILE:-avm_fritzbox-4040}

openwrt_version="23.05.4"

export HOSTNAME=$hostname
export INJECT_ENV='$HOSTNAME'

build_dir="_build/${platform}-${target}-${openwrt_version}"

if [[ ! -f "${build_dir}/.setup" ]]; then
  rm -rf "${build_dir}"
  mkdir -p "${build_dir}"
  curl -s --retry 2 --fail -L "https://downloads.openwrt.org/releases/${openwrt_version}/targets/${platform}/${target}/openwrt-imagebuilder-${openwrt_version}-${platform}-${target}.Linux-x86_64.tar.xz" | \
    tar --strip-components=1 -C "${build_dir}" -Jxvf -
  touch "${build_dir}/.setup"
fi

for f in $(find files/ -type f); do
  mkdir -p "$(dirname "$build_dir/$f")"
  envsubst "$INJECT_ENV" < "$f" > "$build_dir/$f"
done

for src in $(find files.enc/ -type f); do
  dst=${src/files.enc/files}
  mkdir -p "$(dirname "$build_dir/$dst")"
  sops -d "$src" > "$build_dir/$dst"
done

packages=$(xargs < packages)

if [[ "$target" == "mt7621" ]]; then
  packages="$packages -kmod-ath10k-ct -ath10k-firmware-qca4019-ct ath10k-firmware-qca4019 kmod-ath10k"
fi

# imagebuilder settings
export BIN_DIR="."
export FILES="files"
export DISABLED_SERVICES="dropbear" # using openssh-server instead
export PACKAGES=$packages

make -C $build_dir image PACKAGES="$PACKAGES"
