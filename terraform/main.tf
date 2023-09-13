terraform {
  backend "local" {
    path = "state.decrypted"
  }

  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.4"
    }
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

provider "b2" {}
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


resource "b2_bucket" "backups" {
  bucket_name = "samcday-home-cluster-backups"
  bucket_type = "allPrivate"
  lifecycle_rules {
    days_from_hiding_to_deleting = 7
    file_name_prefix             = ""
  }
}

resource "b2_application_key" "backups" {
  key_name     = "kube-system"
  bucket_id    = b2_bucket.backups.bucket_id
  capabilities = ["listAllBucketNames", "listBuckets", "listFiles", "readFiles", "writeFiles", "deleteFiles"]
}

resource "kubernetes_secret" "backups-bucket" {
  metadata {
    name      = "backups-bucket"
    namespace = "kube-system"
  }

  data = {
    "rclone.conf" = <<-EOT
    [remote]
    type = s3
    provider = Other
    access_key_id = ${b2_application_key.backups.application_key_id}
    secret_access_key = ${b2_application_key.backups.application_key}
    endpoint = s3.eu-central-003.backblazeb2.com
    acl = private
    EOT
    "velero" = <<-EOT
    [default]
    aws_access_key_id=${b2_application_key.backups.application_key_id}
    aws_secret_access_key=${b2_application_key.backups.application_key}
    EOT
  }
}
