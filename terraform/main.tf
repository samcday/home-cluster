terraform {
  backend "local" {}

  required_providers {
    dmsnitch = {
      source  = "plukevdh/dmsnitch"
      version = "0.1.5"
    }
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

provider "dmsnitch" {}
provider "github" {}
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

data "kubernetes_secret" "webhook-token" {
  metadata {
    name      = "webhook-token"
    namespace = "flux-system"
  }
}

data "kubernetes_resource" "receiver" {
  api_version = "notification.toolkit.fluxcd.io/v1"
  kind        = "Receiver"

  metadata {
    name      = "home-cluster"
    namespace = "flux-system"
  }
}

resource "github_repository_webhook" "push" {
  active = true
  configuration {
    content_type = "form"
    insecure_ssl = false
    secret       = data.kubernetes_secret.webhook-token.data.token
    url          = "https://home-flux.samcday.com${data.kubernetes_resource.receiver.object.status.webhookPath}"
  }
  events     = ["push"]
  repository = "home-cluster"
}
