terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.37.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.47.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "cloudflare" {}
provider "hcloud" {}
provider "random" {}

data "cloudflare_api_token_permission_groups" "all" {}

data "cloudflare_zone" "samcday" {
  name = "samcday.com"
}

resource "hcloud_ssh_key" "samcday" {
  name       = "samcday"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwawprQXEkGl38Q7T0PNseL0vpoyr4TbATMkEaZJTWQ"
}

resource "hcloud_placement_group" "placement-group" {
  name = "placement-group"
  type = "spread"
}

resource "hcloud_firewall" "firewall" {
  name = "firewall"
  rule {
    direction = "in"
    protocol  = "udp"
    port      = "41641"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "172.28.0.0/15"
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "172.29.0.0/16"
}

resource "random_password" "tunnel_secret" {
  length           = 32
}

resource "cloudflare_tunnel" "tunnel" {
  name       = "cloud-cluster"
  secret     = base64encode(random_password.tunnel_secret.result)
  account_id = "444c14b123bd021dcdf0400fbd847d63"
}

resource "cloudflare_api_token" "token" {
  name = "cloud-cluster"

  policy {
    permission_groups = [
      data.cloudflare_api_token_permission_groups.all.zone["DNS Write"],
    ]
    resources = {
      "com.cloudflare.api.account.zone.${data.cloudflare_zone.samcday.id}" = "*"
    }
  }
}

output "tunnel_token" {
  value     = cloudflare_tunnel.tunnel.tunnel_token
  sensitive = true
}

output "tunnel_secret" {
  value     = random_password.tunnel_secret.result
  sensitive = true
}

output "tunnel_cname" {
  value = cloudflare_tunnel.tunnel.cname
}

output "token" {
  value     = cloudflare_api_token.token.value
  sensitive = true
}
