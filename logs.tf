resource "aws_cloudwatch_log_group" "mcs-register-dns-record-function-log" {
  name              = "/aws/lambda/${var.resource_name_prefix}-mcs-register-dns-record-function"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "mcs-instance-start-stop-function-log" {
  name              = "/aws/lambda/${var.resource_name_prefix}-mcs-instance-start-stop-function"
  retention_in_days = 30
}
