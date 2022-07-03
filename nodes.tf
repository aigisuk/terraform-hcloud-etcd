resource "hcloud_placement_group" "etcd_placement_group" {
  name = "etcd-node-placement-group"
  type = "spread"
}

# Create etcd nodes
resource "hcloud_server" "etcd_node" {
  count              = var.node_count
  name               = "etcd-node-${count.index}-${var.location}-${random_id.etcd_node_id[count.index].hex}"
  image              = "ubuntu-22.04"
  server_type        = "cx11"
  placement_group_id = hcloud_placement_group.etcd_placement_group.id
  location           = var.location
  ssh_keys           = [var.ssh_public_key_name]
  labels = {
    provisioner = "terraform",
    type        = local.etcd_label
  }
  # Prevent destruction of the entire cluster in the case of changes to any attributes
  # that force recreation of server or network ip's/mac addresses.
  lifecycle {
    ignore_changes = [
      location,
      network,
      ssh_keys,
      user_data,
    ]
  }
  network {
    network_id = hcloud_network.etcd_net.id
    ip         = cidrhost(hcloud_network_subnet.etcd_net.ip_range, (20 + count.index))
  }
  user_data = templatefile("${path.module}/user_data/etcd.yaml.tftpl", {
    install_script = base64gzip(templatefile("${path.module}/user_data/install_etcd.sh", {
      etcd_version    = var.etcd_version
      cluster_members = local.cluster_members
      node_hostname   = "etcd-node-${count.index}-${var.location}-${random_id.etcd_node_id[count.index].hex}"
      node_ip         = cidrhost(hcloud_network_subnet.etcd_net.ip_range, (20 + count.index))
      }))
  })
}
