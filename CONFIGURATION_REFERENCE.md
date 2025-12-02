# Agent Mitra Configuration Reference

This document provides a comprehensive reference of all environment variables and configuration options for the Agent Mitra backend system.

## Environment File Structure

The application uses multiple environment configuration files:

- `env.example` - Template with all available variables
- `env.development` - Development environment defaults
- `env.staging` - Staging environment configuration
- `env.production` - Production environment configuration
- `.env` - Local environment overrides (gitignored)

## Configuration Categories

### 1. Application Settings

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `APP_NAME` | Agent Mitra API | Application display name | All |
| `APP_VERSION` | 0.1.0 | Application version | All |
| `DEBUG` | true/false | Enable debug mode | dev: true, prod: false |
| `ENVIRONMENT` | development | Environment identifier | dev/staging/prod |

### 2. Server Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `API_HOST` | 0.0.0.0 | Server bind address | All |
| `API_PORT` | 8012 | Server port | All |

### 3. Database Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `DATABASE_URL` | postgresql://agentmitra:agentmitra_dev@localhost:5432/agentmitra_dev | PostgreSQL connection URL | All |
| `DB_POOL_SIZE` | 10 | Connection pool size | dev: 10, prod: N/A |
| `DB_MAX_OVERFLOW` | 20 | Max overflow connections | dev: 20, prod: N/A |
| `DB_POOL_TIMEOUT` | 30 | Connection timeout | dev: 30, prod: N/A |
| `DB_POOL_RECYCLE` | 3600 | Connection recycle time | dev: 3600, prod: N/A |
| `DB_ECHO` | false | SQL query logging | dev: false, prod: N/A |
| `DB_SCHEMA` | lic_schema | Database schema | prod/staging |

### 4. Redis Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `REDIS_URL` | redis://localhost:6379 | Redis connection URL | All |
| `REDIS_HOST` | localhost | Redis host | All |
| `REDIS_PORT` | 6379 | Redis port | All |
| `REDIS_DB` | 0 | Redis database number | dev: 0, staging: 1 |
| `REDIS_PASSWORD` | "" | Redis password | prod: required |
| `REDIS_SOCKET_TIMEOUT` | 5 | Socket timeout | dev: 5 |
| `REDIS_SOCKET_CONNECT_TIMEOUT` | 5 | Connect timeout | dev: 5 |

### 5. Security & Authentication

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `JWT_SECRET_KEY` | dev-jwt-secret-key-change-in-production-32-chars-minimum | JWT signing key | All (unique per env) |
| `JWT_ALGORITHM` | HS256 | JWT algorithm | All |
| `JWT_ACCESS_TOKEN_EXPIRE_MINUTES` | 15 | Access token expiry | All |
| `JWT_REFRESH_TOKEN_EXPIRE_DAYS` | 7 | Refresh token expiry | All |

### 6. OTP Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `OTP_EXPIRY_MINUTES` | 5 | OTP validity duration | All |
| `OTP_MAX_ATTEMPTS` | 3 | Max OTP verification attempts | All |
| `OTP_RATE_LIMIT_PER_HOUR` | 5 | OTP requests per hour limit | dev: 5, staging: 10 |

### 7. Rate Limiting

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `RATE_LIMITING_ENABLED` | true/false | Enable rate limiting | dev: false, staging/prod: true |
| `RATE_LIMIT_DEFAULT` | 100/minute | Default rate limit | dev: 100, staging: 500 |
| `RATE_LIMIT_AUTH` | 10000/hour | Auth endpoints limit | dev: 10000, staging: 5000 |
| `RATE_LIMIT_OTP` | 50/hour | OTP endpoints limit | dev: 50, staging: 100 |
| `RATE_LIMIT_IMPORT` | 50/minute | Import endpoints limit | dev: 50, staging: 100 |
| `RATE_LIMIT_ANALYTICS` | 500/minute | Analytics endpoints limit | dev: 500, staging: 1000 |

### 8. External APIs

#### OpenAI Configuration
| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `OPENAI_API_KEY` | dev-openai-api-key | OpenAI API key | All (dev has placeholder) |
| `OPENAI_MODEL` | gpt-3.5-turbo | OpenAI model | All |
| `OPENAI_MAX_TOKENS` | 500/300 | Max tokens per request | dev: 500, prod: 300 |
| `OPENAI_TEMPERATURE` | 0.7 | Response creativity | All |
| `OPENAI_ORGANIZATION` | dev-org-id | OpenAI organization ID | dev: placeholder |

### 9. SMS Provider Configuration

#### Twilio
| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `SMS_PROVIDER` | twilio | SMS provider | All |
| `TWILIO_ACCOUNT_SID` | dev-twilio-account-sid | Twilio account SID | All (dev has placeholder) |
| `TWILIO_AUTH_TOKEN` | dev-twilio-auth-token | Twilio auth token | All (dev has placeholder) |
| `TWILIO_PHONE_NUMBER` | +1234567890 | Twilio phone number | All |
| `TWILIO_MESSAGING_SERVICE_SID` | dev-messaging-service-sid | Twilio messaging service | dev: placeholder |

#### AWS SNS (Alternative)
| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `SMS_API_KEY` | dev-sms-api-key | SMS API key | dev: placeholder |
| `SMS_API_SECRET` | dev-sms-api-secret | SMS API secret | dev: placeholder |
| `SMS_FROM_NUMBER` | +1234567890 | SMS sender number | All |
| `SMS_SENDER_ID` | AGMITR | SMS sender ID | All |

### 10. AWS Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `AWS_ACCESS_KEY_ID` | dev-aws-access-key | AWS access key | All (dev has placeholder) |
| `AWS_SECRET_ACCESS_KEY` | dev-aws-secret-key | AWS secret key | All (dev has placeholder) |
| `AWS_REGION` | us-east-1 | AWS region | All |

### 11. Email Provider Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `EMAIL_PROVIDER` | smtp | Email provider | dev/staging: smtp, prod: sendgrid |
| `EMAIL_HOST` | smtp.gmail.com | SMTP host | dev/staging: smtp.gmail.com, prod: smtp.sendgrid.net |
| `EMAIL_PORT` | 587 | SMTP port | All |
| `EMAIL_USER` | dev@example.com | SMTP username | All (dev has placeholder) |
| `EMAIL_PASSWORD` | dev-app-password | SMTP password | All (dev has placeholder) |
| `EMAIL_FROM` | dev@example.com | From email address | All |

### 12. Feature Flag Configuration (Pioneer/FeatureHub)

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `FEATUREHUB_URL` | http://localhost:8071 | FeatureHub server URL | dev/staging |
| `FEATUREHUB_API_KEY` | dev-featurehub-api-key | FeatureHub API key | All (dev has placeholder) |
| `FEATUREHUB_ENVIRONMENT` | development | FeatureHub environment | All |
| `FEATUREHUB_SDK_KEY` | dev-featurehub-sdk-key | FeatureHub SDK key | All (dev has placeholder) |
| `FEATUREHUB_POLL_INTERVAL` | 30 | Polling interval | All |
| `FEATUREHUB_STREAMING` | true | Enable streaming | All |
| `FEATUREHUB_ADMIN_TOKEN` | dev-admin-token | Admin token | dev: placeholder |
| `FEATUREHUB_ADMIN_SDK_URL` | http://localhost:8071 | Admin SDK URL | dev/staging |

### 13. MinIO Storage Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `MINIO_ENDPOINT` | localhost:9000 | MinIO server endpoint | dev: localhost, prod: prod-minio |
| `MINIO_ACCESS_KEY` | minioadmin | MinIO access key | All |
| `MINIO_SECRET_KEY` | minioadmin | MinIO secret key | dev: minioadmin, prod: secure |
| `MINIO_BUCKET_NAME` | agentmitra-media | Storage bucket | dev: agentmitra-media, staging: agentmitra-staging-media, prod: agentmitra-production-media |
| `MINIO_USE_SSL` | false | Use SSL/TLS | dev/staging: false, prod: true |
| `MINIO_CDN_BASE_URL` | http://localhost:9000/agentmitra-media | CDN base URL | All (environment-specific) |

### 14. WhatsApp Business API Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `WHATSAPP_API_URL` | https://graph.facebook.com/v18.0 | WhatsApp API URL | All |
| `WHATSAPP_ACCESS_TOKEN` | dev-whatsapp-access-token | WhatsApp access token | All (dev has placeholder) |
| `WHATSAPP_BUSINESS_ACCOUNT_ID` | dev-business-account-id | Business account ID | All (dev has placeholder) |
| `WHATSAPP_BUSINESS_NUMBER` | 1234567890 | Business phone number | All |
| `WHATSAPP_WEBHOOK_SECRET` | dev-webhook-secret | Webhook secret | All (dev has placeholder) |
| `WHATSAPP_VERIFY_TOKEN` | dev-verify-token | Verify token | All (dev has placeholder) |
| `WHATSAPP_WEBHOOK_URL` | N/A | Webhook URL | dev: missing, others: N/A |

### 15. YouTube Integration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `YOUTUBE_API_KEY` | your-youtube-api-key | YouTube API key | All (placeholder) |
| `YOUTUBE_CHANNEL_ID` | your-youtube-channel-id | Channel ID | All (placeholder) |
| `YOUTUBE_CLIENT_ID` | your-youtube-oauth-client-id | OAuth client ID | All (placeholder) |
| `YOUTUBE_CLIENT_SECRET` | your-youtube-oauth-client-secret | OAuth client secret | All (placeholder) |
| `YOUTUBE_UPLOAD_ENABLED` | true | Enable uploads | All |
| `YOUTUBE_DEFAULT_PRIVACY` | unlisted | Default privacy | All |

### 16. Video Tutorial System

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `VIDEO_MAX_FILE_SIZE_MB` | 100 | Max video size | All |
| `VIDEO_ALLOWED_FORMATS` | mp4,mov,avi,mkv,webm | Allowed formats | All |
| `VIDEO_MAX_DURATION_SECONDS` | 900 | Max duration | All |
| `VIDEO_MIN_DURATION_SECONDS` | 30 | Min duration | All |
| `VIDEO_THUMBNAIL_GENERATION` | true | Generate thumbnails | All |
| `VIDEO_TRANSCRIPTION_AUTO` | false | Auto transcription | All |
| `VIDEO_PROCESSING_QUEUE` | redis_queue | Processing queue | dev: redis_queue |
| `VIDEO_RECOMMENDATION_ENABLED` | true | Enable recommendations | All |
| `VIDEO_ANALYTICS_ENABLED` | true | Enable analytics | All |
| `VIDEO_AUTO_TAGGING_ENABLED` | true | Auto tagging | All |

### 17. Payment Gateway Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `RAZORPAY_KEY_ID` | dev-razorpay-key-id | Razorpay key ID | All (dev has placeholder) |
| `RAZORPAY_KEY_SECRET` | dev-razorpay-key-secret | Razorpay secret | All (dev has placeholder) |
| `RAZORPAY_WEBHOOK_SECRET` | dev-razorpay-webhook-secret | Razorpay webhook secret | All (dev has placeholder) |
| `STRIPE_SECRET_KEY` | dev-stripe-secret-key | Stripe secret key | All (dev has placeholder) |
| `STRIPE_PUBLISHABLE_KEY` | dev-stripe-publishable-key | Stripe publishable key | All (dev has placeholder) |
| `STRIPE_WEBHOOK_SECRET` | dev-stripe-webhook-secret | Stripe webhook secret | All (dev has placeholder) |

### 18. Legacy Feature Flags

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `ENABLE_MOCK_DATA` | false | Enable mock data | All |
| `ENABLE_ANALYTICS` | true | Enable analytics | All |
| `ENABLE_PAYMENT_PROCESSING` | false | Enable payments | dev: false |
| `ENABLE_CHATBOT` | true | Enable chatbot | All |

### 19. Logging Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `LOG_LEVEL` | INFO | Log level | dev: INFO, prod: WARNING |
| `LOG_FILE` | ./logs/app.log | Log file path | dev: ./logs/app.log, prod: /app/logs/agentmitra.log |
| `LOG_JSON_FORMAT` | false | JSON log format | dev: false, prod/staging: true |

### 20. Monitoring Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `ENABLE_METRICS` | true | Enable metrics | All |
| `METRICS_PORT` | 9090/8001 | Metrics port | dev: 9090, prod: 8001 |
| `PROMETHEUS_ENABLED` | true | Enable Prometheus | All |

### 21. CORS Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `CORS_ORIGINS` | http://localhost:3000,http://localhost:8080,http://localhost:8012,http://localhost:3013 | Allowed origins | All |
| `CORS_ALLOW_CREDENTIALS` | true | Allow credentials | All |
| `CORS_ALLOW_METHODS` | GET,POST,PUT,DELETE,OPTIONS | Allowed methods | All |
| `CORS_ALLOW_HEADERS` | * | Allowed headers | All |

### 22. File Upload Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `MAX_UPLOAD_SIZE_MB` | 10 | Max upload size | dev: 10, prod: 100 |
| `UPLOAD_DIR` | ./uploads | Upload directory | All |
| `ALLOWED_FILE_TYPES` | image/jpeg,image/png,image/gif,application/pdf | Allowed file types | dev: images+pdf, prod: includes video |

### 23. Compliance Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `IRDAI_COMPLIANCE_ENABLED` | true | Enable IRDAI compliance | All |
| `DPDP_COMPLIANCE_ENABLED` | true | Enable DPDP compliance | All |
| `AUDIT_LOGGING_ENABLED` | true | Enable audit logging | All |
| `DATA_ENCRYPTION_ENABLED` | true/false | Enable data encryption | dev: true, staging: false, prod: true |

### 24. Content Management

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `CONTENT_MAX_FILE_SIZE_MB` | 100 | Max content size | All |
| `CONTENT_ALLOWED_VIDEO_TYPES` | video/mp4,video/avi,video/mov,video/mkv,video/webm | Allowed video types | All |
| `CONTENT_ALLOWED_DOC_TYPES` | application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document | Allowed doc types | All |
| `CONTENT_CDN_ENABLED` | true | Enable CDN | All |
| `CONTENT_COMPRESSION_ENABLED` | true | Enable compression | All |

### 25. Analytics Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `ANALYTICS_RETENTION_DAYS` | 90 | Data retention | dev: 90, staging: 30 |
| `ANALYTICS_CACHE_TTL` | 3600 | Cache TTL | dev: 3600, staging: 1800 |
| `ANALYTICS_REPORTING_ENABLED` | true | Enable reporting | All |

### 26. Chatbot Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `CHATBOT_ENABLED` | true | Enable chatbot | All |
| `CHATBOT_MODEL` | gpt-3.5-turbo | Chatbot model | All |
| `CHATBOT_TEMPERATURE` | 0.7 | Response temperature | All |
| `CHATBOT_MAX_TOKENS` | 300 | Max tokens | All |
| `CHATBOT_LANGUAGE` | en | Language | All |
| `CHATBOT_AUTO_ESCALATION_ENABLED` | true | Auto escalation | All |
| `CHATBOT_PROACTIVE_SUGGESTIONS_ENABLED` | true | Proactive suggestions | All |

### 27. Callback Management

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `CALLBACK_SLA_HIGH` | 15 | High priority SLA (minutes) | All |
| `CALLBACK_SLA_MEDIUM` | 60 | Medium priority SLA (minutes) | All |
| `CALLBACK_SLA_LOW` | 240 | Low priority SLA (minutes) | All |
| `CALLBACK_AUTO_ASSIGN` | true | Auto assign callbacks | All |
| `CALLBACK_ESCALATION_HOURS` | 24 | Escalation time (hours) | All |

### 28. Portal Service Configuration

| Variable | Default | Description | Environment |
|----------|---------|-------------|-------------|
| `PORTAL_APP_NAME` | Agent Configuration Portal | Portal app name | dev/staging |
| `PORTAL_APP_VERSION` | 1.0.0 | Portal version | dev/staging |
| `PORTAL_DEBUG` | true | Portal debug mode | dev: true |
| `PORTAL_ENVIRONMENT` | development | Portal environment | dev/staging |
| `PORTAL_HOST` | 0.0.0.0 | Portal host | dev/staging |
| `PORTAL_PORT` | 3013 | Portal port | dev/staging |
| `PORTAL_JWT_SECRET_KEY` | dev-portal-jwt-secret-key-change-in-production | Portal JWT key | dev/staging |
| `PORTAL_JWT_ACCESS_TOKEN_EXPIRE_MINUTES` | 60 | Portal token expiry | dev/staging |
| `PORTAL_CORS_ORIGINS` | http://localhost:3000,http://localhost:3013 | Portal CORS origins | dev/staging |
| `MAIN_API_URL` | http://localhost:8012 | Main API URL | dev/staging |
| `MAIN_API_TOKEN` | "" | Main API token | dev/staging |
| `PORTAL_UPLOAD_DIR` | ./portal_uploads | Portal upload dir | dev/staging |
| `PORTAL_MAX_UPLOAD_SIZE_MB` | 50 | Portal max upload size | dev/staging |
| `ENABLE_AGENT_ONBOARDING` | true | Enable agent onboarding | dev/staging |
| `ENABLE_BULK_IMPORT` | true | Enable bulk import | dev/staging |
| `ENABLE_CALLBACK_MANAGEMENT` | true | Enable callback management | dev/staging |
| `ENABLE_CONTENT_MANAGEMENT` | true | Enable content management | dev/staging |
| `IMPORT_BATCH_SIZE` | 100 | Import batch size | dev/staging |
| `IMPORT_TIMEOUT_SECONDS` | 300 | Import timeout | dev/staging |
| `PORTAL_LOG_LEVEL` | INFO | Portal log level | dev/staging |
| `PORTAL_LOG_FILE` | ./logs/portal.log | Portal log file | dev/staging |
| `PORTAL_SMTP_SERVER` | smtp.gmail.com | Portal SMTP server | dev/staging |
| `PORTAL_SMTP_PORT` | 587 | Portal SMTP port | dev/staging |
| `PORTAL_SMTP_USERNAME` | dev-portal@example.com | Portal SMTP user | dev/staging |
| `PORTAL_SMTP_PASSWORD` | dev-portal-app-password | Portal SMTP password | dev/staging |

## Environment-Specific Configurations

### Development Environment
- Uses localhost services
- Debug mode enabled
- Rate limiting disabled
- Mock/test API keys
- Extensive logging
- All CORS origins allowed

### Staging Environment
- Uses staging service URLs
- Debug mode disabled
- Moderate rate limiting
- Real API keys (staging)
- JSON logging enabled
- Reduced data retention

### Production Environment
- Production service URLs
- Debug mode disabled
- Strict rate limiting
- Production API keys and secrets
- Minimal logging (WARNING+)
- Full security measures
- Restricted CORS origins

## Security Considerations

### Required Security Measures
1. **JWT_SECRET_KEY**: Minimum 32 characters, unique per environment
2. **Database passwords**: Strong, rotated regularly
3. **API keys**: Environment-specific, restricted permissions
4. **CORS origins**: Whitelist only required domains in production
5. **SSL/TLS**: Enabled for all external communications in production

### Environment Variable Precedence
1. `.env.local` (highest priority, local overrides)
2. `.env` (main environment file)
3. `env.{ENVIRONMENT}` (environment-specific defaults)
4. `env.example` (template with all variables)

## Migration Guide

When upgrading or deploying:

1. Compare your current `.env` with `env.example`
2. Add any new required variables
3. Update changed variable names
4. Test in development environment
5. Deploy to staging for validation
6. Deploy to production with proper secrets

## Troubleshooting

### Common Issues
- **Application won't start**: Check DATABASE_URL format and JWT_SECRET_KEY length
- **Database connection fails**: Verify PostgreSQL credentials and network connectivity
- **Redis connection fails**: Check Redis service and password configuration
- **External API failures**: Validate API keys and endpoint URLs
- **CORS errors**: Review CORS_ORIGINS configuration

### Debug Steps
1. Check application logs for specific error messages
2. Verify environment variable values are loaded correctly
3. Test individual service connections (DB, Redis, external APIs)
4. Use development environment for detailed debugging
5. Compare configurations between working and failing environments
