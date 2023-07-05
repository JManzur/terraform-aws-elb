# Terraform AWS ELB Module

Terraform module to create an AWS ELB.

## How to use this module

```bash
module "elb" {
  source = "git::https://github.com/JManzur/terraform-aws-elb.git?ref=vX.X.X"

  # Required variables:
  name_prefix             = "jm"
  environment             = "dev"
  name_suffix             = "poc"
  vpc_id                  = var.vpc_id
  vpc_cidr                = var.vpc_cidr
  create_self_signed_cert = true
  elb_settings = [{
    name     = "internal"
    internal = true
    type     = "application"
    subnets  = var.public_subnets_ids
  }]
  access_logs_bucket = {
    enable_access_logs = false
    create_new_bucket  = false
  }
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_lb.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_s3_bucket.elb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.elb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_policy.elb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.elb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.elb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.elb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.elb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_parameter.alb_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [tls_private_key.alb](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.alb](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.elb_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_logs_bucket"></a> [access\_logs\_bucket](#input\_access\_logs\_bucket) | [OPTIONAL] Settings for access logging. | <pre>object({<br>    enable_access_logs   = bool<br>    create_new_bucket    = optional(bool)<br>    existing_bucket_name = optional(string)<br>  })</pre> | <pre>{<br>  "create_new_bucket": false,<br>  "enable_access_logs": false,<br>  "existing_bucket_name": null<br>}</pre> | no |
| <a name="input_alb_log_retention_days"></a> [alb\_log\_retention\_days](#input\_alb\_log\_retention\_days) | [OPTIONAL] The number days logs should be kept before they are automatically removed.  (e.g. `30`) | `number` | `30` | no |
| <a name="input_create_self_signed_cert"></a> [create\_self\_signed\_cert](#input\_create\_self\_signed\_cert) | [OPTIONAL] Create a self-signed certificate for the load balancer. | `bool` | `false` | no |
| <a name="input_elb_settings"></a> [elb\_settings](#input\_elb\_settings) | [REQUIRED] A list of values to create the load balancer. | <pre>list(object({<br>    name            = string<br>    internal        = bool<br>    type            = string<br>    subnets         = list(string)<br>    certificate_arn = optional(string)<br>  }))</pre> | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | [REQUIRED] Environment Friendly name.  (e.g. `dev`, `qa`, `prod`) | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | [REQUIRED] Used to name and tag resources. | `string` | n/a | yes |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | [REQUIRED] Suffix to use for naming in global resources (e.g. `main` or `dr`) | `string` | n/a | yes |
| <a name="input_send_outputs_to_ssm"></a> [send\_outputs\_to\_ssm](#input\_send\_outputs\_to\_ssm) | [OPTIONAL] Send outputs to SSM Parameter Store. | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | [REQUIRED] The VPC CIDR block, Required format: '0.0.0.0/0' | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | [REQUIRED] The VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_arn"></a> [lb\_arn](#output\_lb\_arn) | The ARN of the ELB |
| <a name="output_lb_dns_name"></a> [lb\_dns\_name](#output\_lb\_dns\_name) | The DNS name of the ELB |
