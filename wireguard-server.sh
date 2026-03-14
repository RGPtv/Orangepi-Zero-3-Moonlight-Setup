#!/usr/bin/env bash
set -e

echo "Updating system..."
apt update
apt upgrade -y

echo "Installing required packages..."
apt install -y ca-certificates curl gnupg

echo "Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo "Adding Docker repository..."
ARCH=$(dpkg --print-architecture)
CODENAME=$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")

cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$ARCH signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable
EOF

echo "Installing Docker..."
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable docker
systemctl start docker

echo "Creating wg-easy directory..."
mkdir -p /etc/docker/containers/wg-easy
cd /etc/docker/containers/wg-easy

echo "Creating docker-compose.yml..."
cat > docker-compose.yml <<'EOF'
volumes:
  etc_wireguard:

services:
  wg-easy:
    image: ghcr.io/wg-easy/wg-easy:15
    container_name: wg-easy

    environment:
      - INSECURE=false
      # - PORT=51821
      # - HOST=0.0.0.0

    networks:
      wg:
        ipv4_address: 10.42.42.42
        ipv6_address: fdcc:ad94:bacf:61a3::2a

    volumes:
      - etc_wireguard:/etc/wireguard
      - /lib/modules:/lib/modules:ro

    ports:
      - "51820:51820/udp"
      - "51821:51821/tcp"

    restart: unless-stopped

    cap_add:
      - NET_ADMIN
      - SYS_MODULE

    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
      - net.ipv6.conf.all.disable_ipv6=0
      - net.ipv6.conf.all.forwarding=1
      - net.ipv6.conf.default.forwarding=1

networks:
  wg:
    driver: bridge
    enable_ipv6: true
    ipam:
      config:
        - subnet: 10.42.42.0/24
        - subnet: fdcc:ad94:bacf:61a3::/64
EOF

echo "Starting wg-easy container..."
docker compose up -d

echo "Setup complete!"
echo "Access wg-easy at: http://SERVER-IP:51821"
