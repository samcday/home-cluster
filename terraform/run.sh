#!/bin/bash
set -uexo pipefail

state_dir=$(mktemp -d)
sops -d state > "${state_dir}/state.decrypted"

function encrypt() {
    if  [[ -f "${state_dir}/state.decrypted" ]] &&
        [[ -f "${state_dir}/state.decrypted.new" ]] &&
        ! diff "${state_dir}/state.decrypted" "${state_dir}/state.decrypted.orig";
    then
        sops -e -a age10c9vvuvfkflc7zypu6zm8dtw0gdn028nlr3gslt35df8vdqrap5q36xav4 "${state_dir}/state.decrypted.new" > state
    fi
    rm -rf $state_dir
}
trap encrypt EXIT

export KUBE_CONFIG_PATH=${KUBECONFIG:-$HOME/.kube/config}
tf_cmd="terraform $*"
if [[ -z "${SKIP_STATE:-}" ]]; then
    tf_cmd="$tf_cmd -state=${state_dir}/state.decrypted -state-out=${state_dir}/state.decrypted.new -backup=-"
fi

sops exec-env env.yaml "$tf_cmd"
