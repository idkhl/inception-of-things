#!/bin/sh

apt update -y
apt-get install -y curl

curl -sfL https://get.k3s.io | sh -s - server \
  --write-kubeconfig-mode 644 \
  --node-ip 192.168.56.110 \
  --bind-address 192.168.56.110 \
  --flannel-iface eth1

sleep 15

sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token
