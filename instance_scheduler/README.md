# Instance schedule module

Solution based on EventBridge Schedules to directly call APIs (such as start/stop instance) on schedule (cron)

pros: simple, flexible cron (in contrast of SSM State Manager associations), zero or close to zero cost over long period
cons: simple, no orchestrator (though can get expensive if we have recurring lambda to check status every X mins etc..) , little to no retry options, can’t scope instances by tag (other than instanceid etc.., because it’s mandatory parameter for api) monitoring in eventbridge dashboard and cloudtrail, cloudwatch (metrics)

can upgrade - notification to sns if invocation fails; deadletter q for debug etc…

Note: Because AWS doesn't support all cron expressions (like 1W), for more advanced invocations, use Lambda for logic or for_each when calling the module.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_scheduler_schedule.start_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.start_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.stop_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.stop_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_group"></a> [create\_group](#input\_create\_group) | Set to false to not create EventBridge schedule group | `bool` | `true` | no |
| <a name="input_dbinstanceidentifier"></a> [dbinstanceidentifier](#input\_dbinstanceidentifier) | Instance identifier of RDS instance to start/stop | `string` | `""` | no |
| <a name="input_enable_ec2"></a> [enable\_ec2](#input\_enable\_ec2) | Set to true to enable EC2 start/stop | `bool` | `false` | no |
| <a name="input_enable_rds"></a> [enable\_rds](#input\_enable\_rds) | Set to true to enable RDS start/stop | `bool` | `false` | no |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | Optional. Existing EventBridge Scheduler group name to use. Leave empty to create a new one. | `string` | `""` | no |
| <a name="input_instanceids"></a> [instanceids](#input\_instanceids) | List of EC2 instance IDs for start/stop scope | `list(string)` | `[]` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | IAM Role ARN to use when not creating one. If no value assigned, will create role and policy. | `string` | `""` | no |
| <a name="input_schedule_expression_timezone"></a> [schedule\_expression\_timezone](#input\_schedule\_expression\_timezone) | The time zone for the schedule. Defaults Finnish time. | `string` | `"Europe/Helsinki"` | no |
| <a name="input_start_ec2_schedule"></a> [start\_ec2\_schedule](#input\_start\_ec2\_schedule) | Cron expression for starting EC2s. Eg: cron(5 12 * * MON-FRI *) | `string` | `""` | no |
| <a name="input_start_rds_schedule"></a> [start\_rds\_schedule](#input\_start\_rds\_schedule) | Cron expression for starting RDS instance Eg: cron(5 12 * * MON-FRI *) | `string` | `""` | no |
| <a name="input_stop_ec2_schedule"></a> [stop\_ec2\_schedule](#input\_stop\_ec2\_schedule) | Cron expression for stopping EC2s. Eg: cron(5 12 * * MON-FRI *) | `string` | `""` | no |
| <a name="input_stop_rds_schedule"></a> [stop\_rds\_schedule](#input\_stop\_rds\_schedule) | Cron expression for stopping RDS instance. Eg: cron(5 12 * * MON-FRI *) | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags that will be applied to ECS cluster | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_group_name"></a> [group\_name](#output\_group\_name) | n/a |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | n/a |

## Example usage

```hcl
module "scheduler" {
  source = "../aws-iac-tf-modules/modules/instance_scheduler"

  enable_ec2 = true
  enable_rds = true

  instanceids        = [module.vm_dbmanagement.instance_id]
  start_ec2_schedule = "cron(50 06 1-10 * ? *)"
  stop_ec2_schedule  = "cron(0 21 * * ? *)"

  dbinstanceidentifier = module.rds_db.tags_all.Name
  start_rds_schedule   = "cron(50 06 1-10 * ? *)"
  stop_rds_schedule    = "cron(0 21 * * ? *)"
}
```

In case of existing role & group, or when calling the same module more than once within same project.
```hcl
module "weekend" {
  source = "../aws-iac-tf-modules/modules/instance_scheduler"

  enable_ec2 = true
  enable_rds = true

  group_name  = module.scheduler.group_name
  role_arn    = module.scheduler.role_arn

  instanceids       = [module.vm_dbmanagement.instance_id]
  stop_ec2_schedule = "cron(10 07 ? * SAT-SUN *)"

  dbinstanceidentifier = module.rds_db.tags_all.Name
  stop_rds_schedule    = "cron(10 07 ? * SAT-SUN *)"
}
```