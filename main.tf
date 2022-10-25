provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  backend "s3" {
    bucket = "htr-mcs-tfstate"
    region = "ap-northeast-1"
    key = "terraform.tfstate"
  }
}
