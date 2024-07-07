# Manage Dead Man's Switch, save the callback URL into a k8s secret (for use by Prometheus).
# See the dms AlertmanagerConfig for usage of the secret.

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
