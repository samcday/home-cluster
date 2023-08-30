#!/bin/bash
cd "$(dirname "$0")"
set -uexo pipefail

repo="samcday/home-hcloud-provisioner"
sha=$(cat Dockerfile | shasum | awk '{print $1}' | head -c10)
docker build -t $repo:$sha .
docker push $repo:$sha

sed -i -Ee "s#(image: ${repo}:).*#\1$sha#" hcloud-provisioner.yaml
