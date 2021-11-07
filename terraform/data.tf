data "local_file" "pubkey_file" {
  filename = pathexpand(var.pubkey_path)
}
