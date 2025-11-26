# Docker Services Guide

## Available Services

### Essential Services (Always Start)
- **minio** - Object storage for media files
- **backend** - Python FastAPI backend (port 8012)

### Optional Services
- **prometheus** - Metrics collection (port 9012)
- **grafana** - Dashboards (port 3012)
- **portal** - React Agent Config Portal (port 3013) - *Currently commented out*
- **nginx** - Reverse proxy (ports 80, 443) - *Currently commented out*

## Starting Services

### Default (Essential Only)
```bash
./scripts/start-prod.sh
# Starts: minio, backend
```

### All Available Services
```bash
./scripts/start-prod.sh all
# Starts: minio, backend, prometheus, grafana
```

### Minimal Setup
```bash
./scripts/start-prod.sh minimal
# Starts: minio, backend
```

### Specific Services
```bash
./scripts/start-prod.sh minio backend prometheus
# Starts only specified services
```

## Why Portal and Nginx Are Commented Out

The `portal` and `nginx` services are commented out in `docker-compose.prod.yml` because:

1. **Portal** requires:
   - `./config-portal` directory to exist
   - `./config-portal/Dockerfile` to exist
   - React app to be built

2. **Nginx** requires:
   - `./nginx/nginx.conf` configuration file
   - `./nginx/ssl/` directory for SSL certificates
   - `./config-portal/build/` (portal build)
   - `./build/web/` (Flutter web build)

## Enabling Portal and Nginx

1. **Uncomment services** in `docker-compose.prod.yml`:
   ```yaml
   portal:
     # ... uncomment the service definition
   
   nginx:
     # ... uncomment the service definition
   ```

2. **Ensure required files exist:**
   ```bash
   # Check if portal exists
   ls -la config-portal/
   
   # Check if nginx config exists
   ls -la nginx/nginx.conf
   
   # Check if Flutter build exists
   ls -la build/web/
   ```

3. **Start with all services:**
   ```bash
   ./scripts/start-prod.sh all
   ```

## Service Ports

| Service | Port | URL |
|---------|------|-----|
| Backend API | 8012 | http://localhost:8012 |
| Portal | 3013 | http://localhost:3013 |
| MinIO Console | 9001 | http://localhost:9001 |
| MinIO API | 9000 | http://localhost:9000 |
| Grafana | 3012 | http://localhost:3012 |
| Prometheus | 9012 | http://localhost:9012 |
| Nginx | 80, 443 | http://localhost, https://localhost |

## CORS Configuration

Backend allows requests from:
- `http://localhost:8080` (Flutter web app)
- `http://localhost:3000` (React dev server)
- `http://localhost:8012` (Backend API)
- `http://localhost:3013` (Portal)

Configure in `.env`:
```bash
CORS_ORIGINS=http://localhost:8080,http://localhost:3000,http://localhost:8012,http://localhost:3013
```

