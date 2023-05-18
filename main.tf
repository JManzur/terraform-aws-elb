locals {
  lb_name_prefix = "${var.name_prefix}-${var.environment}-"
  lb_type_suffixes = {
    application = "-alb"
    network     = "-nbl"
  }
}

resource "aws_lb" "this" {
  for_each = { for elb in var.elb_settings : elb.name => elb }

  name               = "${local.lb_name_prefix}${each.value.name}${lookup(local.lb_type_suffixes, each.value.type, "")}"
  internal           = each.value.internal
  load_balancer_type = each.value.type
  subnets            = each.value.subnets
  security_groups    = [aws_security_group.elb[each.key].id]

  dynamic "access_logs" {
    for_each = var.access_logs_bucket.enable_access_logs ? [1] : []
    content {
      /* 
      The value of "bucket" would be one of the following:
      - null if enable_access_logs is false.
      - existing_bucket_name if existing_bucket_name is not null.
      - The id of the first bucket in the aws_s3_bucket.elb_logs resource if create_new_bucket is true. 
      */
      bucket = var.access_logs_bucket.existing_bucket_name != null ? var.access_logs_bucket.existing_bucket_name : (
        var.access_logs_bucket.create_new_bucket ? aws_s3_bucket.elb_logs[0].id : null
      )
      enabled = true
    }
  }

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = { Name = "${local.lb_name_prefix}${each.value.name}${lookup(local.lb_type_suffixes, each.value.type, "")}" }
}

resource "aws_lb_listener" "http" {
  for_each = { for elb in var.elb_settings : elb.name => elb }

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  for_each = { for elb in var.elb_settings : elb.name => elb }

  load_balancer_arn = aws_lb.this[each.key].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # if each.value.certificate_arn is null and create_self_signed_cert is true, then the first certificate in the aws_acm_certificate.cert resource will be used.
  certificate_arn = each.value.certificate_arn != null ? each.value.certificate_arn : (
    var.create_self_signed_cert ? aws_acm_certificate.alb[0].arn : null
  )
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "The page you're trying to access cannot be found. Please verify the URL or try again later"
      status_code  = "404"
    }
  }
}

resource "aws_security_group" "elb" {
  for_each = { for elb in var.elb_settings : elb.name => elb }

  name        = "${local.lb_name_prefix}${each.value.name}${lookup(local.lb_type_suffixes, each.value.type, "")}-sg"
  description = "${title(each.value.name)} Security Group"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      description = "Allow port ${ingress.value}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = each.value.internal ? [var.vpc_cidr] : ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${local.lb_name_prefix}${each.value.name}${lookup(local.lb_type_suffixes, each.value.type, "")}-sg" }

  lifecycle {
    create_before_destroy = true
  }
}