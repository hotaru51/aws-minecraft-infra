provider "aws" {
  region = var.region

  default_tags {
    tags = {
      CostGroup = var.cost_allocation_tag_value
    }
  }
}
