#!/bin/sh

# apt update -y

# NODE_TOKEN=$(cat /vagrant/node-token)

# curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="${NODE_TOKEN}" INSTALL_K3S_EXEC="agent --node-ip=192.168.56.111" sh -


apt-get update -y
apt-get install -y curl

NODE_TOKEN=$(cat /vagrant/node-token)

curl -sfL https://get.k3s.io | K3S_URL="https://192.168.56.110:6443" K3S_TOKEN="${NODE_TOKEN}" sh -s - agent \
  --node-ip 192.168.56.111 \
  --flannel-iface eth1