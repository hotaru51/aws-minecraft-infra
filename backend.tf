terraform {
  required_version = "1.7.1"

  required_providers {
    aws = {
      version = "5.34.0"
    }
  }

  backend "s3" {}
}
