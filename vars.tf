# デプロイ先リージョン
variable "region" {
  type    = string
  default = "ap-northeast-1"
}

# 各リソース名やNameタグのprefix
variable "resource_name_prefix" {
  type    = string
  default = "htr"
}

# VPCのCIDR
variable "vpc_cidr_block" {
  type = string
}

# public subnet(a)のCIDR
variable "public_subnet_a_cidr_block" {
  type = string
}

# public subnet(c)のCIDR
variable "public_subnet_c_cidr_block" {
  type = string
}
