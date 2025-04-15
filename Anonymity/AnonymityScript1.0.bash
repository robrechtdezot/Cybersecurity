#!/bin/bash

# Anonymity hardening script for Kali Linux
# Run as root. Use responsibly.

# ─── CONFIG ────────────────────────────────────────────────
IFACE="wlan0"  # change to your interface (use `ip a` to list)
NEW_HOSTNAME="anon-$(tr -dc a-z0-9 </dev/urandom | head -c 6)"
DNS_SERVER="1.1.1.1"  # Use DoH if you can later

# ─── SPOOF HOSTNAME ────────────────────────────────────────
echo "[*] Changing hostname to $NEW_HOSTNAME..."
hostnamectl set-hostname "$NEW_HOSTNAME"

# ─── SPOOF MAC ADDRESS ─────────────────────────────────────
echo "[*] Spoofing MAC address on $IFACE..."
ip link set "$IFACE" down
macchanger -r "$IFACE"
ip link set "$IFACE" up

# ─── SPOOF TIMEZONE AND LOCALE ─────────────────────────────
echo "[*] Spoofing timezone to UTC and locale to en_US..."
timedatectl set-timezone UTC
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ─── SET CUSTOM DNS ────────────────────────────────────────
echo "[*] Setting custom DNS server..."
echo "nameserver $DNS_SERVER" > /etc/resolv.conf

# ─── DISABLE SERVICES ──────────────────────────────────────
echo "[*] Disabling unneeded services..."
systemctl disable --now avahi-daemon cups bluetooth

# ─── WIPE BASH HISTORY ─────────────────────────────────────
echo "[*] Clearing history and temp files..."
history -c
rm -rf ~/.bash_history /tmp/* /var/tmp/*

# ─── FIREWALL SETUP ────────────────────────────────────────
echo "[*] Setting default firewall to deny all outgoing..."
ufw default deny outgoing
ufw default deny incoming
ufw allow out on "$IFACE"
ufw enable

# ─── LOAD TOR + VPN (if installed manually) ────────────────
echo "[*] Start Tor and VPN if available..."
# systemctl start tor
# openvpn --config ~/your-config.ovpn &

# ─── FINAL MESSAGE ─────────────────────────────────────────
echo "[+] Anonymity prep complete. Proceed cautiously."
