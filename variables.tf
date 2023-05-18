
variable "name_prefix" {
  description = "[REQUIRED] Used to name and tag resources."
  type        = string
}

variable "name_suffix" {
  description = "[REQUIRED] Suffix to use for naming in global resources (e.g. `main` or `dr`)"
  type        = string
}

variable "environment" {
  description = "[REQUIRED] Environment Friendly name.  (e.g. `dev`, `qa`, `prod`)"
  type        = string
}

variable "elb_settings" {
  type = list(object({
    name            = string
    internal        = bool
    type            = string
    subnets         = list(string)
    certificate_arn = optional(string)
  }))

  description = "[REQUIRED] A list of values to create the load balancer."

  validation {
    condition = (
      var.elb_settings[0].type == "application" ||
      var.elb_settings[0].type == "network"
    )
    error_message = "Invalid load balancer type: type must be one of application or network."
  }
}

variable "access_logs_bucket" {
  description = "[OPTIONAL] Settings for access logging."
  type = object({
    enable_access_logs   = bool
    create_new_bucket    = optional(bool)
    existing_bucket_name = optional(string)
  })
  default = {
    enable_access_logs   = false
    create_new_bucket    = false
    existing_bucket_name = null
  }

  # validation, if enable_access_logs is true, then create_new_bucket must be true or existing_bucket_name must not be null
  validation {
    condition     = var.access_logs_bucket.enable_access_logs == false || var.access_logs_bucket.create_new_bucket == true || var.access_logs_bucket.existing_bucket_name != null
    error_message = "Invalid access_logs_bucket: if enable_access_logs is true, then create_new_bucket must be true or existing_bucket_name must not be null."
  }
}

variable "alb_log_retention_days" {
  description = "[OPTIONAL] The number days logs should be kept before they are automatically removed.  (e.g. `30`)"
  type        = number
  default     = 30

  validation {
    condition     = var.alb_log_retention_days > 0
    error_message = "Invalid alb_log_retention_days: alb_log_retention_days must be a non-zero positive integer."
  }
}

variable "vpc_id" {
  description = "[REQUIRED] The VPC ID"
  type        = string

  validation {
    condition = (
      can(regex("^vpc-[a-z0-9]", var.vpc_id)) && length(substr(var.vpc_id, 4, 17)) == 8 ||
      can(regex("^vpc-[a-z0-9]", var.vpc_id)) && length(substr(var.vpc_id, 4, 17)) == 17
    )
    error_message = "Invalid VPC ID. Must be of format 'vpc-xxxxxxxx' and length of eather 8 or 17 (after the vpc- prefix )."
  }
}

variable "vpc_cidr" {
  description = "[REQUIRED] The VPC CIDR block, Required format: '0.0.0.0/0'"
  type        = string

  validation {
    condition     = try(cidrhost(var.vpc_cidr, 0), null) != null
    error_message = "The CIDR block is invalid. Must be of format '0.0.0.0/0'."
  }
}

variable "create_self_signed_cert" {
  description = "[OPTIONAL] Create a self-signed certificate for the load balancer."
  type        = bool
  default     = false
}

variable "send_outputs_to_ssm" {
  description = "[OPTIONAL] Send outputs to SSM Parameter Store."
  type        = bool
  default     = false
}