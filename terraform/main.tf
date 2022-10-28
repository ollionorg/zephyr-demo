provider "google" {
  project = var.GOOGLE_PROJECT
}


terraform {
  required_version = ">= 0.12"
}

provider "random" {}

resource "random_string" "random" {
  length    = 8
  special   = false
  min_lower = 8
}

variable "GOOGLE_PROJECT" {
  default = null
}

resource "google_storage_bucket" "website_bucket" {
  name          = "zephyr-demo-${random_string.random.result}"
  location      = var.BUCKET_LOCATION
  force_destroy = true

  website {
    main_page_suffix = "output.html"
    not_found_page   = "output.html"
  }
  
  labels   = {
      #Added to prevent security alerts
      allow_public_bucket_acl  = "true"
  }
  lifecycle_rule {
    condition {
      age = "1"
    }
    action {
      type = "Delete"
    }
  }
}
resource "google_storage_bucket_acl" "website_bucket_acl" {
  provider    = google-beta
  bucket      = google_storage_bucket.website_bucket.name
  role_entity = ["READER:allUsers"]
}

resource "google_storage_default_object_access_control" "public_rule" {
  bucket = google_storage_bucket.website_bucket.name
  role   = "READER"
  entity = "allUsers"

  depends_on = [google_storage_bucket_acl.website_bucket_acl]
}

variable "BUCKET_LOCATION" {
description = "The geographic location of the storage bucket (US, EU, ASIA)."
type        = string
default     = "US"
}
