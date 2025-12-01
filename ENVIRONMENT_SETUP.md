# Environment Configuration Guide

## Unified .env Configuration

Agent Mitra uses a **single unified `.env` file** in the project root for all configuration across all components:

- Flutter Mobile App
- Python Backend API
- React Config Portal

## Setup Instructions

### 1. Copy Environment Template
```bash
cp .env.example .env
```

### 2. Configure Your Environment

Edit `.env` with your specific values:

```bash
# Required for development
nano .env
```

### 3. Verify Configuration

Each component loads from the unified `.env` file:

- **Flutter**: `await dotenv.load(fileName: '.env')`
- **Backend**: `load_dotenv('.env', override=True)`
- **React**: `process.env.REACT_APP_*` variables

## Configuration Sections

### Application Settings (Shared)
```env
APP_NAME=Agent Mitra
APP_VERSION=1.0.0
ENVIRONMENT=development
DEBUG=true
```

### Flutter App Configuration
```env
API_BASE_URL=http://localhost:8012
ENABLE_CHATBOT=true
PIONEER_ENABLED=true
# ... more Flutter-specific settings
```

### Backend Configuration
```env
DATABASE_URL=postgresql://agentmitra:agentmitra_dev@localhost:5432/agentmitra_dev
REDIS_URL=redis://localhost:6379
JWT_SECRET_KEY=your-secret-key
OPENAI_API_KEY=your-openai-key
# ... more backend-specific settings
```

### React Portal Configuration
```env
REACT_APP_API_URL=http://localhost:8012
REACT_APP_PIONEER_URL=http://localhost:4001
# ... more React-specific settings
```

## Development vs Production

### Development Setup
```bash
# Local PostgreSQL & Redis (via brew)
brew services start postgresql@16
brew services start redis

# Pioneer via Docker
docker compose -f docker-compose.prod.yml up -d pioneer-nats pioneer-compass-server pioneer-scout pioneer-compass-client

# Start services
./scripts/deploy/start-prod.sh minimal
```

### Production Setup
```bash
# Update .env for production values
ENVIRONMENT=production
DATABASE_URL=postgresql://prod_user:prod_pass@prod-db-host:5432/agentmitra_prod
JWT_SECRET_KEY=your-production-jwt-secret-key
CORS_ORIGINS=https://your-production-domain.com

# Deploy
./scripts/deploy/start-prod.sh all
```

## Required Environment Variables

### Critical for All Environments
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `JWT_SECRET_KEY` - JWT signing key (32+ chars)
- `PIONEER_API_KEY` - Feature flag service key

### Optional but Recommended
- `OPENAI_API_KEY` - For chatbot functionality
- `MINIO_ACCESS_KEY/SECRET` - For file storage
- `RAZORPAY_KEY_ID/SECRET` - For payments

## Security Notes

- **Never commit `.env`** - It contains sensitive credentials
- **Use strong secrets** - Especially `JWT_SECRET_KEY`
- **Environment-specific configs** - Different values for dev/staging/prod
- **Access control** - Limit who can modify `.env`

## Troubleshooting

### Flutter App Issues
- Ensure `.env` is in project root
- Check `flutter_dotenv` package is installed
- Verify `AppConfig.initialize()` is called in `main.dart`

### Backend Issues
- Check backend logs: `docker compose -f docker-compose.prod.yml logs backend`
- Verify `.env` loading in `settings.py`
- Check database connectivity

### React Portal Issues
- Ensure `REACT_APP_*` variables are prefixed correctly
- Check browser console for missing environment variables
- Verify API endpoints are accessible

## Migration from Individual .env Files

If migrating from individual component `.env` files:

1. **Backup existing configs**
   ```bash
   cp backend/env.development backend/env.development.backup
   cp config-portal/.env config-portal/.env.backup
   ```

2. **Merge configurations** into root `.env`
   ```bash
   # Combine all unique variables from individual files
   cat backend/env.development >> .env
   cat config-portal/.env >> .env
   # Remove duplicates and organize
   ```

3. **Update component loading**
   - Flutter: Already configured for root `.env`
   - Backend: Updated `settings.py` to load from root
   - React: Configure to use root `.env`

4. **Test all components**
   ```bash
   # Test Flutter
   flutter run

   # Test Backend
   cd backend && python main.py

   # Test React
   cd config-portal && npm start
   ```

## Support

For configuration issues:
1. Check this guide
2. Verify `.env` file exists and is readable
3. Check component-specific logs
4. Ensure all required services are running
