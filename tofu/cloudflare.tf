data "cloudflare_api_token_permission_groups" "all" {}

resource "cloudflare_api_token" "cloud-cluster" {
  name = "cloud-cluster"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.account["Cloudflare Tunnel Edit"],
    ]
    resources = {
      "com.cloudflare.api.account.*" = "*"
    }
  }
}

resource "kubernetes_secret" "cloudflared-tunnel-token" {
  metadata {
    name      = "cloudflare-token"
    namespace = "cloud-cluster"
  }

  data = {
    "CLOUDFLARE_API_TOKEN" = cloudflare_api_token.cloud-cluster.tunnel_token
  }
}
