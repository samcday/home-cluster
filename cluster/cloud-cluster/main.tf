terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.47.0"
    }
  }
}

provider "hcloud" {}

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
