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

resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "172.28.0.0/16"
}

resource "hcloud_network_subnet" "subnet" {
  network_id   = hcloud_network.network.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "172.28.255.0/24"
}
