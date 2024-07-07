# home-cluster

A self-hosting platform for my digital life.

![A picture of my home cluster, which is 5 Lenovo Thinkcentre 1-liter volume computers, stacked on top of one another. An Xbox Controller leans on one side of the stack, demonstrating that it is not very physically large - measuring about 20cm in height, width, and depth.](./.github/readme-pic.jpg)

The core cluster is:

 - 4x Lenovo Thinkcentre M710q
 - 1x Lenovo Thinkcentre M715q
 - 5 port gigabit switch
 - AVM FRITZ!Box 4040 router

The cluster is powered by Kubernetes. Everything is managed, GitOps style, from this repository.

All nodes run [Fedora CoreOS][], the base OCI image is customized a bit in [`node/`][]. [Ignition] is used to provision the nodes with secrets and late-bound config. The configs are located in [`ignition/`][]. The cluster can reprovision its own via PXE netboot infrastructure, see the [Pixiecore setup for more info](./cluster/kube-system/pixiecore.yaml).

The Kubernetes control plane runs on all 5 nodes to ensure resiliency against up to 2 nodes failing simultaneously. The cluster itself is reconciled with Flux, the manifests are located in [`cluster/`][]. Storage is provided by Ceph, and networking is powered by Cilium.

Infrastructure bits outside the cluster are managed by OpenTofu configs in [`tofu/`](./tofu), reconciled by Flux tf-controller.

The router runs OpenWRT, the image is built in [`devices/router/`][].

[Fedora CoreOS]: https://fedoraproject.org/coreos/
[`node/`]: ./node/README.md
[`ignition/`]: ./ignition/README.md
[Ignition]: https://docs.fedoraproject.org/en-US/fedora-coreos/producing-ign/
[`cluster/`]./cluster/README.md
[`devices/router/`]./devices/router/README.md