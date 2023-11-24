# home-cluster

My Kubernetes cluster, at home.

The core cluster is 3x Lenovo Thinkcentre M710q USFF PCs, and a (WIP) postmarketOS phone (currently: ghetto FP2, soon: Galaxy A5) that handles some administrative duties.

!TODO: photo

## Overview

Every facet of the cluster is managed as code, in this repository.

The M710q nodes run CoreOS, the Ignition is generated in [`control-plane/`](./control-plane/README.md). The root partition is encrypted, and uses Clevis to pin Tang+TPM2. `/var` is encrypted as a separate partition with a fixed secret.

The Kubernetes cluster is reconciled with Flux, the manifests are in [`cluster/`](./cluster/README.md).

Cluster storage is provided by Ceph.

Cluster networking is powered by "kubenet". Each node is inside a Tailscale tailnet, and the tailnet is used to route intra-cluster traffic.
