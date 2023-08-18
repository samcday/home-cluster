# home-cluster router

This directory contains scripts/files necessary to build a custom OpenWRT 22.03 image (using [imagebuilder](https://openwrt.org/docs/guide-user/additional-software/imagebuilder)) for the AVM FRITZ!Box 4040 that handles routing for my home cluster.

## Netboot infra

The nodes that make up my home cluster can bootstrap the installation of CoreOS from this router.

The router itself is configured with static DHCP assignments for each node, and will serve up the iPXE binary, Ignition config, and CoreOS kernel/initrd/rootfs artifacts.

All of these artifacts are located on an external USB drive. Preparation of these artifacts is handled in [`../boot`](../boot/README.md).
