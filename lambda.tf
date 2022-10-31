resource "aws_lambda_function" "mcs-delete-dns-record-function" {
  filename         = "function_code/delete-dns-record-function.zip"
  source_code_hash = "function_code/delete-dns-record-function.zip"
  function_name    = "${var.resource_name_prefix}-mcs-delete-dns-record-function"
  role             = aws_iam_role.mcs-function-role.arn
  handler          = "app.lambda_handler"
  runtime          = "ruby2.7"
}

resource "aws_lambda_permission" "mcs-allow-server-stop-event" {
  statement_id  = "${var.resource_name_prefix}McsAllowServerStopEvent"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.mcs-delete-dns-record-function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.mcs-server-stop-event.arn
}
