locals {
  nva_script = "${path.module}/scripts/setup_nva.sh"
  standard_vm_script = "${path.module}/scripts/setup_standard.sh"
}

# ── SSH Key ────────────────────────────────────────────
resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}
