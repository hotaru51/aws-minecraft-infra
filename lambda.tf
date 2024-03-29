resource "aws_lambda_function" "mcs-register-dns-record-function" {
  filename         = "function_code/register-dns-record-function.zip"
  source_code_hash = filebase64sha256("function_code/register-dns-record-function.zip")
  function_name    = "${var.resource_name_prefix}-mcs-register-dns-record-function"
  role             = aws_iam_role.mcs-function-role.arn
  handler          = "app.lambda_handler"
  runtime          = "ruby3.2"
  timeout          = 15
  memory_size      = 256

  environment {
    variables = {
      PUBLIC_HOSTED_ZONE_ID   = aws_route53_zone.mcs-public-hosted-zone.id
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

resource "aws_lambda_function" "mcs-instance-start-stop-function" {
  filename         = "function_code/instance-start-stop-function.zip"
  source_code_hash = filebase64sha256("function_code/instance-start-stop-function.zip")
  function_name    = "${var.resource_name_prefix}-mcs-instance-start-stop-function"
  role             = aws_iam_role.mcs-function-role.arn
  handler          = "app.lambda_handler"
  runtime          = "ruby3.2"
  timeout          = 15
  memory_size      = 256

  environment {
    variables = {
      TOKEN_PARAMETER_NAME = data.aws_ssm_parameter.mcs-token-parameter.name
      TARGET_INSTANCE      = aws_instance.mcs-instance.id
    }
  }
}

resource "aws_lambda_function_url" "mcs-instance-start-stop-function-url" {
  function_name      = aws_lambda_function.mcs-instance-start-stop-function.function_name
  authorization_type = "NONE"
}
