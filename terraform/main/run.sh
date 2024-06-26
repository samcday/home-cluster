#!/bin/bash
set -uexo pipefail

sops -d state > state.decrypted
cp state.decrypted state.decrypted.orig

function encrypt() {
    if  ! diff state.decrypted state.decrypted.orig >/dev/null 2>&1; then
        sops -e -a age10c9vvuvfkflc7zypu6zm8dtw0gdn028nlr3gslt35df8vdqrap5q36xav4 state.decrypted > state
    fi
    rm state.decrypted*
}
trap encrypt EXIT

export KUBE_CONFIG_PATH=${KUBECONFIG:-$HOME/.kube/config}
sops exec-env env.yaml "tofu $*"
