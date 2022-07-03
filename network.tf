resource "hcloud_network" "etcd_net" {
  name     = "etcd-net-01"
  ip_range = var.etcd_network_range
  labels = {
    "type" = "cluster"
  }
}

resource "hcloud_network_subnet" "etcd_net" {
  network_id   = hcloud_network.etcd_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.1.0.0/16"
}