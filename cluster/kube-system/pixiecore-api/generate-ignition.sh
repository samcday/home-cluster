#!/bin/bash
set -ueo pipefail

export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl="chroot /host kubectl"
kubeadm="chroot /host kubeadm"

mac_addr=$(basename "$REQUEST_URI" | tr '[:upper:]' '[:lower:]' | tr ':' '-')
node=$($kubectl get node -o name -l "samcday.com/mac=$mac_addr" | head -n1)

if [[ -z "$node" ]]; then
  echo "ignition request for unknown mac $mac_addr" >&2
  echo "Status: 404"
  echo
  exit
fi

bootprofiles="$($kubectl get "$node" -o jsonpath='{.metadata.annotations.samcday\.com/boot-profiles}')"

if [[ -z "$bootprofiles" ]]; then
  echo "ignition request for $node which is missing boot-profile annotations" >&2
  echo "Status: 404"
  echo
  exit
fi

token=$($kubeadm token create)
cahash=$(chroot /host bash -c "openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
       | openssl rsa -pubin -outform der 2>/dev/null \
       | openssl dgst -sha256 -hex | sed 's/^.* //'")

echo "content-type: application/json"
echo

controlplane=""
if $kubectl get "$node" -o jsonpath='{.metadata.labels}' | jq -e '. | keys | any(. == "node-role.kubernetes.io/control-plane")' >/dev/null 2>&1; then
  certkey=$($kubeadm certs certificate-key)
  $kubeadm init phase upload-certs --upload-certs --certificate-key "$certkey" >&2
  controlplane="
            controlPlane:
              certificateKey: \"$certkey\""
fi

IFS=","; for n in $bootprofiles; do
  merge+="
        - local: $n.ign"
done

hostname=${node/node\/}

rm -rf /host/tmp/ignition
mkdir -p /host/tmp/ignition
cp /ignition/*.ign /host/tmp/ignition/
chroot /host butane -d /tmp/ignition --strict <<HERE
variant: fcos
version: 1.5.0
ignition:
  config:
    merge: $merge
storage:
  files:
    - path: /etc/hostname
      mode: 0644
      contents:
        inline: $hostname
    - path: /etc/kubeadm.conf.d/70-join.yaml
      contents:
        inline: |
          ---
          apiVersion: kubeadm.k8s.io/v1beta3
          kind: JoinConfiguration
          nodeRegistration:
              taints: []
          $controlplane
          discovery:
              bootstrapToken:
                  apiServerEndpoint: 10.0.1.254:6443
                  token: "$token"
                  caCertHashes: ["sha256:$cahash"]
HERE
rm -rf /host/tmp/ignition
