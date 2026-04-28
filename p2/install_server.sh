#!/bin/sh

apt update -y
apt-get install -y curl

curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --bind-address=192.168.56.110" sh -

sleep 5

sudo cat /var/lib/rancher/k3s/server/node-token > /vagrant/node-token
