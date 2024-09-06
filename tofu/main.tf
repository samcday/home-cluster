terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.12"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.41.0"
    }
    dmsnitch = {
      source  = "plukevdh/dmsnitch"
      version = "0.1.5"
    }
    github = {
      source  = "integrations/github"
      version = "6.2.3"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
  }
}

provider "b2" {}
provider "cloudflare" {}
provider "dmsnitch" {}
provider "github" {}
provider "kubernetes" {}
