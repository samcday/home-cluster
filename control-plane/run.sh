#!/bin/bash
set -uexo pipefail

mkdir -p build

# Prepare Ignition files in build dir.
rm -rf build/ignition-files
cp -R ignition-files build/
for f in $(find ignition-files.enc/ -type f); do
	dst=${f/files.enc/files}
  mkdir -p build/$(dirname $dst)
  sops -d $f > build/$dst
done

# Compile Ignition config.
butane="butane"
if ! $butane --version; then
	butane="podman run --rm -i -v `pwd`/build/ignition-files:`pwd`/build/ignition-files quay.io/coreos/butane:release"
fi

$butane --pretty --strict -d `pwd`/build/ignition-files < config.bu > build/config.ign


if [[ "${RUN_PIXIECORE:-1}" != "1" ]]; then
  exit 0
fi

cd build

[[ -n "${FCOS_STREAM:-}" ]] || FCOS_STREAM=stable

if [[ -z "${FCOS_VERSION:-}" ]]; then
  # Grab a copy of FCOS stream metadata.
  metadata=stable-pxe-$(date -u +"%Y-%m-%d").json
  if [[ ! -f $metadata ]]; then
    curl https://builds.coreos.fedoraproject.org/streams/${FCOS_STREAM}.json \
      | jq '.architectures.x86_64.artifacts.metal' \
      > $metadata
  fi
  FCOS_VERSION=$(jq -r .release < $metadata)
fi

url_base="https://builds.coreos.fedoraproject.org/prod/streams/${FCOS_STREAM}/builds/${FCOS_VERSION}/x86_64"

kernel="fedora-coreos-${FCOS_VERSION}-live-kernel.x86_64.img"
initrd="fedora-coreos-${FCOS_VERSION}-live-initramfs.x86_64.img"
rootfs="fedora-coreos-${FCOS_VERSION}-live-rootfs.x86_64.img"

kernel_url="${url_base}/${kernel}"
initrd_url="${url_base}/${initrd}"
rootfs_url="${url_base}/${rootfs}"

# Download FCOS artifacts.
for v in kernel initrd rootfs; do
  urlv="${v}_url"
  url=${!urlv}
  file=${!v}

  if [[ ! -f $file ]]; then
    curl -o $file.tmp $url
    mv $file.tmp $file
  fi
done

# Run pixiecore and provide it with the downloaded FCOS artifacts.
sudo docker run --net=host -v `pwd`:/pixiecore pixiecore/pixiecore:master \
  boot -d $kernel $initrd \
  --dhcp-no-bind \
  --cmdline "coreos.live.rootfs_url={{ ID \"$rootfs\" }} coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url={{ ID \"config.ign\" }}"
