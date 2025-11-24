# FeatureHub Startup Guide

## Issue: FeatureHub Edge not starting on port 8071

## Root Cause Analysis

1. **Docker Daemon Access**: Docker daemon not accessible from terminal session
2. **Dependency Chain**: FeatureHub Edge depends on FeatureHub Admin, which depends on Database
3. **Startup Order**: Services need to start in correct order

## Solution Steps

### 1. Start Services in Order

```bash
cd /Users/manish/Documents/GitHub/zero/agentmitra

# Step 1: Start Database
docker-compose -f docker-compose.dev.yml up -d featurehub-db

# Step 2: Wait for DB to be ready (10-15 seconds)
sleep 15

# Step 3: Start Admin
docker-compose -f docker-compose.dev.yml up -d featurehub-admin

# Step 4: Wait for Admin to be ready (30-60 seconds)
sleep 60

# Step 5: Start Edge
docker-compose -f docker-compose.dev.yml up -d featurehub-edge

# Step 6: Verify
curl http://localhost:8071/health
```

### 2. Check Logs

```bash
# Check Edge logs
docker-compose -f docker-compose.dev.yml logs featurehub-edge

# Check Admin logs
docker-compose -f docker-compose.dev.yml logs featurehub-admin

# Check DB logs
docker-compose -f docker-compose.dev.yml logs featurehub-db
```

### 3. Verify Services

```bash
# Check all FeatureHub services
docker-compose -f docker-compose.dev.yml ps

# Check port mapping
docker ps | grep featurehub

# Test health endpoint
curl http://localhost:8071/health
```

## Configuration

### Port Mapping
- **Host Port**: 8071
- **Container Port**: 8080
- **Mapping**: `8071:8080`

### Network
- **Network**: `agentmitra_network`
- **Edge URL**: `http://featurehub-edge:8080` (internal)
- **Public URL**: `http://localhost:8071` (external)

### Environment Variables
- `FEATUREHUB_MODE=edge`
- `FEATUREHUB_REPOSITORY_URL=http://featurehub-admin:8085`
- `FEATUREHUB_EDGE_PORT=8080`

## Troubleshooting

### If Edge fails to start:

1. **Check Admin is running**:
   ```bash
   curl http://localhost:8085/health
   ```

2. **Check Edge logs for errors**:
   ```bash
   docker-compose -f docker-compose.dev.yml logs featurehub-edge | tail -50
   ```

3. **Restart Edge**:
   ```bash
   docker-compose -f docker-compose.dev.yml restart featurehub-edge
   ```

4. **Check network connectivity**:
   ```bash
   docker exec agentmitra_featurehub_edge_dev ping featurehub-admin
   ```

### Common Issues

1. **Admin not ready**: Edge starts before Admin is healthy
   - **Fix**: Added `depends_on` with `condition: service_healthy`

2. **Port already in use**: Another service using port 8071
   - **Fix**: Check `lsof -i :8071` and stop conflicting service

3. **Network issues**: Containers can't communicate
   - **Fix**: Ensure all services on same network (`agentmitra_network`)

## Updated docker-compose.dev.yml

Added `depends_on` to ensure proper startup order:
- Edge waits for Admin to be healthy
- Admin waits for DB to be healthy

## Testing

Once FeatureHub is running:

```bash
# Test health
curl http://localhost:8071/health

# Test backend integration
curl http://localhost:8012/api/v1/feature-flags
```

