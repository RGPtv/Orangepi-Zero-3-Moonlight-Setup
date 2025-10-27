# Moonlight + WireGuard Setup for Orange Pi (Armbian)

A fully automated installation and configuration script for deploying **Moonlight-qt** (NVIDIA GameStream client) and **WireGuard VPN** on **Orange Pi** devices running **Armbian**.  
The setup enables both **local** and **remote** game streaming with optimized performance and minimal configuration.

---

## Overview

This script streamlines the following:

- Installation of **Moonlight-qt** and all required **Qt6** and **ALSA** components  
- Deployment of a verified **ASound configuration** for audio output  
- Environment setup for **EGLFS** (direct framebuffer rendering)  
- Optional installation and configuration of **WireGuard** for remote streaming over secure VPN  
- Full system update, cleanup, and service enablement  

---

## System Requirements

| Component | Requirement |
|------------|-------------|
| Hardware | Orange Pi Zero 3 (or compatible SBC) |
| OS | Armbian (Debian-based recommended) |
| Network | Active internet connection |
| Permissions | Root or sudo access |

---

## Installation Guide

### 1. Download the Repository
```bash
git clone https://github.com/RGPtv/Orangepi-Zero-3-Moonlight-Setup.git
cd Orangepi-Zero-3-Moonlight-Setup
```
### 2. Make the Script Executable
```bash
chmod +x setup.sh
```
### 3. Run the Installer
Execute the script as root:
```bash
sudo ./setup.sh
```
You will be prompted whether to install WireGuard for remote access.
