# Agent Mitra Deployment Guide

## Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04+ / CentOS 7+ / Docker
- **CPU**: 2+ cores
- **RAM**: 4GB+ minimum, 8GB+ recommended
- **Storage**: 20GB+ available space
- **Network**: Stable internet connection

### Required Software
```bash
# Docker and Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Git
sudo apt-get update && sudo apt-get install -y git

# Clone repository
git clone https://github.com/your-org/agentmitra.git
cd agentmitra
```

## Environment Configuration

### Production Environment Variables
Create `.env` file in the project root:

```bash
# Database Configuration
DB_PASSWORD=your_secure_db_password_here
POSTGRES_DB=agentmitra
POSTGRES_USER=agentmitra_user

# Redis Configuration
REDIS_PASSWORD=your_secure_redis_password_here

# JWT Configuration
JWT_SECRET_KEY=your_256_bit_secret_key_here

# CORS Configuration
CORS_ORIGINS=https://yourdomain.com,https://app.yourdomain.com

# Monitoring
GRAFANA_PASSWORD=your_secure_grafana_password_here

# SSL/TLS (if using HTTPS)
SSL_CERT_PATH=/etc/ssl/certs/agentmitra.crt
SSL_KEY_PATH=/etc/ssl/private/agentmitra.key
```

### SSL Certificate Setup
```bash
# Using Let's Encrypt (recommended)
sudo apt-get install certbot
sudo certbot certonly --standalone -d yourdomain.com

# Copy certificates
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem /etc/ssl/certs/
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem /etc/ssl/private/
```

## Deployment Options

### Option 1: Docker Compose (Recommended)

1. **Quick Start**
```bash
# Clone and setup
git clone https://github.com/your-org/agentmitra.git
cd agentmitra

# Configure environment
cp .env.example .env
# Edit .env with your values

# Deploy
docker-compose -f docker-compose.prod.yml up -d

# Check status
docker-compose -f docker-compose.prod.yml ps
docker-compose -f docker-compose.prod.yml logs -f
```

2. **Verify Deployment**
```bash
# Health checks
curl -f http://localhost/health
curl -f http://localhost/api/v1/health

# Application access
# Frontend: http://localhost/portal/
# API: http://localhost/api/v1/
# Monitoring: http://localhost:3012 (admin/admin)
```

### Option 2: Manual Installation

1. **Backend Setup**
```bash
# Install Python dependencies
cd backend
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Setup database
sudo -u postgres createdb agentmitra
sudo -u postgres createuser agentmitra_user
sudo -u postgres psql -c "ALTER USER agentmitra_user PASSWORD 'your_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE agentmitra TO agentmitra_user;"

# Run migrations
python manage.py migrate

# Start backend
python main.py
```

2. **Frontend Setup**
```bash
# Install Node.js dependencies
cd config-portal
npm install

# Build for production
npm run build

# Serve with nginx
sudo cp -r build/* /var/www/html/
```

## Production Optimization

### Nginx Configuration
```nginx
# /etc/nginx/sites-available/agentmitra
server {
    listen 80;
    server_name yourdomain.com;

    # SSL configuration
    listen 443 ssl http2;
    ssl_certificate /etc/ssl/certs/agentmitra.crt;
    ssl_certificate_key /etc/ssl/private/agentmitra.key;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";

    # API proxy
    location /api/ {
        proxy_pass http://localhost:8012;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Frontend
    location / {
        root /var/www/html;
        try_files $uri $uri/ /index.html;
    }
}
```

### Systemd Services
Create service files for production reliability:

```bash
# /etc/systemd/system/agentmitra-backend.service
[Unit]
Description=Agent Mitra Backend
After=network.target postgresql.service redis.service

[Service]
Type=simple
User=agentmitra
Group=agentmitra
WorkingDirectory=/opt/agentmitra/backend
Environment=PATH=/opt/agentmitra/backend/venv/bin
ExecStart=/opt/agentmitra/backend/venv/bin/python main.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

### Log Rotation
```bash
# /etc/logrotate.d/agentmitra
/opt/agentmitra/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 agentmitra agentmitra
    postrotate
        systemctl reload agentmitra-backend
    endscript
}
```

## Backup Strategy

### Automated Backups
```bash
#!/bin/bash
# /opt/agentmitra/scripts/backup.sh

BACKUP_DIR="/opt/backups/agentmitra"
DATE=$(date +%Y%m%d_%H%M%S)

# Database backup
docker-compose -f docker-compose.prod.yml exec -T postgres pg_dump -U agentmitra_user agentmitra > $BACKUP_DIR/db_$DATE.sql

# Configuration backup
tar -czf $BACKUP_DIR/config_$DATE.tar.gz /opt/agentmitra/.env /opt/agentmitra/nginx/

# Compress and cleanup
gzip $BACKUP_DIR/db_$DATE.sql
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete
```

### Restore Procedure
```bash
# Stop services
docker-compose -f docker-compose.prod.yml down

# Restore database
docker-compose -f docker-compose.prod.yml exec -T postgres psql -U agentmitra_user agentmitra < backup.sql

# Restore configuration
tar -xzf config_backup.tar.gz -C /

# Start services
docker-compose -f docker-compose.prod.yml up -d
```

## Monitoring Setup

### Prometheus Configuration
```yaml
# /opt/monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'agentmitra-backend'
    static_configs:
      - targets: ['localhost:8012']
    scrape_interval: 5s
    metrics_path: '/metrics'

  - job_name: 'nginx'
    static_configs:
      - targets: ['localhost:80']
```

### Grafana Dashboards
1. Access Grafana at http://your-server:3012
2. Import dashboard templates from `monitoring/grafana/dashboards/`
3. Configure data sources for Prometheus

### Alert Rules
```yaml
# /opt/monitoring/alert_rules.yml
groups:
  - name: agentmitra
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
```

## Security Hardening

### Firewall Configuration
```bash
# UFW configuration
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable
```

### SSL/TLS Configuration
```nginx
# Strong SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;
```

### Fail2Ban Setup
```bash
# Install and configure
sudo apt-get install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Custom jail for Agent Mitra
sudo tee /etc/fail2ban/jail.d/agentmitra.conf > /dev/null <<EOF
[agentmitra]
enabled = true
port = http,https
filter = agentmitra
logpath = /var/log/nginx/access.log
maxretry = 3
bantime = 86400
EOF
```

## Performance Tuning

### Database Optimization
```sql
-- Performance indexes
CREATE INDEX CONCURRENTLY idx_policies_agent_id ON policies(agent_id);
CREATE INDEX CONCURRENTLY idx_policies_status ON policies(status);
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Query optimization
ALTER TABLE policies SET (autovacuum_vacuum_scale_factor = 0.02);
ALTER TABLE users SET (autovacuum_analyze_scale_factor = 0.01);
```

### Cache Configuration
```bash
# Redis optimization
# /etc/redis/redis.conf
maxmemory 512mb
maxmemory-policy allkeys-lru
tcp-keepalive 300
```

### System Tuning
```bash
# /etc/sysctl.conf
net.core.somaxconn = 1024
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.ip_local_port_range = 1024 65535
```

## Scaling Strategies

### Horizontal Scaling
```bash
# Multiple backend instances
docker-compose -f docker-compose.prod.yml up -d --scale backend=3

# Load balancer configuration
upstream backend {
    server backend1:8012;
    server backend2:8012;
    server backend3:8012;
}
```

### Database Scaling
```bash
# Read replicas
# Configure PostgreSQL streaming replication
# Update application to use read replicas for SELECT queries
```

## Troubleshooting

### Common Issues

1. **Backend won't start**
```bash
# Check logs
docker-compose -f docker-compose.prod.yml logs backend

# Check database connectivity
docker-compose -f docker-compose.prod.yml exec backend python -c "import psycopg2; psycopg2.connect('postgresql://...')"
```

2. **Frontend not loading**
```bash
# Check nginx configuration
sudo nginx -t

# Check static files
ls -la /var/www/html/

# Check browser console for errors
```

3. **Slow performance**
```bash
# Check system resources
top
iotop
iostat -x 1

# Check database performance
docker-compose -f docker-compose.prod.yml exec postgres psql -c "SELECT * FROM pg_stat_activity;"

# Check cache hit rates
docker-compose -f docker-compose.prod.yml exec redis redis-cli info stats
```

## Maintenance Schedule

### Daily Tasks
- [ ] Monitor error rates and performance metrics
- [ ] Review application logs for anomalies
- [ ] Check disk space usage
- [ ] Verify backup completion

### Weekly Tasks
- [ ] Update system packages
- [ ] Rotate and archive logs
- [ ] Review security alerts
- [ ] Performance optimization review

### Monthly Tasks
- [ ] Full system backup verification
- [ ] Security vulnerability assessment
- [ ] Database maintenance (VACUUM, REINDEX)
- [ ] Certificate renewal check

### Quarterly Tasks
- [ ] Major version updates
- [ ] Security audit
- [ ] Performance benchmarking
- [ ] Disaster recovery testing

---

This deployment guide should be updated as the system evolves. Always test deployments in a staging environment before production deployment.
