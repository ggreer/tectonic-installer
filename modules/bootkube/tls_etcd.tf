resource "tls_private_key" "etcd-ca" {
  count = "${!var.experimental_enabled && var.etcd_tls_enabled ? 1 : 0}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "etcd-ca" {
  count = "${!var.experimental_enabled && var.etcd_tls_enabled ? 1 : 0}"

  key_algorithm   = "${tls_private_key.etcd-ca.algorithm}"
  private_key_pem = "${tls_private_key.etcd-ca.private_key_pem}"

  subject {
    common_name  = "etcd-ca"
    organization = "etcd"
  }

  is_ca_certificate     = true
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

resource "tls_private_key" "etcd_client" {
  count = "${!var.experimental_enabled && var.etcd_tls_enabled ? 1 : 0}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "etcd_client" {
  count = "${!var.experimental_enabled && var.etcd_tls_enabled ? 1 : 0}"

  key_algorithm   = "${tls_private_key.etcd_client.algorithm}"
  private_key_pem = "${tls_private_key.etcd_client.private_key_pem}"

  subject {
    common_name  = "etcd"
    organization = "etcd"
  }

  dns_names = ["${var.etcd_cert_dns_names}"]
}

resource "tls_locally_signed_cert" "etcd_client" {
  count = "${!var.experimental_enabled && var.etcd_tls_enabled ? 1 : 0}"

  cert_request_pem = "${tls_cert_request.etcd_client.cert_request_pem}"

  ca_key_algorithm   = "${join(" ", tls_self_signed_cert.etcd-ca.*.key_algorithm)}"
  ca_private_key_pem = "${join(" ", tls_private_key.etcd-ca.*.private_key_pem)}"
  ca_cert_pem        = "${join(" ", tls_self_signed_cert.etcd-ca.*.cert_pem)}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

resource "tls_private_key" "etcd_peer" {
  count = "${!var.experimental_enabled && var.etcd_tls_enabled ? 1 : 0}"

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "etcd_peer" {
  count = "${!var.experimental_enabled && var.etcd_tls_enabled ? 1 : 0}"

  key_algorithm   = "${tls_private_key.etcd_peer.algorithm}"
  private_key_pem = "${tls_private_key.etcd_peer.private_key_pem}"

  subject {
    common_name  = "etcd"
    organization = "etcd"
  }

  dns_names = ["${var.etcd_cert_dns_names}"]
}

resource "tls_locally_signed_cert" "etcd_peer" {
  count = "${!var.experimental_enabled && var.etcd_tls_enabled ? 1 : 0}"

  cert_request_pem = "${tls_cert_request.etcd_peer.cert_request_pem}"

  ca_key_algorithm   = "${join(" ", tls_self_signed_cert.etcd-ca.*.key_algorithm)}"
  ca_private_key_pem = "${join(" ", tls_private_key.etcd-ca.*.private_key_pem)}"
  ca_cert_pem        = "${join(" ", tls_self_signed_cert.etcd-ca.*.cert_pem)}"

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}
