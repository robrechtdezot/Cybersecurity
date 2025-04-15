#!/bin/bash

# Advanced anonymity setup for Kali Linux
# ⚠️ Run this script as root

IFACE="wlan0"  # or eth0 - check with `ip a`
NEW_HOSTNAME="anon-$(tr -dc a-z0-9 </dev/urandom | head -c 8)"
DNS_SERVER="127.0.0.1"  # For dnscrypt-proxy
TIMEZONE="UTC"
LOCALE="en_US.UTF-8"

echo "[*] Changing hostname..."
hostnamectl set-hostname "$NEW_HOSTNAME"

echo "[*] Spoofing MAC..."
ip link set "$IFACE" down
macchanger -r "$IFACE"
ip link set "$IFACE" up

echo "[*] Setting timezone and locale..."
timedatectl set-timezone "$TIMEZONE"
export LANG=$LOCALE
export LC_ALL=$LOCALE

echo "[*] Overriding DNS (temporary)..."
echo "nameserver $DNS_SERVER" > /etc/resolv.conf

echo "[*] Disabling risky services..."
systemctl disable --now avahi-daemon cups bluetooth

echo "[*] Flushing old logs and bash history..."
history -c
rm -rf ~/.bash_history /tmp/* /var/tmp/* ~/.cache/*

echo "[*] Activating strict firewall rules..."
ufw --force reset
ufw default deny outgoing
ufw default deny incoming
ufw allow out on "$IFACE"
ufw enable

echo "[*] Done. Tor and VPN should now be used manually."