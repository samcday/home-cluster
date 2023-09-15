# Manages a Backblaze bucket for cluster (etcd + Velero) backups.
# Creates a k8s Secret with the connection details.

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

resource "kubernetes_secret" "miniflux" {
  metadata {
    name      = "backups-bucket"
    namespace = "miniflux"
  }

  data = {
    ACCESS_KEY_ID = "${b2_application_key.backups.application_key_id}"
    ACCESS_SECRET_KEY = "${b2_application_key.backups.application_key}"
  }
}

resource "kubernetes_secret" "synapse" {
  metadata {
    name      = "backups-bucket"
    namespace = "synapse"
  }

  data = {
    ACCESS_KEY_ID = "${b2_application_key.backups.application_key_id}"
    ACCESS_SECRET_KEY = "${b2_application_key.backups.application_key}"
  }
}

locals {
  pg_namespaces = toset(["forgejo", "miniflux", "monitoring", "synapse"])
}

resource "b2_application_key" "postgres-backup-keys" {
  for_each = local.pg_namespaces

  key_name     = "postgres-backup-${each.key}"
  bucket_id    = b2_bucket.backups.bucket_id
  capabilities = ["listAllBucketNames", "listBuckets", "listFiles", "readFiles", "writeFiles", "deleteFiles"]
  name_prefix = "postgres/${each.key}"
}

resource "kubernetes_secret" "postgres-backup-bucket" {
  for_each = local.pg_namespaces

  metadata {
    name      = "postgres-backups-bucket"
    namespace = each.key
    labels = {
      "cnpg.io/reload": "true",
    }
  }

  data = {
    ACCESS_KEY_ID = "${b2_application_key.postgres-backup-keys[each.key].application_key_id}"
    ACCESS_SECRET_KEY = "${b2_application_key.postgres-backup-keys[each.key].application_key}"
  }
}