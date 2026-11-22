#!/bin/bash
# WireGuard server setup on RHEL (run as a user with sudo).
# Step-by-step reference for the lab; review before running.
set -e

# 1. Install tools
sudo dnf install -y wireguard-tools

# 2. Generate the server key pair (private key readable by root only)
umask 077
mkdir -p ~/wireguard && cd ~/wireguard
wg genkey | tee server_private.key | wg pubkey > server_public.key

# 3. Create /etc/wireguard/wg0.conf from configs/server-wg0.conf
#    (paste server_private.key and the client's public key)
sudo chmod 600 /etc/wireguard/wg0.conf

# 4. Enable IP forwarding (persistent)
echo "net.ipv4.ip_forward = 1" | sudo tee /etc/sysctl.d/99-wireguard.conf
sudo sysctl --system

# 5. firewalld: custom zone with UDP 51820 and masquerading
sudo firewall-cmd --permanent --new-zone=webzone || true
sudo firewall-cmd --permanent --zone=webzone --add-interface=wg0
sudo firewall-cmd --permanent --zone=webzone --add-port=51820/udp
sudo firewall-cmd --permanent --zone=webzone --add-masquerade
sudo firewall-cmd --permanent --add-port=51820/udp     # on the LAN-facing zone
sudo firewall-cmd --reload

# 6. Start the tunnel and enable it at boot
sudo systemctl enable --now wg-quick@wg0
sudo systemctl is-enabled wg-quick@wg0

# 7. Verify
sudo wg
