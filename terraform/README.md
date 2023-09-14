# terraform

The Terraform configs here manage various bits of infrastructure outside of the core cluster and devices.

It's split into two distinct sets:

 * `init/` is for early Terraform that needs to be applied before the cluster exists
 * `main/` is for everything else
