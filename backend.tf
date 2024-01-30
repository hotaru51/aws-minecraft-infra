terraform {
  required_version = "1.7.1"

  required_providers {
    aws = {
      version = "4.36.1"
    }
  }

  backend "s3" {}
}
