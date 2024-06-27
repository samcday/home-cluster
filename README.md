# home-cluster

My Kubernetes cluster, at home.

The core cluster is 3x Lenovo Thinkcentre M710q USFF PCs, and a AVM FRITZ!Box 4040 router.

## Overview

Every facet of the cluster is managed as code, in this repository.

 * All nodes run CoreOS, customizations are layered into an OCI image in [`node/`](./node/README.md)
 * [`control-plane/`](./control-plane/README.md) has the Ignition config to bootstrap such nodes.
 * The Kubernetes [`cluster/`](./cluster/README.md) manifests are reconciled with Flux.
 * Infrastructure bits outside the cluster are managed by OpenTofu configs in [`terraform/`](./terraform), reconciled by Flux tf-controller.
 * The router runs OpenWRT, the image is built in [`devices/router/`](./devices/router/README.md).
 * Storage is provided by Ceph.
 * Networking is powered by Cilium.
