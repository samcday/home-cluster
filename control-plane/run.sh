#!/bin/bash
set -uexo pipefail

if [[ -z "${1:-}" ]]; then
  echo ERROR: hostname parameter not set
  exit 1
fi

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

$butane --pretty --strict -d `pwd`/build <<HERE > build/machine.ign
variant: fcos
version: 1.5.0
ignition:
    config:
        merge:
            - local: config.ign
storage:
  files:
    - path: /etc/hostname
      mode: 0644
      contents:
        inline: $1
HERE

if [[ "${RUN_PIXIECORE:-1}" != "1" ]]; then
  exit 0
fi

cd build

# Grab a copy of FCOS stream metadata.
metadata=stable-pxe-$(date -u +"%Y-%m-%d").json
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
  --cmdline "coreos.live.rootfs_url={{ ID \"$rootfs\" }} coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url={{ ID \"machine.ign\" }}"
