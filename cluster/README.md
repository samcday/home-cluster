# home-cluster manifests

This directory contains the Kubernetes manifests for my home-cluster. It is reconciled with Flux.


## Early bootstrap

`boot/` brings up nodes ready to be Kubernetes cluster members. A small amount of manual poking is required to bootstrap the cluster from scratch initially.

```sh
ssh core@m710q-1 sudo kubeadm init --config /etc/kubeadm.yaml

ssh core@m710q-1 "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config
chmod 600 ~/.kube/config


helm install cilium cilium/cilium --version 1.14.1  --namespace kube-system --values cluster/cilium-values.yaml

ssh core@m710q-2 sudo kubeadm join --config /etc/kubeadm.yaml
ssh core@m710q-3 sudo kubeadm join --config /etc/kubeadm.yaml

helm install flux flux2 --repo=https://fluxcd-community.github.io/helm-charts -n flux-system --create-namespace --values cluster/flux-values.yaml
sops -d cluster/secrets/flux-system/age-key.yaml | kubectl apply -f-

kubectl apply -k cluster/flux-system

# Once prom-operator has been reconciled
helm upgrade flux flux2 --repo=https://fluxcd-community.github.io/helm-charts -n flux-system --values cluster/flux-values.yaml --values cluster/flux-values-monitoring.yaml
```
