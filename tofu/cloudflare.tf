data "cloudflare_api_token_permission_groups" "all" {}

data "cloudflare_zone" "samcday" {
  name = "samcday.com"
}

resource "cloudflare_api_token" "cloud-cluster" {
  name = "cloud-cluster"

  policies {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.account["Argo Tunnel Write"],
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
    ]
    resources = {
      "com.cloudflare.api.account.*"                                       = "*"
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.samcday.id}" = "*"
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

resource "cloudflare_dns_record" "smtp2go_cname" {
  zone_id = data.cloudflare_zone.samcday.zone_id
  name    = "em510336"
  value   = "return.smtp2go.net"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_dns_record" "smtp2go_dkim" {
  zone_id = data.cloudflare_zone.samcday.zone_id
  name    = "s510336._domainkey"
  value   = "dkim.smtp2go.net"
  type    = "CNAME"
  proxied = false
}

resource "cloudflare_dns_record" "smtp2go_link" {
  zone_id = data.cloudflare_zone.samcday.zone_id
  name    = "smtp2go-link"
  value   = "track.smtp2go.net"
  type    = "CNAME"
  proxied = false
}
