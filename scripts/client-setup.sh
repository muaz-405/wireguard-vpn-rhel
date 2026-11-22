#!/bin/bash
# WireGuard client setup on RHEL (client-vm). Review before running.
set -e

sudo dnf install -y wireguard-tools

umask 077
mkdir -p ~/wireguard && cd ~/wireguard
wg genkey | tee client_private.key | wg pubkey > client_public.key

# Create /etc/wireguard/wg0.conf from configs/client-wg0.conf
# (paste client_private.key and the server's public key)
sudo chmod 600 /etc/wireguard/wg0.conf

sudo systemctl enable --now wg-quick@wg0

# Verify: handshake + reach the server over the tunnel
sudo wg
ping -c 4 10.0.0.1
