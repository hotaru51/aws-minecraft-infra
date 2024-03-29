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

# コスト分配タグの値
variable "cost_allocation_tag_value" {
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

# minecraftサーバプロセスの待受ポート
variable "mcs_listen_port" {
  type = number
}

# minecraftサーバのインスタンスタイプ
variable "mcs_instance_type" {
  type    = string
  default = "t2.micro"
}

# minecraftサーバのAMI
variable "mcs_ami_id" {
  type = string
}

# minecraftサーバで使用するキーペア
variable "mcs_keypair" {
  type = string
}

# DNSレコードに使用されるprefix
variable "dns_record_prefix" {
  type = string
}

# ホストゾーン名
variable "public_hosted_zone_name" {
  type = string
}

# インスタンス起動/停止Lambdaで使用するトークン格納用Parameter名
variable "token_parameter_name" {
  type = string
}
