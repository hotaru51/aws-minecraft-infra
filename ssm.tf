data "aws_ssm_parameter" "mcs-token-parameter" {
  name = var.token_parameter_name
}
