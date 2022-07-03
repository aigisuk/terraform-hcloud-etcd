#!/bin/bash

mkdir /tmp/etcd && cd /tmp/etcd
curl -sL -o etcd-v${etcd_version}-linux-amd64.tar.gz  https://github.com/etcd-io/etcd/releases/download/v${etcd_version}/etcd-v${etcd_version}-linux-amd64.tar.gz

tar -xvf etcd-v${etcd_version}-linux-amd64.tar.gz
mv etcd-v${etcd_version}-linux-amd64/etcd* /usr/local/bin/

groupadd --system etcd
useradd -s /sbin/nologin --system -g etcd etcd
mkdir -p /etc/etcd /var/lib/etcd
chown -R etcd:etcd /var/lib/etcd/
chmod -R 700 /var/lib/etcd/

etcdctl --endpoints=${init_node_ip}:2379 member add ${node_hostname} --peer-urls=http://${node_ip}:2380

cat << EOF > /lib/systemd/system/etcd.service
[Unit]
Description=etcd service
Documentation=https://github.com/coreos/etcd

[Service]
User=etcd
Type=notify
ExecStart=/usr/local/bin/etcd \\
 --name ${node_hostname} \\
 --data-dir /var/lib/etcd \\
 --initial-advertise-peer-urls http://${node_ip}:2380 \\
 --listen-peer-urls http://${node_ip}:2380 \\
 --listen-client-urls http://${node_ip}:2379,http://127.0.0.1:2379 \\
 --advertise-client-urls http://${node_ip}:2379 \\
 --initial-cluster-token etcd-cluster-0 \\
 --initial-cluster ${cluster_members} \\
 --initial-cluster-state existing \\
 --heartbeat-interval 1000 \\
 --election-timeout 5000
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable etcd
systemctl start etcd.service