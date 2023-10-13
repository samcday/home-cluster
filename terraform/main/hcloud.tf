variable "kubeadm_token" {
  sensitive = true
  type      = string
}

resource "hcloud_ssh_key" "me" {
  name       = "me"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFwawprQXEkGl38Q7T0PNseL0vpoyr4TbATMkEaZJTWQ"
}

resource "tailscale_tailnet_key" "hcloud" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 90 * 24 * 60 * 60
  tags          = ["tag:home-cluster"]
}

resource "hcloud_server" "server" {
  count       = 2
  name        = "hcloud-${count.index + 1}"
  server_type = "cax11"
  image       = "ubuntu-22.04"
  ssh_keys = [hcloud_ssh_key.me.id]
  user_data   = <<-HERE
    #!/bin/bash
    set -uexo pipefail

    export DEBIAN_FRONTEND=noninteractive

    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.noarmor.gpg > /usr/share/keyrings/tailscale-archive-keyring.gpg
    curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/jammy.tailscale-keyring.list > /etc/apt/sources.list.d/tailscale.list
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' > /etc/apt/sources.list.d/kubernetes.list
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

    apt-get update
    apt-get install -y containernetworking-plugins tailscale containerd.io kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl

    containerd config default | sed 's/SystemdCgroup = false/SystemdCgroup = true/' > /etc/containerd/config.toml
    systemctl restart containerd

    tailscale up --auth-key=${tailscale_tailnet_key.hcloud.key} --accept-dns --accept-routes

    cat > /etc/modules-load.d/k8s.conf <<MODS
    br_netfilter
    overlay
    MODS
    modprobe overlay
    modprobe br_netfilter

    cat > /etc/sysctl.d/k8s.conf <<SYSCTL
    net.bridge.bridge-nf-call-iptables  = 1
    net.bridge.bridge-nf-call-ip6tables = 1
    net.ipv4.ip_forward                 = 1
    net.ipv6.conf.all.forwarding        = 1
    fs.inotify.max_user_instances       = 8192
    fs.inotify.max_user_watches         = 524288
    SYSCTL
    systemctl restart systemd-sysctl

    kubeadm join --config /dev/stdin <<KUBEADM
    apiVersion: kubeadm.k8s.io/v1beta3
    kind: ClusterConfiguration
    controlPlaneEndpoint: 172.29.0.1:6444
    networking:
        dnsDomain: home-cluster.local
        podSubnet: 172.30.0.0/16,fdab:bc3f:3e04::/56
        serviceSubnet: 172.31.0.0/16,fd7f:bc81:7c5c::/112
    ---
    apiVersion: kubeadm.k8s.io/v1beta3
    kind: JoinConfiguration
    nodeRegistration:
        kubeletExtraArgs:
            cloud-provider: external
        taints:
          - key: samcday.com/hcloud
            value: "1"
            effect: NoExecute
    discovery:
        bootstrapToken:
            apiServerEndpoint: 172.29.0.1:6444
            token: ${var.kubeadm_token}
            caCertHashes:
                - sha256:115e5a84bdb260f15defdbd836acf108769cff1e18bc9e2c473eb6f208051c58
    KUBEADM
  HERE
}
