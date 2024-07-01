#!/bin/bash
set -ueo pipefail

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl="chroot /host kubectl"

mac_addr=$(basename "$REQUEST_URI" | tr '[:upper:]' '[:lower:]' | tr ':' '-')
node=$($kubectl get node -o name -l "samcday.com/mac=$mac_addr" | head -n1)

if [[ -z "$node" ]]; then
  echo "ignition request for unknown mac $mac_addr" >&2
  echo "Status: 404"
  echo
  exit
fi

if ! $kubectl get "$node" -o jsonpath='{.metadata.annotations}' | jq -e '. | keys | any(. == "samcday.com/boot")' >/dev/null 2>&1; then
  echo "ignition request for $node which is missing boot annotation" >&2
  echo "Status: 404"
  echo
  exit
fi

if ! $kubectl get "$node" -o jsonpath='{.metadata.annotations}' | jq -e '. | keys | any(. == "samcday.com/boot-profiles")' >/dev/null 2>&1; then
  echo "ignition request for $node which is missing boot-profiles annotation" >&2
  echo "Status: 404"
  echo
  exit
fi

resp=$(curl --fail https://builds.coreos.fedoraproject.org/streams/stable.json | jq .architectures.x86_64.artifacts.metal.formats.pxe)

kernel=$(jq -r .kernel.location    <<< "$resp")
rootfs=$(jq -r .rootfs.location    <<< "$resp")
initrd=$(jq -r .initramfs.location <<< "$resp")

echo "content-type: application/json"
echo
cat <<HERE
{
  "kernel": "$kernel",
  "initrd": ["$initrd"],
  "cmdline": "coreos.live.rootfs_url={{ URL \"$rootfs\" }} coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url={{ URL \"/ignition/$mac_addr\" }}"
}
HERE
