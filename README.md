# home-cluster

My Kubernetes cluster, at home.

The core cluster is 3x Lenovo Thinkcentre M710q USFF PCs, and a AVM FRITZ!Box 4040 router.

!TODO: photo

## Overview

Every facet of the cluster is managed as code, in this repository.

The M710q nodes run CoreOS, the Ignition is generated in [`boot/`](./boot/README.md). The root partition is encrypted, and uses Clevis to pin Tang+TPM2. `/var` is encrypted as a separate partition with a fixed secret.

The router runs OpenWRT, the image is built in [`router/`](./router/README.md). It runs PXE netboot infra, and serves up the Ignition config when a node is (re-)installing CoreOS.

The Kubernetes cluster is reconciled with Flux, the manifests are in [`cluster/`](./cluster/README.md).

Cluster storage is provided by Ceph.

Cluster networking is powered by Cilium in native L2 mode. Each node is inside a Tailscale tailnet, and the tailnet is used to route intra-cluster traffic.

