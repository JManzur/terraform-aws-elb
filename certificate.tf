/* ALB self-signed TLS certificate */
resource "tls_private_key" "alb" {
  count = var.create_self_signed_cert ? 1 : 0

  algorithm = "RSA"
}

resource "tls_self_signed_cert" "alb" {
  count = var.create_self_signed_cert ? 1 : 0

  private_key_pem = try(tls_private_key.alb[0].private_key_pem, null)

  subject {
    common_name  = "${var.name_prefix}.${var.environment}.local"
    organization = "${upper(var.name_prefix)} Inc."
  }

  validity_period_hours = 87600
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]

  depends_on = [
    tls_self_signed_cert.alb
  ]
}

resource "aws_acm_certificate" "alb" {
  count = var.create_self_signed_cert ? 1 : 0

  private_key      = try(tls_private_key.alb[0].private_key_pem, null)
  certificate_body = try(tls_self_signed_cert.alb[0].cert_pem, null)

  depends_on = [
    tls_private_key.alb,
    tls_self_signed_cert.alb
  ]
}