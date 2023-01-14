# minecraftサーバ用のIAMロール
output "mcs-iam-name" {
  value = aws_iam_role.mcs-ec2-role.name
}

# minecraftサーバ用のSG ID
output "mcs-sg-id" {
  value = aws_security_group.mcs-instance-sg.id
}

# サブネットID
output "mcs-subnet-a-id" {
  value = aws_subnet.mcs-subnet-a.id
}
