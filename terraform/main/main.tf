terraform {
  backend "local" {
    path = "state.decrypted"
  }

  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.9"
    }
    dmsnitch = {
      source  = "plukevdh/dmsnitch"
      version = "0.1.5"
    }
    github = {
      source  = "integrations/github"
      version = "5.45.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.45.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "0.14.0"
    }
  }
}

provider "b2" {}
provider "dmsnitch" {}
provider "github" {}
provider "hcloud" {}
provider "kubernetes" {}
provider "tailscale" {}
