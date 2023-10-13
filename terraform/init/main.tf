terraform {
  backend "local" {
    path = "state.decrypted"
  }

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.13.11"
    }
  }
}

provider "tailscale" {}
