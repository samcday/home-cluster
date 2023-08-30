terraform {
  backend "kubernetes" {
    secret_suffix = "terraform"
    namespace     = "monitoring"
  }
  required_providers {
    dmsnitch = {
      source  = "plukevdh/dmsnitch"
      version = "0.1.5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

provider "dmsnitch" {}
provider "kubernetes" {}

resource "dmsnitch_snitch" "home-cluster" {
  name = "home-cluster"

  interval = "hourly"
  type     = "basic"
}

resource "kubernetes_secret" "dms-url" {
  metadata {
    name      = "dms-url"
    namespace = "monitoring"
  }

  data = {
    "url" = dmsnitch_snitch.home-cluster.url
  }
}
