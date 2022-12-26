data "aws_ssm_parameter" "mcs-token-parameter" {
  name = var.token_parameter_name
}

resource "aws_ssm_maintenance_window" "mcs-maintenance-window" {
  name              = "${var.resource_name_prefix}-mcs-daily-instance-stop"
  schedule          = "cron(0 2 * * ? *)"
  schedule_timezone = "Asia/Tokyo"
  duration          = 1
  cutoff            = 0
}

resource "aws_ssm_maintenance_window_target" "mcs-maintenance-window-target" {
  name          = "target-instance"
  window_id     = aws_ssm_maintenance_window.mcs-maintenance-window.id
  resource_type = "INSTANCE"
  targets {
    key    = "tag:InstanceGroup"
    values = [var.resource_name_prefix]
  }
}

resource "aws_ssm_maintenance_window_task" "mcs-maintenance-window-task" {
  name             = "stop-minecraft-server"
  task_type        = "AUTOMATION"
  task_arn         = "AWS-StopEC2Instance"
  window_id        = aws_ssm_maintenance_window.mcs-maintenance-window.id
  service_role_arn = aws_iam_role.mcs-ssm-maintenance-window-role.arn
  priority         = 1
  max_concurrency  = "100%"
  max_errors       = "100%"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.mcs-maintenance-window-target.id]
  }

  task_invocation_parameters {
    automation_parameters {
      document_version = "$DEFAULT"
      parameter {
        name   = "InstanceId"
        values = ["{{TARGET_ID}}"]
      }

      parameter {
        name   = "AutomationAssumeRole"
        values = [aws_iam_role.mcs-ssm-automation-role.arn]
      }
    }
  }
}
