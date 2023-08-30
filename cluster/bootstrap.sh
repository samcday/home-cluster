#!/bin/bash

helm repo add fluxcd-community https://fluxcd-community.github.io/helm-charts
helm repo update fluxcd-community
helm install flux fluxcd-community/flux2 --values flux-values.yaml -n flux-system --create-namespace
sops -d secrets/flux-system/age-key.yaml | kubectl apply -f-
kubectl apply -k flux-system
