terraform {
  backend "kubernetes" {
    secret_suffix = "terraform"
    namespace     = "flux-system"
  }
  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.32.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

provider "github" {}
provider "kubernetes" {}

data "kubernetes_secret" "webhook-token" {
  metadata {
    name      = "webhook-token"
    namespace = "flux-system"
  }
}

data "kubernetes_resource" "receiver" {
  api_version = "notification.toolkit.fluxcd.io/v1beta1"
  kind        = "Receiver"

  metadata {
    name      = "hominions"
    namespace = "flux-system"
  }
}

resource "github_repository_webhook" "push" {
  active = true
  configuration {
    content_type = "form"
    insecure_ssl = false
    secret       = data.kubernetes_secret.webhook-token.data.token
    url          = "https://home-flux.samcday.com${data.kubernetes_resource.receiver.object.status.url}"
  }
  events     = ["push"]
  repository = "hominions"
}
