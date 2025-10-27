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
| Kernel | V4L2-request enabled (For hardware acceleration) |

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

---

## (OPTIONAL): Auto Launch Moonlight

### 1. Create a systemd service
```bash
sudo nano /etc/systemd/system/moonlight.service
```
### 2. Paste this example
```ini
[Unit]
Description=Moonlight Game Streaming Client
After=network-online.target

[Service]
User=root
ExecStart=/usr/bin/moonlight-qt
Restart=on-failure
Environment=DISPLAY=:0

[Install]
WantedBy=multi-user.target
```

### 3. Enable the service
```bash
sudo systemctl enable moonlight.service
```

### 4. Start it immediately
```bash
sudo systemctl start moonlight.service
```

---

## Example Interaction

```bash
Do you want to install WireGuard for remote streaming? [y/N]: y
Enter your WireGuard config URL: https://example.com/orangepi.conf
Enter your WireGuard config name (no spaces): orangepi
```

---

## Post-Installation

Once the installation is complete:
```bash
sudo reboot
```

### Useful Commands
| Task | Command |
|------|----------|
| Launch Moonlight | `moonlight-qt` |
| Verify WireGuard status | `wg` |
| Restart WireGuard interface | `systemctl restart wg-quick@orangepi` |

---

## Troubleshooting

| Issue | Cause / Resolution |
|-------|--------------------|
| **EGLFS display error** | Ensure HDMI is connected and `export QT_QPA_PLATFORM=eglfs` is present in `~/.bashrc`. |
| **No audio output** | Confirm that `/etc/asound.conf` exists and ALSA is properly installed. |
| **WireGuard fails to start** | Check `/etc/wireguard/<name>.conf` and ensure correct syntax. |
| **Script stops with `[ERROR]`** | The script intentionally halts on fatal errors. Review the last log line for details. |

---

## Maintenance and Updates

To update the system or reapply configuration:
```bash
sudo apt update && sudo apt upgrade -y
```

If the script repository has been updated, pull the latest changes:
```bash
cd Orangepi-Zero-3-Moonlight-Setup
git pull
```

---

## Acknowledgments

- [Moonlight Game Streaming Project](https://moonlight-stream.org/)  
- [WireGuard](https://www.wireguard.com/)  
- [Armbian](https://www.armbian.com/)  
- Special thanks to the open-source community for continuous support

---

> **Note:** This setup is optimized for Armbian running on Orange Pi Zero 3 but can be adapted to similar ARM-based single-board computers.
