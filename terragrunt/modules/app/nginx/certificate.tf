resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "this" {
  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = "*.elb.${var.aws_region}.amazonaws.com"
    organization = "Test Org"
  }

  validity_period_hours = 8760
  early_renewal_hours   = 720
  is_ca_certificate     = false

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "kubernetes_secret" "tls" {
  metadata {
    name      = "airflow-tls"
    namespace = "airflow"
  }

  data = {
    "tls.crt" = tls_self_signed_cert.this.cert_pem
    "tls.key" = tls_private_key.this.private_key_pem
  }

  type = "kubernetes.io/tls"
}
