resource "hcloud_ssh_key" "default" {
  name       = var.ssh_public_key_name
  public_key = var.ssh_public_key
}