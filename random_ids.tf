resource "random_id" "etcd_node_id" {
  byte_length = 2
  count       = var.node_count
}