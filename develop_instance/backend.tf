terraform {
  required_version = "1.7.1"

  required_providers {
    aws = {
      version = "5.34.0"
    }
  }

  backend "s3" {}
}

data "terraform_remote_state" "mcs" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = var.remote_state_object_key
  }
}
