# Docker Setup Guide

## Quick Start

### 1. Check Docker Status
```bash
./scripts/check-docker.sh
```

### 2. Start Services
```bash
# Start all services
./scripts/start-prod.sh all

# Or start specific services
./scripts/start-prod.sh minio backend

# Or use docker-compose directly
docker-compose -f docker-compose.prod.yml up -d
```

### 3. Stop Services
```bash
./scripts/stop-prod.sh

# Or use docker-compose directly
docker-compose -f docker-compose.prod.yml down
```

## Environment Variables

Create a `.env` file in the project root (copy from `.env.example`):

```bash
cp .env.example .env
```

Required variables:
- `JWT_SECRET_KEY` - Generate with: `openssl rand -hex 32`
- `CORS_ORIGINS` - Comma-separated list of allowed origins
- `GRAFANA_PASSWORD` - Grafana admin password

Optional variables (have defaults):
- `MINIO_ROOT_USER` - Default: `minioadmin`
- `MINIO_ROOT_PASSWORD` - Default: `minioadmin`
- `MINIO_BUCKET_NAME` - Default: `agentmitra-media`

## Services

- **minio** - Object storage (ports 9000, 9001)
- **backend** - Python API (port 8012)
- **portal** - React portal (port 3013)
- **nginx** - Reverse proxy (ports 80, 443)
- **prometheus** - Metrics (port 9012)
- **grafana** - Dashboards (port 3012)

## Troubleshooting

### Docker daemon not running
```bash
# Check status
./scripts/check-docker.sh

# Start Docker Desktop (macOS)
open -a Docker

# Start Docker (Linux)
sudo systemctl start docker
```

### View logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f backend
docker-compose -f docker-compose.prod.yml logs -f minio
```

### Restart a service
```bash
docker-compose -f docker-compose.prod.yml restart backend
```

### Check service status
```bash
docker-compose -f docker-compose.prod.yml ps
```

### Access MinIO Console
- URL: http://localhost:9001
- Username: `minioadmin`
- Password: `minioadmin` (or value from `.env`)

