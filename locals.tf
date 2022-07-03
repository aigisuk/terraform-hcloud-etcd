locals {
  etcd_label = "etcd"

  cluster_ips = [
    for i in range(var.node_count) : format("http://%s:2380", cidrhost(hcloud_network_subnet.etcd_net.ip_range, (20 + i)))
  ]

  node_names = [
    for i in range(var.node_count) : format("etcd-node-%s", ("${i}-${var.location}-${random_id.etcd_node_id[i].hex}"))
  ]

  cluster_members = join(",", [
    for i in range(var.node_count) : format("%s", ("${element(local.node_names, i)}=${element(local.cluster_ips, i)}"))
  ])
}