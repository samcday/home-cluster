terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.9.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.49.1"
    }
    dmsnitch = {
      source  = "plukevdh/dmsnitch"
      version = "0.1.5"
    }
    github = {
      source  = "integrations/github"
      version = "6.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.1"
    }
  }
}

provider "b2" {}
provider "cloudflare" {}
provider "dmsnitch" {}
provider "github" {}
provider "kubernetes" {}
