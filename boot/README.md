# home-cluster boot

This directory handles building the artifacts necessary to boot a node that is part of my home cluster.

When a node is (re-)installed, it will attempt to PXE boot. The router will serve up the artifacts that are built here.

These artifacts contain early bootstrapping tokens/secrets to do a fully unattended install. Thus, the files are sensitive. The build script assumes it is preparing a USB drive. Thus, to remove the secrets from the router requires only to unplug the USB drive.

The drive itself needs to be securely erased if it is no longer in use. Ideally it would be encrypted, but I haven't explored that possibility in OpenWRT yet.
