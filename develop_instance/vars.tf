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

# minecraftサーバのAMI
# バックアップのAMIから起動する場合はオプション等で指定する
variable "dev_ami_id" {
  type    = string
  default = null
}

# minecraftサーバで使用するキーペア
variable "mcs_keypair" {
  type = string
}

# remote_stateの参照先bucket
variable "remote_state_bucket" {
  type = string
}

# remote_stateの参照先bucketのregion
variable "remote_state_region" {
  type = string
}

# remote_stateのobject key
variable "remote_state_object_key" {
  type = string
}
