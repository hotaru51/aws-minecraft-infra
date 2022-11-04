resource "aws_lambda_function" "mcs-register-dns-record-function" {
  filename         = "function_code/register-dns-record-function.zip"
  source_code_hash = "function_code/register-dns-record-function.zip"
  function_name    = "${var.resource_name_prefix}-mcs-register-dns-record-function"
  role             = aws_iam_role.mcs-function-role.arn
  handler          = "app.lambda_handler"
  runtime          = "ruby2.7"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      PUBLIC_HOSTED_ZONE_ID = aws_route53_zone.mcs-public-hosted-zone.id
      PUBLIC_HOSTED_ZONE_NAME = aws_route53_zone.mcs-public-hosted-zone.name
    }
  }
}

resource "aws_lambda_permission" "mcs-allow-instance-state-event" {
  statement_id  = "${var.resource_name_prefix}McsAllowServerStopEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mcs-register-dns-record-function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.mcs-instance-state-event.arn
}
