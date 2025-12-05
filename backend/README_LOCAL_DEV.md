# Backend Local Development Guide

## Quick Start

The backend is now configured to run locally with hot reload (no Docker builds required).

### Run Backend Locally

```bash
# From project root
./scripts/run_backend.sh

# Or from backend directory
cd backend
python main.py
```

### Environment Setup

The script automatically:
- Activates virtual environment
- Sets up environment variables for local development
- Connects to local services (PostgreSQL, Redis, MinIO)
- Enables hot reload for fast development

### Service Connections

When running locally, the backend connects to:
- **PostgreSQL**: `localhost:5432` (local MacBook service)
- **Redis**: `localhost:6379` (local MacBook service)
- **MinIO**: `localhost:9000` (Docker container, port exposed)
- **Pioneer**: `localhost:4001` (Docker container, port exposed)

### Nginx Configuration

Nginx (running in Docker) is configured to proxy requests to the backend running on the host machine via `host.docker.internal:8012`. This means:
- Backend runs on `localhost:8012` (host machine)
- Nginx connects to backend via `host.docker.internal:8012`
- No changes needed to nginx configuration

### Hot Reload

The backend automatically reloads on code changes when `ENVIRONMENT=development`. No need to restart manually!

### API Endpoints

- API Base: `http://localhost:8012`
- API Docs: `http://localhost:8012/docs`
- Health Check: `http://localhost:8012/api/v1/health`

### Troubleshooting

1. **Port already in use**: Make sure nothing else is running on port 8012
2. **Database connection failed**: Ensure PostgreSQL is running locally
3. **Redis connection failed**: Ensure Redis is running locally
4. **MinIO connection failed**: Ensure MinIO Docker container is running and port 9000 is exposed

