# Agent Mitra Production Operations Runbook

## Overview
This runbook provides comprehensive operational procedures for the Agent Mitra application suite, covering deployment, monitoring, troubleshooting, and maintenance tasks.

## System Architecture

### Components
- **Flutter Mobile App**: Cross-platform mobile application
- **React Configuration Portal**: Web-based agent configuration interface
- **Python Backend API**: FastAPI-based REST API with PostgreSQL
- **Nginx Reverse Proxy**: Load balancing and SSL termination
- **PostgreSQL Database**: Primary data storage
- **Redis Cache**: Session storage and caching
- **Prometheus + Grafana**: Monitoring and alerting

### Infrastructure Stack
- **Docker Compose**: Container orchestration for development/production
- **Nginx**: Reverse proxy and static file serving
- **PostgreSQL 16**: Relational database
- **Redis 7**: In-memory data store
- **Prometheus**: Metrics collection
- **Grafana**: Dashboard visualization

## Deployment Procedures

### Prerequisites
```bash
# Required tools
- Docker >= 20.10
- Docker Compose >= 2.0
- Node.js >= 18
- Python >= 3.11
- PostgreSQL client tools

# Environment variables
cp .env.example .env
# Edit .env with production values
```

### Production Deployment
```bash
# 1. Prepare environment
export COMPOSE_FILE=docker-compose.prod.yml

# 2. Deploy all services
docker-compose up -d

# 3. Run health checks
docker-compose ps
docker-compose logs -f --tail=100

# 4. Verify deployment
curl -f http://localhost/health
curl -f http://localhost/api/v1/health
curl -f http://localhost/portal/
```

### Rolling Updates
```bash
# Update specific service
docker-compose up -d backend

# Zero-downtime deployment
docker-compose up -d --scale backend=2
docker-compose up -d --scale backend=1
```

## Monitoring & Alerting

### Key Metrics to Monitor
- **API Response Time**: < 200ms average
- **Error Rate**: < 1% of total requests
- **Database Connections**: < 80% of max connections
- **Memory Usage**: < 85% of available RAM
- **Disk Usage**: < 90% of available space

### Health Check Endpoints
- `GET /health` - Overall system health
- `GET /api/v1/health` - Backend API health
- `GET /api/v1/health/database` - Database connectivity
- `GET /api/v1/health/system` - System resources

### Monitoring Dashboards
- **Grafana**: http://localhost:3012 (admin/admin)
- **Prometheus**: http://localhost:9012
- **Application Monitoring**: http://localhost/monitoring.html

## Troubleshooting Guide

### Backend Issues

#### High Response Times
```bash
# Check database performance
docker-compose exec postgres psql -U agentmitra_user -d agentmitra -c "SELECT * FROM pg_stat_activity;"

# Check Redis performance
docker-compose exec redis redis-cli info stats

# Review slow queries
docker-compose logs backend | grep "duration"
```

#### Memory Issues
```bash
# Check container resources
docker stats

# Review backend logs
docker-compose logs backend | grep "memory\|MemoryError"
```

#### Database Connection Issues
```bash
# Test database connectivity
docker-compose exec backend python -c "
import psycopg2
conn = psycopg2.connect('postgresql://agentmitra_user:password@postgres:5432/agentmitra')
print('Database connection successful')
"
```

### Frontend Issues

#### Portal Loading Issues
```bash
# Check portal container
docker-compose logs portal

# Verify static files
docker-compose exec portal ls -la /usr/share/nginx/html

# Test portal health
curl -I http://localhost/portal/
```

#### Mobile App Issues
```bash
# Check Flutter build logs
flutter build web --verbose

# Test API connectivity from mobile
# Use device developer tools to inspect network requests
```

### Infrastructure Issues

#### Container Health
```bash
# Check all container health
docker-compose ps

# Restart unhealthy containers
docker-compose restart <service_name>

# View detailed logs
docker-compose logs -f --tail=100 <service_name>
```

#### Network Issues
```bash
# Test inter-container connectivity
docker-compose exec backend ping postgres
docker-compose exec portal ping backend

# Check nginx configuration
docker-compose exec nginx nginx -t
```

## Maintenance Procedures

### Database Maintenance
```bash
# Backup database
docker-compose exec postgres pg_dump -U agentmitra_user agentmitra > backup_$(date +%Y%m%d).sql

# Vacuum and analyze
docker-compose exec postgres psql -U agentmitra_user -d agentmitra -c "VACUUM ANALYZE;"

# Check database size
docker-compose exec postgres psql -U agentmitra_user -d agentmitra -c "SELECT pg_size_pretty(pg_database_size('agentmitra'));"
```

### Log Management
```bash
# View application logs
docker-compose logs -f --tail=100 backend
docker-compose logs -f --tail=100 portal

# Archive old logs
find logs/ -name "*.log" -mtime +30 -exec gzip {} \;

# Clean old backups
find backups/ -name "*.sql.gz" -mtime +90 -delete
```

### Security Updates
```bash
# Update all containers
docker-compose pull

# Update with zero downtime
docker-compose up -d --no-deps backend
docker-compose up -d --no-deps portal

# Verify updates
docker-compose images
```

## Backup & Recovery

### Automated Backups
```bash
# Database backup script
#!/bin/bash
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)

docker-compose exec postgres pg_dump -U agentmitra_user agentmitra > $BACKUP_DIR/backup_$DATE.sql
gzip $BACKUP_DIR/backup_$DATE.sql

# Keep only last 30 days
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +30 -delete
```

### Recovery Procedures
```bash
# Restore database from backup
docker-compose exec -T postgres psql -U agentmitra_user agentmitra < backup_file.sql

# Restore configuration
cp backup_config/.env .env
cp backup_config/nginx.conf nginx/

# Restart services
docker-compose down
docker-compose up -d
```

## Performance Optimization

### Backend Optimization
- **Database Indexing**: Regular index maintenance
- **Query Optimization**: Monitor slow queries with EXPLAIN
- **Caching Strategy**: Redis for session and API response caching
- **Connection Pooling**: Optimize database connection limits

### Frontend Optimization
- **Bundle Splitting**: Code splitting for better loading
- **Image Optimization**: WebP format and lazy loading
- **Caching**: Service worker for offline functionality
- **CDN**: Static asset delivery optimization

### Infrastructure Optimization
- **Load Balancing**: Nginx upstream configuration
- **SSL/TLS**: Certificate management and renewal
- **Resource Limits**: Container memory and CPU limits
- **Auto-scaling**: Horizontal pod scaling when needed

## Incident Response

### Severity Levels
- **P0 - Critical**: System completely down, data loss
- **P1 - High**: Major functionality broken, significant user impact
- **P2 - Medium**: Minor functionality issues, partial degradation
- **P3 - Low**: Cosmetic issues, performance degradation

### Response Procedures
1. **Acknowledge**: Confirm incident and assess impact
2. **Assess**: Determine root cause and severity
3. **Communicate**: Notify stakeholders and users
4. **Resolve**: Implement fix and verify resolution
5. **Post-mortem**: Document lessons learned and improvements

### Emergency Contacts
- **Technical Lead**: [Contact Information]
- **DevOps Engineer**: [Contact Information]
- **Database Administrator**: [Contact Information]
- **Security Team**: [Contact Information]

## Compliance & Security

### Data Protection
- **Encryption**: Data at rest and in transit
- **Access Control**: Role-based access with principle of least privilege
- **Audit Logging**: Comprehensive logging of all data access
- **Backup Security**: Encrypted backup storage

### Regulatory Compliance
- **Data Privacy**: GDPR/CCPA compliance
- **Financial Data**: PCI DSS compliance for payment processing
- **Security Standards**: SOC 2 Type II compliance
- **Regular Audits**: Quarterly security assessments

## Capacity Planning

### Resource Monitoring
- **CPU Usage**: Target < 70% average utilization
- **Memory Usage**: Target < 80% of allocated memory
- **Disk Usage**: Target < 75% of available storage
- **Network I/O**: Monitor bandwidth utilization

### Scaling Guidelines
- **Vertical Scaling**: Increase container resources
- **Horizontal Scaling**: Add more container instances
- **Database Scaling**: Read replicas and connection pooling
- **Caching**: Redis cluster for high availability

---

## Quick Reference Commands

```bash
# System status
docker-compose ps
docker-compose logs -f

# Health checks
curl http://localhost/health
curl http://localhost/api/v1/health

# Database operations
docker-compose exec postgres psql -U agentmitra_user -d agentmitra

# Log analysis
docker-compose logs backend | grep ERROR
docker-compose logs portal | tail -100

# Performance monitoring
docker stats
docker-compose exec prometheus promtool check config /etc/prometheus/prometheus.yml

# Backup operations
docker-compose exec postgres pg_dump -U agentmitra_user agentmitra > backup.sql
```

This runbook should be updated regularly as the system evolves and new operational procedures are established.
