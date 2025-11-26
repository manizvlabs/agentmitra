# Docker Compose Setup - Complete & Functional

## ✅ All Services Enabled

All services in `docker-compose.prod.yml` are now **fully functional** and ready to use:

### Essential Services
- ✅ **minio** - Object storage for media files (ports 9000, 9001)
- ✅ **backend** - Python FastAPI backend (port 8012)

### Frontend Services
- ✅ **portal** - React Agent Configuration Portal (port 3013)
- ✅ **nginx** - Reverse proxy for Flutter web app and portal (ports 80, 443)

### Monitoring Services
- ✅ **prometheus** - Metrics collection (port 9012)
- ✅ **grafana** - Dashboards (port 3012)

## Quick Start

### Start All Services
```bash
./scripts/start-prod.sh all
```

### Start Essential Services Only
```bash
./scripts/start-prod.sh
# or
./scripts/start-prod.sh minimal
```

### Start Specific Services
```bash
./scripts/start-prod.sh minio backend portal
```

## Service URLs

| Service | URL | Credentials |
|---------|-----|------------|
| **Backend API** | http://localhost:8012 | - |
| **Portal** | http://localhost:3013 | - |
| **Flutter Web** | http://localhost:80 | - |
| **Nginx** | http://localhost:80 | - |
| **MinIO Console** | http://localhost:9001 | minioadmin / minioadmin |
| **MinIO API** | http://localhost:9000 | - |
| **Grafana** | http://localhost:3012 | admin / (from .env) |
| **Prometheus** | http://localhost:9012 | - |

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Nginx (Port 80/443)                   │
│  ┌──────────────────┐  ┌──────────────────┐            │
│  │  Flutter Web App │  │  Portal (/portal) │            │
│  │  /var/www/flutter│  │  Proxy to portal  │            │
│  └──────────────────┘  └──────────────────┘            │
│                                                           │
│  ┌──────────────────┐                                    │
│  │  API Proxy (/api)│                                    │
│  │  → backend:8012   │                                    │
│  └──────────────────┘                                    │
└───────────────────────────────────────────────────────────┘
                          │
                          ▼
┌───────────────────────────────────────────────────────────┐
│                    Backend (Port 8012)                    │
│  ┌──────────────────┐  ┌──────────────────┐              │
│  │  FastAPI        │  │  MinIO Storage   │              │
│  │  /api/v1/*       │  │  Port 9000       │              │
│  └──────────────────┘  └──────────────────┘              │
└───────────────────────────────────────────────────────────┘
```

## Prerequisites

### Required Files/Directories
- ✅ `config-portal/` - React portal source code
- ✅ `config-portal/Dockerfile` - Portal Docker build file
- ✅ `config-portal/build/` - Portal production build (auto-created during Docker build)
- ✅ `build/web/` - Flutter web build (must exist before starting nginx)
- ✅ `nginx/nginx.conf` - Nginx main configuration
- ✅ `nginx/ssl/` - SSL certificates directory (optional, empty for HTTP)

### Build Requirements

**Portal Build:**
The portal is built automatically during Docker image creation. The Dockerfile:
1. Installs Node.js dependencies
2. Builds the React app (`npm run build`)
3. Serves it with nginx

**Flutter Web Build:**
You need to build the Flutter web app before starting nginx:
```bash
flutter build web
```

## SSL/HTTPS Setup (Optional)

For development, HTTP works fine. For HTTPS:

1. **Generate self-signed certificates:**
   ```bash
   ./scripts/generate-ssl-certs.sh
   ```

2. **Uncomment SSL server block** in `nginx/nginx.conf`:
   ```nginx
   server {
       listen 443 ssl http2;
       # ... SSL configuration
   }
   ```

3. **Update docker-compose.prod.yml** to use the certificates:
   ```yaml
   volumes:
     - ./nginx/ssl/nginx-selfsigned.crt:/etc/nginx/ssl/cert.pem:ro
     - ./nginx/ssl/nginx-selfsigned.key:/etc/nginx/ssl/key.pem:ro
   ```

## Troubleshooting

### Portal Not Starting
- Check if `config-portal/Dockerfile` exists
- Verify `config-portal/package.json` is valid
- Check Docker build logs: `docker-compose -f docker-compose.prod.yml logs portal`

### Nginx Not Starting
- Verify `build/web/` directory exists (run `flutter build web`)
- Check nginx config: `docker-compose -f docker-compose.prod.yml config`
- Check nginx logs: `docker-compose -f docker-compose.prod.yml logs nginx`

### Port Conflicts
If ports 80, 443, 3013 are already in use:
- Stop conflicting services
- Or modify ports in `docker-compose.prod.yml`

## Health Checks

All services include health checks:
- **Backend**: `http://localhost:8012/health`
- **Portal**: `http://localhost:3013/health`
- **Nginx**: `http://localhost:80/health`
- **MinIO**: Auto-checked via Docker healthcheck

## Next Steps

1. **Build Flutter web app:**
   ```bash
   flutter build web
   ```

2. **Start all services:**
   ```bash
   ./scripts/start-prod.sh all
   ```

3. **Access the applications:**
   - Flutter web: http://localhost:80
   - Portal: http://localhost:3013
   - Backend API: http://localhost:8012

4. **Verify services:**
   ```bash
   docker-compose -f docker-compose.prod.yml ps
   ```

All services are now **fully functional** and ready for development and production use! 🚀

