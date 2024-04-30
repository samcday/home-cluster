terraform {
  backend "local" {
    path = "state.decrypted"
  }

  required_providers {
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.16.0"
    }
  }
}

provider "tailscale" {}
