# home-cluster control-plane

This directory handles building the artifacts necessary to boot nodes that form the k8s control-plane for my home cluster.

When a node is (re-)installed, it will attempt to PXE boot. I run pixiecore from my personal laptop (using `run.sh`), which will provide the booting machine with CoreOS kernel/initrd/rootfs artifacts, as well as the generated Ignition config.
