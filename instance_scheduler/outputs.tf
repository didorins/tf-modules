output "group_name" {
  value = try(aws_scheduler_schedule_group.this[0].id, null)
}

output "role_arn" {
  value = try(aws_iam_role.this[0].arn, null)
}