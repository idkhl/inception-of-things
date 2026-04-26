#!/bin/sh
curl -sfL https://get.k3s.io | K3S_TOKEN="12345" INSTALL_K3S_EXEC="server --node-ip=192.168.56.110 --bind-address=192.168.56.110" sh -