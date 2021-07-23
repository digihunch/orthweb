data "local_file" "pubkey" {
  filename = pathexpand(var.local_pubkey_file)
}
