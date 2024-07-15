terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.8.12"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.31.0"
    }
  }
}

provider "b2" {}
provider "kubernetes" {}

variable "namespace" {
  type = string
}

resource "b2_bucket" "bucket" {
  bucket_name = "samcday-${var.namespace}-pgbackups"
  bucket_type = "allPrivate"
  lifecycle_rules {
    days_from_hiding_to_deleting = 7
    file_name_prefix             = ""
  }
}

resource "b2_application_key" "key" {
  key_name     = "${var.namespace}-pgbackups"
  bucket_id    = b2_bucket.bucket.bucket_id
  capabilities = ["listAllBucketNames", "listBuckets", "listFiles", "readFiles", "writeFiles", "deleteFiles"]
}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = "postgres-backups-bucket"
    namespace = var.namespace
    labels = {
      "cnpg.io/reload" : "true",
    }
  }

  data = {
    ACCESS_KEY_ID     = "${b2_application_key.key.application_key_id}"
    ACCESS_SECRET_KEY = "${b2_application_key.key.application_key}"
  }
}
