resource "aws_iam_role" "this" {
  count = length(var.role_arn) == 0 ? 1 : 0
  name  = "eventbridge-instance-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "scheduler.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    tomap({
      "created-by-nordcloud-tf" = local.module_version
    }),
    var.tags
  )
}


resource "aws_iam_role_policy" "this" {
  count = length(var.role_arn) == 0 ? 1 : 0
  name  = "eventbridge-instance-scheduler-policy"
  role  = aws_iam_role.this[0].name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "rds:StopDBInstance",
          "rds:StartDBInstance"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_scheduler_schedule_group" "this" {
  count = length(var.group_name) == 0 ? 1 : 0
  name  = "instance-scheduler"

  tags = merge(
    tomap({
      "created-by-nordcloud-tf" = local.module_version
    }),
    var.tags
  )
}

resource "aws_scheduler_schedule" "start_ec2" {
  count       = var.enable_ec2 && length(var.instanceids) > 0 && var.start_ec2_schedule != "" ? 1 : 0
  name_prefix = "start-ec2"
  group_name  = length(var.group_name) > 0 ? var.group_name : aws_scheduler_schedule_group.this[0].name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.start_ec2_schedule
  schedule_expression_timezone = var.schedule_expression_timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = try(aws_iam_role.this[0].arn, var.role_arn)

    input = jsonencode({
      InstanceIds = var.instanceids
    })
  }
}

resource "aws_scheduler_schedule" "stop_ec2" {
  count       = var.enable_ec2 && length(var.instanceids) > 0 && var.stop_ec2_schedule != "" ? 1 : 0
  name_prefix = "stop-ec2"
  group_name  = length(var.group_name) > 0 ? var.group_name : aws_scheduler_schedule_group.this[0].name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.stop_ec2_schedule
  schedule_expression_timezone = var.schedule_expression_timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = try(aws_iam_role.this[0].arn, var.role_arn)

    input = jsonencode({
      InstanceIds = var.instanceids
    })
  }
}

resource "aws_scheduler_schedule" "start_rds" {
  count       = var.enable_rds && length(var.dbinstanceidentifier) > 0 && var.start_rds_schedule != "" ? 1 : 0
  name_prefix = "start-rds"
  group_name  = length(var.group_name) > 0 ? var.group_name : aws_scheduler_schedule_group.this[0].name
  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.start_rds_schedule
  schedule_expression_timezone = var.schedule_expression_timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBInstance"
    role_arn = try(aws_iam_role.this[0].arn, var.role_arn)

    input = jsonencode({
      DbInstanceIdentifier = var.dbinstanceidentifier
    })
  }
}

resource "aws_scheduler_schedule" "stop_rds" {
  count       = var.enable_rds && length(var.dbinstanceidentifier) > 0 && var.stop_rds_schedule != "" ? 1 : 0
  name_prefix = "stop-rds"
  group_name  = length(var.group_name) > 0 ? var.group_name : aws_scheduler_schedule_group.this[0].name

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression          = var.stop_rds_schedule
  schedule_expression_timezone = var.schedule_expression_timezone

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBInstance"
    role_arn = try(aws_iam_role.this[0].arn, var.role_arn)

    input = jsonencode({
      DbInstanceIdentifier = var.dbinstanceidentifier
    })
  }
}