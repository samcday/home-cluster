# home-cluster control-plane

This directory handles building the artifacts necessary to boot nodes that form the k8s control-plane for my home cluster.

When a node is (re-)installed, it will attempt to PXE boot. I run pixiecore from my personal laptop (using `run.sh`), which will provide the booting machine with CoreOS kernel/initrd/rootfs artifacts, as well as the generated Ignition config.

## Disk encryption

The root partition is encrypted with a TPM2 Clevis pin. This partition is ephemeral, there's nothing on it that isn't defined in the Ignition config.

`/var` is encrypted as a separate partition with a fixed encryption key that is deployed by Ignition.

As a result, the nodes can be trivially re-provisioned without losing stateful data.
