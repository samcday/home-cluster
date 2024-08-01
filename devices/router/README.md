# home-cluster router

This directory contains scripts/files necessary to build a custom OpenWRT image using [Image Builder][].

There is one router for each "availability zone". They're all flashed with the same image built from this tree.

## Building

```
./build-image.sh <name> <platform> <target> <profile>

# Example to build for an AVM 4040
./build-image.sh ipq40xx generic avm_fritzbox-4040

# And for an RT-AX53U:
./build-image.sh ramips mt7621 asus_rt-ax53u
```

[Image Builder]: https://openwrt.org/docs/guide-user/additional-software/imagebuilder
