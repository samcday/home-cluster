terraform {
  backend "local" {
    path = "state.decrypted"
  }

  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.4"
    }
    dmsnitch = {
      source  = "plukevdh/dmsnitch"
      version = "0.1.5"
    }
    github = {
      source  = "integrations/github"
      version = "5.40.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.44.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.13.11"
    }
  }
}

provider "b2" {}
provider "dmsnitch" {}
provider "github" {}
provider "hcloud" {}
provider "kubernetes" {}
provider "tailscale" {}
