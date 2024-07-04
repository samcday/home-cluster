#!/bin/bash
set -ueo pipefail

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl="chroot /host kubectl"

mac_addr=$(basename "$REQUEST_URI" | tr '[:upper:]' '[:lower:]' | tr ':' '-')
node=$($kubectl get node -o name -l "samcday.com/mac=$mac_addr" | head -n1)

echo "content-type: application/json"
echo

function booterr() {
  echo $1 >&2
  cat <<HERE
{
  "ipxe-script": "#!ipxe\nexit"
}
HERE
  exit
}

if [[ -z "$node" ]]; then
  booterr "boot request for unknown mac $mac_addr"
fi

if ! $kubectl get "$node" -o jsonpath='{.metadata.annotations}' | jq -e '. | keys | any(. == "samcday.com/boot-profiles")' >/dev/null 2>&1; then
  booterr "boot request for $node which is missing boot-profiles annotation"
fi

resp=$(curl -s --fail https://mirror.samcday.com/builds.coreos.fedoraproject.org/streams/stable.json | jq .architectures.x86_64.artifacts.metal.formats.pxe)

kernel=$(jq -r .kernel.location    <<< "$resp")
rootfs=$(jq -r .rootfs.location    <<< "$resp")
initrd=$(jq -r .initramfs.location <<< "$resp")

# Ensure the artifacts are pulled from mirror.
kernel=${kernel/\/\/builds.coreos.fedoraproject.org///mirror.samcday.com/builds.coreos.fedoraproject.org}
rootfs=${rootfs/\/\/builds.coreos.fedoraproject.org///mirror.samcday.com/builds.coreos.fedoraproject.org}
initrd=${initrd/\/\/builds.coreos.fedoraproject.org///mirror.samcday.com/builds.coreos.fedoraproject.org}

cat <<HERE
{
  "kernel": "$kernel",
  "initrd": ["$initrd"],
  "cmdline": "coreos.live.rootfs_url={{ URL \"$rootfs\" }} coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url={{ URL \"/ignition/$mac_addr\" }}"
}
HERE
