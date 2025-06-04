variable "create_group" {
  type        = bool
  default     = true
  description = "Set to false to not create EventBridge schedule group"
}

variable "group_name" {
  type        = string
  description = "Optional. Existing EventBridge Scheduler group name to use. Leave empty to create a new one."
  default     = ""
}

variable "enable_ec2" {
  type        = bool
  default     = false
  description = "Set to true to enable EC2 start/stop"
}

variable "start_ec2_schedule" {
  type        = string
  default     = ""
  description = "Cron expression for starting EC2s. Eg: cron(5 12 * * MON-FRI *)"
}

variable "stop_ec2_schedule" {
  type        = string
  default     = ""
  description = "Cron expression for stopping EC2s. Eg: cron(5 12 * * MON-FRI *)"
}

variable "instanceids" {
  type        = list(string)
  default     = []
  description = "List of EC2 instance IDs for start/stop scope"
}

variable "start_rds_schedule" {
  type        = string
  default     = ""
  description = "Cron expression for starting RDS instance Eg: cron(5 12 * * MON-FRI *)"
}

variable "stop_rds_schedule" {
  type        = string
  default     = ""
  description = "Cron expression for stopping RDS instance. Eg: cron(5 12 * * MON-FRI *)"
}

variable "dbinstanceidentifier" {
  type        = string
  default     = ""
  description = "Instance identifier of RDS instance to start/stop"
}

variable "enable_rds" {
  type        = bool
  default     = false
  description = "Set to true to enable RDS start/stop"
}

variable "schedule_expression_timezone" {
  type        = string
  default     = "Europe/Helsinki"
  description = "The time zone for the schedule. Defaults Finnish time."
}

variable "role_arn" {
  type        = string
  default     = ""
  description = "IAM Role ARN to use when not creating one. If no value assigned, will create role and policy."
}

### General variables
variable "tags" {
  description = "Additional tags that will be applied to ECS cluster"
  type        = map(string)
  default     = {}
}
