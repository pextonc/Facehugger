#!/bin/bash
set -Eeuo pipefail
echo
if [[ "$EUID" -ne 0 ]]; then
    echo "ERROR: Run this script with sudo or as root."
    exit 1
fi
echo
echo "This script is intended ONLY for fresh Ubuntu images."
echo "It installs OpenSSH-Server and configures inbound SSH on a chosen port."
echo "Root SSH login will be disabled."
echo
echo "Ensure you have console access and can recover the machine"
echo "if SSH connectivity fails."
echo
echo "If you wish to continue, press ENTER. Otherwise CTRL+C"
read -r
echo
echo "Installing OpenSSH-Server..."
apt-get update
apt-get install -y openssh-server
echo
echo "OpenSSH version:"
sshd -V 2>&1 || true
echo
echo
echo "Preparing SSH runtime directory..."
install -d -m 0755 -o root -g root /run/sshd
echo
read -r -p "Enter new SSH port (1-65535): " SSH_PORT
if [[ ! "$SSH_PORT" =~ ^[0-9]+$ ]] ||
   (( 10#$SSH_PORT < 1 || 10#$SSH_PORT > 65535 )); then
    echo "ERROR: Invalid port."
    exit 1
fi
SSH_PORT=$((10#$SSH_PORT))
CONFIG_DIR="/etc/ssh/sshd_config.d"
FACEHUGGER_CONFIG="$CONFIG_DIR/00-facehugger.conf"
if [[ ! -d "$CONFIG_DIR" ]]; then
    echo "ERROR: Expected Ubuntu SSH configuration directory not found."
    exit 1
fi
if [[ -e "$FACEHUGGER_CONFIG" ]]; then
    echo "ERROR: $FACEHUGGER_CONFIG already exists."
    echo "Cannot overwrite it."
    exit 1
fi
echo
echo "Configuring SSH on port $SSH_PORT..."
echo
cat > "$FACEHUGGER_CONFIG" <<EOF
Port $SSH_PORT
PermitRootLogin no
EOF
chmod 644 "$FACEHUGGER_CONFIG"
echo "Validating SSH configuration..."
if ! sshd -t; then
    echo "ERROR: Configuration validation failed."
    rm -f "$FACEHUGGER_CONFIG"
    exit 1
fi
echo
echo "The configuration is valid."
echo "Ensure TCP port $SSH_PORT is allowed by your firewall"
echo
read -r -p "Enable and restart SSH now? [y/N]: " ANSWER
if [[ ! "$ANSWER" =~ ^[Yy]$ ]]; then
    echo "Not applied. Removing the proposed config"
    rm -f "$FACEHUGGER_CONFIG"
    exit 0
fi
echo
echo
echo "Enabling and restarting SSH..."
if ! systemctl enable ssh ||
   ! systemctl restart ssh; then
    echo "ERROR: SSH service failed to start with the new configuration."
    echo "Removing Facehugger config..."
    rm -f "$FACEHUGGER_CONFIG"
    if sshd -t; then
        systemctl restart ssh || true
    fi
    exit 1
fi
echo
echo "Verifying SSH listener..."
if ss -ltnH | awk -v port=":$SSH_PORT" \
    '$4 ~ port "$" { found=1 } END { exit !found }'; then
    echo "SSH is listening on port $SSH_PORT."
else
    echo "ERROR: SSH is not listening on port $SSH_PORT."
    systemctl status ssh --no-pager || true
    exit 1
fi
echo
echo "===================================================="
echo " SSH server configured"
echo " Listening port: $SSH_PORT"
echo " Root SSH login: disabled"
echo
echo "Connect from your workstation using:"
echo " ssh -p $SSH_PORT USER@SERVER_IP"
echo
echo "Verify connectivity before closing this console."
echo "===================================================="
