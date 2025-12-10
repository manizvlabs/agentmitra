#!/bin/bash
# User Data script for AWS Lightsail instance
# This script runs on first boot to set up the Agent Mitra sandbox environment

set -e

# Update system
apt update && apt upgrade -y

# Install required packages
apt install -y \
    curl \
    wget \
    git \
    docker.io \
    docker-compose \
    nginx \
    certbot \
    python3-certbot-nginx \
    postgresql-client \
    redis-tools \
    awscli \
    jq \
    unzip \
    build-essential

# Install Node.js (for Firebase CLI if needed)
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Install Firebase CLI
npm install -g firebase-tools

# Install Flutter (optional - for building on server)
# wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.13.0-stable.tar.xz
# tar xf flutter_linux_3.13.0-stable.tar.xz -C /opt/
# export PATH="$PATH:/opt/flutter/bin"
# flutter config --no-analytics

# Create application directory
mkdir -p /opt/agentmitra
cd /opt/agentmitra

# Clone repository (replace with your repo URL)
# git clone https://github.com/yourusername/agentmitra.git .
# cd agentmitra

# Create necessary directories
mkdir -p logs/sandbox
mkdir -p monitoring/prometheus
mkdir -p monitoring/grafana/provisioning
mkdir -p monitoring/grafana/dashboards
mkdir -p nginx/ssl
mkdir -p uploads/temp
mkdir -p uploads/video_processing

# Set up Docker
systemctl enable docker
systemctl start docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Configure Nginx
cp /opt/agentmitra/nginx/sandbox.nginx.conf /etc/nginx/nginx.conf
nginx -t
systemctl enable nginx
systemctl start nginx

# Set up log rotation
cat > /etc/logrotate.d/agentmitra << EOF
/opt/agentmitra/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 644 ubuntu ubuntu
    postrotate
        docker-compose -f /opt/agentmitra/docker-compose.sandbox.yml logs -f > /dev/null 2>&1 || true
    endscript
}
EOF

# Set up monitoring (optional)
# Install Node Exporter for system monitoring
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
tar xvf node_exporter-1.6.0.linux-amd64.tar.gz
mv node_exporter-1.6.0.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-1.6.0.linux-amd64*

# Create systemd service for Node Exporter
cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=ubuntu
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable node_exporter
systemctl start node_exporter

# Set up automatic updates
cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}";
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}:\${distro_codename}-updates";
};
Unattended-Upgrade::Package-Blacklist {
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::InstallOnShutdown "false";
Unattended-Upgrade::Mail "root";
Unattended-Upgrade::MailOnlyOnError "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF

# Enable automatic updates
systemctl enable unattended-upgrades
systemctl start unattended-upgrades

# Set up firewall (UFW)
ufw --force enable
ufw allow ssh
ufw allow http
ufw allow https
ufw allow 8012

# Create deployment script
cat > /opt/agentmitra/deploy.sh << 'EOF'
#!/bin/bash
set -e

echo "Deploying Agent Mitra Sandbox..."

# Navigate to application directory
cd /opt/agentmitra

# Pull latest changes (if using git)
# git pull origin main

# Copy environment file if it exists
if [ -f ".env.sandbox" ]; then
    cp .env.sandbox .env
fi

# Build and start services
docker-compose -f docker-compose.sandbox.yml down || true
docker-compose -f docker-compose.sandbox.yml up -d --build

# Wait for services to be healthy
echo "Waiting for services to start..."
sleep 30

# Run health checks
if curl -f http://localhost:8012/health > /dev/null 2>&1; then
    echo "✓ Backend is healthy"
else
    echo "✗ Backend health check failed"
fi

if curl -f http://localhost/health > /dev/null 2>&1; then
    echo "✓ Application is healthy"
else
    echo "✗ Application health check failed"
fi

echo "Deployment complete!"
EOF

chmod +x /opt/agentmitra/deploy.sh

# Set up cron job for log rotation
echo "0 2 * * * /usr/sbin/logrotate /etc/logrotate.d/agentmitra" | crontab -

# Clean up
apt autoremove -y
apt autoclean -y

# Final message
cat > /home/ubuntu/README.md << 'EOF'
# Agent Mitra Sandbox Server

This server has been configured for the Agent Mitra sandbox environment.

## Services Running:
- Nginx (ports 80, 443)
- Docker & Docker Compose
- Node Exporter (port 9100) - for monitoring
- Automatic updates enabled

## Application Directory:
/opt/agentmitra

## Deployment:
cd /opt/agentmitra
sudo ./deploy.sh

## Logs:
/opt/agentmitra/logs/

## Monitoring:
- Prometheus: http://localhost:9090 (if running)
- Grafana: http://localhost:3001 (if running)
- Node Exporter metrics: http://localhost:9100/metrics

## Useful Commands:
- View Docker containers: docker ps
- View application logs: docker-compose -f docker-compose.sandbox.yml logs -f
- Restart services: docker-compose -f docker-compose.sandbox.yml restart
- Update application: cd /opt/agentmitra && sudo ./deploy.sh

## Security Notes:
- SSH access is enabled (consider restricting IP ranges)
- UFW firewall is configured
- Automatic security updates are enabled
EOF

# Set proper permissions
chown -R ubuntu:ubuntu /opt/agentmitra
chown -R ubuntu:ubuntu /home/ubuntu

echo "Agent Mitra sandbox server setup complete!" > /var/log/agentmitra-setup.log
date >> /var/log/agentmitra-setup.log
