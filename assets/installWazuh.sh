#!/bin/bash

# Wazuh Installation Script for Ubuntu VM (All-in-One: Wazuh Manager + Indexer + Dashboard)
# Make sure to run as sudo or with root privileges

set -e  # Exit on any error

echo "🔍 Updating system packages..."
if ! apt update && apt upgrade -y; then
    echo "❌ Failed to update system packages."
    exit 1
fi

echo "🔧 Installing required dependencies..."
if ! apt install curl apt-transport-https lsb-release gnupg ufw -y; then
    echo "❌ Failed to install dependencies."
    exit 1
fi

echo "🔑 Adding Wazuh GPG key and repository..."
if ! curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg; then
    echo "❌ Failed to add Wazuh GPG key."
    exit 1
fi

if ! echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list; then
    echo "❌ Failed to add Wazuh repository."
    exit 1
fi

echo "🔄 Updating repositories..."
if ! apt update; then
    echo "❌ Failed to update repositories."
    exit 1
fi

echo "📦 Installing Wazuh Manager, Indexer, and Dashboard..."
if ! apt install wazuh-manager wazuh-indexer wazuh-dashboard -y; then
    echo "❌ Failed to install Wazuh components."
    exit 1
fi

echo "🚀 Enabling and starting Wazuh services..."
systemctl daemon-reload
systemctl enable wazuh-manager wazuh-indexer wazuh-dashboard
systemctl start wazuh-manager wazuh-indexer wazuh-dashboard

echo "🔒 Retrieving Wazuh Dashboard credentials..."
if ! DASHBOARD_PASS=$(cat /var/lib/wazuh-dashboard/data/wazuh-passwords.txt); then
    echo "❌ Failed to retrieve Wazuh Dashboard password."
    exit 1
fi

echo "🌐 Configuring UFW firewall..."
if ! ufw allow OpenSSH; then
    echo "❌ Failed to allow OpenSSH (port 22)."
    exit 1
fi
if ! ufw allow 5601/tcp; then
    echo "❌ Failed to allow Wazuh Dashboard (5601)."
    exit 1
fi
if ! ufw allow 1514/udp; then
    echo "❌ Failed to allow Wazuh Agent (1514/UDP)."
    exit 1
fi
if ! ufw allow 1515/tcp; then
    echo "❌ Failed to allow Wazuh Agent (1515/TCP)."
    exit 1
fi
echo "y" | ufw enable || true  # Enable UFW without interruption

echo "✅ Wazuh installation and firewall configuration complete!"
echo "🌐 Access the Wazuh Dashboard at: https://$(hostname -I | awk '{print $1}'):5601"
echo "🧑 Default user: admin"
echo "🔑 Default password: $DASHBOARD_PASS"
