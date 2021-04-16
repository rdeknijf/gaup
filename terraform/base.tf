terraform {
  backend "gcs" {
    bucket = "deknijf-tf-state"
    prefix = "gaup"
  }
}

terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

provider "google" {
  project = "deknijf-gaup"
  region  = "europe-west4"
  zone    = "europe-west4-a"
}

provider "cloudflare" {}