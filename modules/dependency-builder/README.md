# dependency-builder

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_archive"></a> [archive](#requirement\_archive) | >=2.4.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >=3.2.2 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >=0.11.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | >=2.4.0 |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |
| <a name="provider_time"></a> [time](#provider\_time) | >=0.11.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.lambda_codebuild_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_iam_role.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.codebuild_trigger_lambda_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.codebuild_trigger_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.codebuild_trigger_vpc_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.codebuild_trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [time_sleep.trigger_codebuild_job](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [archive_file.codebuild_trigger](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_lambda_invocation.trigger_codebuild_job](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_invocation) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_log_group_retention"></a> [cloudwatch\_log\_group\_retention](#input\_cloudwatch\_log\_group\_retention) | Amount of days to keep CloudWatch Log Groups for Lambda functions. 0 = Never Expire | `string` | `"0"` | no |
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | Common name to be used for resources deployed by this module | `string` | n/a | yes |
| <a name="input_golang_version"></a> [golang\_version](#input\_golang\_version) | The version of Golang to leverage in Codebuild | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN for the KMS Key being used for this solution | `string` | n/a | yes |
| <a name="input_python_version"></a> [python\_version](#input\_python\_version) | The version of Python to leverage in Codebuild | `string` | n/a | yes |
| <a name="input_s3_logging_bucket_name"></a> [s3\_logging\_bucket\_name](#input\_s3\_logging\_bucket\_name) | The name of the S3 bucket used to store logs for the solution | `string` | n/a | yes |
| <a name="input_s3_terraform_state_bucket_name"></a> [s3\_terraform\_state\_bucket\_name](#input\_s3\_terraform\_state\_bucket\_name) | The name of the S3 bucket used to store state for the solution | `string` | n/a | yes |
| <a name="input_terraform_runner_version"></a> [terraform\_runner\_version](#input\_terraform\_runner\_version) | The version of the Terraform Runner being built | `string` | n/a | yes |
| <a name="input_vpc_deployment"></a> [vpc\_deployment](#input\_vpc\_deployment) | A boolean flag that devermines whether this solution will be deployed inside a VPC | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to use if leveraging an existing VPC for the solution. Otherwise, a VPC will be created as part of deployment. | `string` | `null` | no |
| <a name="input_vpc_private_subnet_ids"></a> [vpc\_private\_subnet\_ids](#input\_vpc\_private\_subnet\_ids) | Required if `vpc_id` is specified. List of private subnets to use in the provided vpc\_id | `list(string)` | `null` | no |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | Required if `vpc_id` is specified. List of security groups to use in the provided vpc\_id | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lambda_layer_build_status"></a> [lambda\_layer\_build\_status](#output\_lambda\_layer\_build\_status) | n/a |
<!-- END_TF_DOCS -->