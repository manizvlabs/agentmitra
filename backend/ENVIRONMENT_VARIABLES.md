# Environment Variables Configuration

This document explains how to configure environment variables for the Agent Mitra backend service.

## Quick Setup

1. **Copy the example file:**
   ```bash
   cp env.example .env
   # OR for development
   cp env.development .env
   ```

2. **Edit the `.env` file** with your actual values

3. **Never commit `.env` file** to version control (it's gitignored)

## Environment File Precedence

The application loads environment variables from the following files in order of priority:

1. **`.env.local`** - Highest priority, local overrides (gitignored)
2. **`.env`** - Your main environment file (gitignored)
3. **`env.development`** - Development defaults (can be committed)
4. **`env.example`** - Template with all variables (committed)

## Environment Variables Reference

### Required Variables

These must be set for the application to work:

```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# JWT Security
JWT_SECRET_KEY=your-32-character-minimum-secret-key-here

# OpenAI (for chatbot)
OPENAI_API_KEY=your-openai-api-key
```

### Optional Variables

These have sensible defaults but may need customization:

```bash
# Application
APP_NAME=Agent Mitra API
DEBUG=true
ENVIRONMENT=development

# Server
API_HOST=0.0.0.0
API_PORT=8012

# Redis
REDIS_URL=redis://localhost:6379

# External Services
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
```

## Development vs Production

### Development (.env.development)
- Uses localhost services
- Enables debug logging
- Allows all CORS origins
- Uses mock/test API keys

### Production (.env)
- Uses production service URLs
- Disables debug mode
- Restricts CORS origins
- Uses real API keys and secrets

## Security Best Practices

1. **Never commit secrets** to version control
2. **Use strong secrets** (minimum 32 characters for JWT)
3. **Rotate secrets** regularly in production
4. **Use different secrets** for each environment
5. **Restrict CORS origins** in production

## Example .env File

```bash
# Application
APP_NAME=Agent Mitra API
DEBUG=false
ENVIRONMENT=production

# Database
DATABASE_URL=postgresql://prod_user:prod_password@prod-db:5432/prod_db

# Security
JWT_SECRET_KEY=your-production-jwt-secret-key-minimum-32-chars

# Redis
REDIS_URL=redis://prod-redis:6379
REDIS_PASSWORD=your-redis-password

# External APIs
OPENAI_API_KEY=sk-your-production-openai-key

# MinIO Storage
MINIO_ENDPOINT=prod-minio:9000
MINIO_ACCESS_KEY=prod-access-key
MINIO_SECRET_KEY=prod-secret-key
MINIO_USE_SSL=true

# CORS
CORS_ORIGINS=https://yourdomain.com,https://admin.yourdomain.com
```

## Troubleshooting

### Application won't start
- Check that `DATABASE_URL` is correctly formatted
- Ensure `JWT_SECRET_KEY` is at least 32 characters
- Verify Redis connection if using background tasks

### Database connection issues
- Check PostgreSQL is running
- Verify connection string format
- Ensure database and user exist

### Redis connection issues
- Check Redis is running on the specified host/port
- Verify password if set
- Check network connectivity

### External API issues
- Verify API keys are correct
- Check service endpoints are accessible
- Ensure proper permissions for API keys

## Migration from Old Configuration

If upgrading from an older version:

1. Copy your existing environment variables
2. Compare with `env.example` for new required variables
3. Update any changed variable names
4. Test thoroughly in development before deploying

## Support

For configuration issues:
1. Check this README
2. Review application logs
3. Verify all required variables are set
4. Ensure services (DB, Redis, etc.) are running
