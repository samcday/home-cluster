#!/bin/bash
cd "$(dirname "$0")"
set -uexo pipefail

openwrt_version="23.05.3"

export IPADDR="10.0.1.1"
export IPADDR_RESTRICTED="10.0.2.1"
export HOSTNAME="home-cluster-router"
export SSID="sam-home-cluster"
export INJECT_ENV='$HOSTNAME $SSID $IPADDR $IPADDR_RESTRICTED'

if [[ ! -f _build/.setup ]]; then
  mkdir -p _build/
  curl -s --retry 2 --fail -L https://downloads.openwrt.org/releases/${openwrt_version}/targets/ipq40xx/generic/openwrt-imagebuilder-${openwrt_version}-ipq40xx-generic.Linux-x86_64.tar.xz | \
    tar --strip-components=1 -C _build/ -Jxvf -
  touch _build/.setup
fi

for f in $(find files/ -type f); do
  mkdir -p $(dirname _build/$f)
  envsubst "$INJECT_ENV" < $f > _build/$f
done

for src in $(find files.enc/ -type f); do
  dst=${src/files.enc/files}
  mkdir -p $(dirname _build/$dst)
  sops -d $src > _build/$dst
done

# imagebuilder settings
export BIN_DIR="."
export FILES="files"
export PACKAGES=$(cat packages | xargs)
export PROFILE=avm_fritzbox-4040
export DISABLED_SERVICES="dropbear" # using openssh-server instead

make -C _build/ image PACKAGES="$PACKAGES"
