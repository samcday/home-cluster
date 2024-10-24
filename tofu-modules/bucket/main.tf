terraform {
  required_providers {
    b2 = {
      source  = "Backblaze/b2"
      version = "0.9.0"
    }
  }
}

provider "b2" {}

variable "name" {
  type = string
}

variable "type" {
  type = string
  default = "allPrivate"
}

resource "b2_bucket" "bucket" {
  bucket_name = "samcday-${var.name}"
  bucket_type = var.type
  lifecycle_rules {
    days_from_hiding_to_deleting = 7
    file_name_prefix             = ""
  }
}

resource "b2_application_key" "key" {
  key_name     = var.name
  bucket_id    = b2_bucket.bucket.bucket_id
  capabilities = ["listAllBucketNames", "listBuckets", "listFiles", "readFiles", "writeFiles", "deleteFiles"]
}

output "access_key_id" {
  sensitive = true
  value = b2_application_key.key.application_key_id
}

output "secret_access_key" {
  sensitive = true
  value = b2_application_key.key.application_key
}
