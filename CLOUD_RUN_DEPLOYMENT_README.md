# 🚀 Agent Mitra Backend - Cloud Run Deployment

## Overview
Deploy only the backend to Google Cloud Run while keeping all other services local for cost optimization.

## Architecture

```
┌──────────────────────────┐
│   Google Cloud (Cheap)   │
│                          │
│  Cloud Run               │
│  └── backend (Python API)│
│      - Public HTTPS URL  │
│      - Scales to zero    │
│      - ~$0 when idle     │
└──────────▲───────────────┘
           │ HTTPS
           │
┌──────────┴───────────────┐
│   Local Mac (Docker)     │
│                          │
│  portal                  │
│  nginx                   │
│  minio                   │
│  prometheus/grafana      │
│  pioneer services        │
│  cloudsql-proxy          │
└──────────────────────────┘
```

## Cost Comparison

| Component | Cost |
|-----------|------|
| **Cloud Run backend** | ✅ **$0 when idle** |
| Cloud SQL (shared) | ~$10/month |
| Everything else | **Local (free)** |
| **Total** | **~$10/month** |

## Step-by-Step Deployment

### Step 1: Run Deployment Script

```bash
# Authenticate and deploy backend to Cloud Run
./deploy_backend_cloudrun.sh
```

The script will:
- Authenticate with Google Cloud
- Create Artifact Registry repository
- Build and push backend image
- Deploy to Cloud Run with Cloud SQL connectivity
- Output the Cloud Run URL

### Step 2: Update URLs

After deployment, get the Cloud Run URL from the output and run:

```bash
# Replace placeholder URLs with actual Cloud Run URL
./update_cloudrun_urls.sh https://agentmitra-backend-xxxxxxxxxx.a.run.app
```

### Step 3: Test the Setup

```bash
# Start local services (without backend)
docker-compose -f docker-compose.prod.yml up -d

# Test API health
curl http://localhost/api/v1/health

# Access portal
open http://localhost:3013
```

## What Changed

### Backend (Cloud Run)
- ✅ Added `PORT` environment variable support
- ✅ Updated Dockerfile to use `gunicorn` with `0.0.0.0:$PORT`
- ✅ Added `gunicorn` to `requirements.txt`
- ✅ Configured Cloud SQL connectivity via `--add-cloudsql-instances`

### Local Services
- ✅ **Backend service commented out** in `docker-compose.prod.yml`
- ✅ **Portal** updated to use `PORTAL_API_URL` env var
- ✅ **Nginx** updated to proxy `/api/` to Cloud Run URL

### Configuration
- ✅ All environment variables preserved for Cloud Run
- ✅ CORS updated to allow Cloud Run origins
- ✅ Cloud SQL connection via `/cloudsql/` socket (secure)

## Services Running Where

| Service | Location | Cost |
|---------|----------|------|
| **Backend API** | **Cloud Run** | Pay-per-use |
| Portal (React) | Local Docker | Free |
| Nginx (Reverse Proxy) | Local Docker | Free |
| MinIO (File Storage) | Local Docker | Free |
| Prometheus/Grafana | Local Docker | Free |
| Pioneer Feature Flags | Local Docker | Free |
| Cloud SQL Proxy | Local Docker | Free |
| **Cloud SQL Database** | **Google Cloud** | ~$10/month |

## Security & Production Ready

- ✅ **Cloud Run**: HTTPS by default, automatic SSL certificates
- ✅ **Cloud SQL**: Secure connection via Cloud SQL Auth Proxy
- ✅ **CORS**: Configured for both local development and Cloud Run
- ✅ **Environment Variables**: Production-ready configuration
- ✅ **Health Checks**: Built-in Cloud Run health monitoring

## Monitoring & Debugging

### Cloud Run Logs
```bash
# View Cloud Run logs
gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=agentmitra-backend"
```

### Local Services Logs
```bash
# View local service logs
docker-compose -f docker-compose.prod.yml logs -f
```

### Health Checks
```bash
# Test Cloud Run directly
curl https://your-cloud-run-url.a.run.app/api/v1/health

# Test through local nginx
curl http://localhost/api/v1/health
```

## Rollback (If Needed)

If you need to rollback to local backend:

1. Uncomment the backend service in `docker-compose.prod.yml`
2. Update portal API URL back to `http://backend:8012`
3. Update nginx proxy back to `http://backend:8012`
4. Remove Cloud Run service: `gcloud run services delete agentmitra-backend`

## Performance Expectations

- **Cold Start**: ~2-5 seconds (first request after idle)
- **Warm Requests**: ~50-200ms
- **Concurrent Requests**: Scales automatically to 1-1000 instances
- **Database**: Same Cloud SQL performance as before

## Files Created/Modified

### New Files
- `deploy_backend_cloudrun.sh` - Complete deployment automation
- `update_cloudrun_urls.sh` - Easy URL updates
- `CLOUD_RUN_DEPLOYMENT_README.md` - This documentation

### Modified Files
- `backend/main.py` - Added PORT support
- `backend/Dockerfile` - Changed to gunicorn
- `backend/requirements.txt` - Added gunicorn
- `backend/app/core/config/settings.py` - PORT priority
- `docker-compose.prod.yml` - Backend commented out, portal updated
- `config-portal/nginx.conf` - API proxy to Cloud Run

## Success Criteria

✅ **API accessible**: `curl http://localhost/api/v1/health` returns healthy
✅ **Portal loads**: `http://localhost:3013` shows React app
✅ **Database works**: Login and data operations function
✅ **Cost optimized**: Only Cloud Run and Cloud SQL incur costs
✅ **Scalable**: Backend scales automatically with demand

---

**Ready to deploy!** Run `./deploy_backend_cloudrun.sh` and follow the prompts. 🚀
