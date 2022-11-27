data "aws_ssm_parameter" "mcs-token-parameter" {
  name = var.token_parameter_name
}

resource "aws_ssm_maintenance_window" "mcs-maintenance-window" {
  name = "${var.resource_name_prefix}-mcs-daily-instance-stop"
  schedule = "cron(0 2 * * ? *)"
  schedule_timezone = "Asia/Tokyo"
  duration = 1
  cutoff = 0
}
