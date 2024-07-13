data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "cloud-cluster" {
  name = "cloud-cluster"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.account["Argo Tunnel Write"],
      data.cloudflare_api_token_permission_groups.all.account["DNS Write"],
    ]
    resources = {
      "com.cloudflare.api.account.*" = "*"
    }
  }
}

resource "kubernetes_secret" "cloudflared-tunnel-token" {
  metadata {
    name      = "cloudflare"
    namespace = "cloud-cluster"
  }

  data = {
    "token" = cloudflare_api_token.cloud-cluster.value
  }
}
