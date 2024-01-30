terraform {
  required_version = "1.3.3"

  required_providers {
    aws = {
      version = "4.36.1"
    }
  }

  backend "s3" {}
}
