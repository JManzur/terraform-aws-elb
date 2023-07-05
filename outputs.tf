output "lb_arn" {
  description = "The ARN of the ELB"
  value       = { for name, lb in aws_lb.this : name => lb.arn }
}

output "lb_dns_name" {
  description = "The DNS name of the ELB"
  value       = { for name, lb in aws_lb.this : name => lb.dns_name }
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created"
  value       = { for name, lb in aws_lb_listener.https : name => lb.arn }
}

resource "aws_ssm_parameter" "alb_arn" {
  count = var.send_outputs_to_ssm ? length(var.elb_settings) : 0

  name  = "/${var.name_prefix}/${var.environment}/alb/${var.elb_settings[count.index].name}/arn"
  type  = "String"
  value = aws_lb.this[var.elb_settings[count.index].name].arn
}