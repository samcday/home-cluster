# home-cluster

My Kubernetes cluster, at home.

The core cluster is 3x Lenovo Thinkcentre M710q USFF PCs.

## Overview

Every facet of the cluster is managed as code, in this repository.

 * The [`control-plane/`](./control-plane/README.md) runs CoreOS and uses Ignition to bootstrap.
 * The Kubernetes [`cluster/`](./cluster/README.md) manifests are reconciled with Flux.

Cluster storage is provided by Ceph.

Cluster networking is powered by "kubenet". Each node is inside a Tailscale tailnet, and the tailnet is used to route intra-cluster traffic.
