# home-cluster

My Kubernetes cluster, at home.

The core cluster is 3x Lenovo Thinkcentre M710q USFF PCs, and a AVM FRITZ!Box 4040 router.

## Overview

Every facet of the cluster is managed as code, in this repository.

 * The [`control-plane/`](./control-plane/README.md) runs CoreOS and uses Ignition to bootstrap.
 * The Kubernetes [`cluster/`](./cluster/README.md) manifests are reconciled with Flux.
 * The router runs OpenWRT, the image is built in [`devices/router/`](./devices/router/README.md).
 * Cluster storage is provided by Ceph.
 * Cluster networking is powered by Cilium.
