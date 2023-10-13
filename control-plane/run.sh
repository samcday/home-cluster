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
podman run --rm -i -v ./build/ignition-files:/files quay.io/coreos/butane:release \
  --pretty --strict -d /files < config.bu > build/config.ign

cd build

# Grab a copy of FCOS stream metadata.
metadata=stable-pxe-$(date --iso-8601).json
if [[ ! -f $metadata ]]; then
  curl https://builds.coreos.fedoraproject.org/streams/stable.json \
    | jq '.architectures.x86_64.artifacts.metal.formats.pxe' \
    > $metadata
fi

# Determine which kernel/initrd/rootfs to download.
kernel_url=$(jq -r .kernel.location < $metadata)
initrd_url=$(jq -r .initramfs.location < $metadata)
rootfs_url=$(jq -r .rootfs.location < $metadata)
kernel=$(basename $kernel_url)
initrd=$(basename $initrd_url)
rootfs=$(basename $rootfs_url)

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
sudo pixiecore boot $kernel $initrd \
  --dhcp-no-bind \
  --cmdline "coreos.live.rootfs_url={{ ID \"$rootfs\" }} coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url={{ ID \"config.ign\" }}"
