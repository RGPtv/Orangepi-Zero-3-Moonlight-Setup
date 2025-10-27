#!/bin/bash
#===============================================================
# Moonlight + WireGuard Setup Script for Orange Pi (Armbian)
#===============================================================
# Author: Rizz Gerald Pacalda
# Description:
#   This script installs Moonlight-qt and optionally WireGuard
#   for remote game streaming on Orange Pi.
#===============================================================

set -euo pipefail  # safer combined form

#---------------------------------------------------------------
# Helper functions
#---------------------------------------------------------------
log() {
    echo -e "\e[1;32m[INFO]\e[0m $1"
}

error_exit() {
    echo -e "\e[1;31m[ERROR]\e[0m $1" >&2
    exit 1
}

#---------------------------------------------------------------
# Pre-flight checks
#---------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
   error_exit "Please run this script as root (use: sudo bash $0)"
fi

log "Updating and Upgrading package list..."
apt update -y
apt upgrade -y

#---------------------------------------------------------------
# OPTION 1: Install Moonlight-qt only
#---------------------------------------------------------------
log "Installing Moonlight-qt and dependencies..."
curl -fsSL 'https://dl.cloudsmith.io/public/moonlight-game-streaming/moonlight-qt/setup.deb.sh' | bash
apt install -y moonlight-qt qt6-base-dev qt6-multimedia-dev qt6-declarative-dev alsa-ucm-conf

#---------------------------------------------------------------
# Install custom ALSA configuration
#---------------------------------------------------------------
log "Installing ALSA asound.conf..."
curl -fsSL -o /etc/asound.conf https://raw.githubusercontent.com/RGPtv/Orangepi-Zero-3-Moonlight-Setup/refs/heads/main/asound.conf || \
    error_exit "Failed to download /etc/asound.conf"

#---------------------------------------------------------------
# Apply EGLFS environment variable
#---------------------------------------------------------------
log "Applying EGLFS environment configuration..."
if ! grep -Fxq "export QT_QPA_PLATFORM=eglfs" ~/.bashrc; then
    echo 'export QT_QPA_PLATFORM=eglfs' >> ~/.bashrc
fi
export QT_QPA_PLATFORM=eglfs

#---------------------------------------------------------------
# OPTION 2: (Optional) Install WireGuard for streaming anywhere
#---------------------------------------------------------------
read -rp "Do you want to install WireGuard for remote streaming? [y/N]: " install_wg
if [[ "$install_wg" =~ ^[Yy]$ ]]; then
    log "Installing WireGuard and dependencies..."
    apt install -y network-manager wireguard iptables

    read -rp "Enter your WireGuard config URL: " wg_url
    if [[ -z "$wg_url" ]]; then
        error_exit "WireGuard config URL cannot be empty."
    fi

    read -rp "Enter your WireGuard config name (no spaces): " wg_name
    if [[ -z "$wg_name" ]]; then
        error_exit "WireGuard config name cannot be empty."
    fi

    mkdir -p /etc/wireguard
    curl -fsSL -o "/etc/wireguard/${wg_name}.conf" "$wg_url" || error_exit "Failed to download WireGuard config."
    chmod 600 "/etc/wireguard/${wg_name}.conf"

    systemctl enable "wg-quick@${wg_name}"
    systemctl start "wg-quick@${wg_name}"

    log "WireGuard installed and started successfully."
fi

#---------------------------------------------------------------
# System update and cleanup
#---------------------------------------------------------------
log "Cleaning up..."
apt update -y
apt upgrade -y
apt autoremove -y
apt clean

#---------------------------------------------------------------
# Final message
#---------------------------------------------------------------
log "Installation complete! Please reboot your Orange Pi now."
echo "Run: sudo reboot"
