locals {
  nva_script = "${path.module}/scripts/setup_nva.sh"
}

# ── SSH Key ────────────────────────────────────────────
resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}
