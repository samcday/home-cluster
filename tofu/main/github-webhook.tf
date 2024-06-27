# Configures a webhook in the home-cluster Github repo to notify Flux on pushes.

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
