# Agent Mitra Cloud Sandbox Setup Guide

## Overview

This document provides a comprehensive guide for creating a cost-effective cloud sandbox environment for Agent Mitra mobile app development and testing. The sandbox is designed for startups with limited budgets, providing full development capabilities while minimizing costs through strategic use of cloud free tiers and efficient resource allocation.

## Architecture Overview

### Core Services
```
┌─────────────────────────────────────────────────────────────────┐
│                        Cloud Sandbox                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │   Frontend  │  │    Backend  │  │   Database  │              │
│  │  (Flutter)  │  │   (FastAPI) │  │(PostgreSQL) │              │
│  │             │  │             │  │             │              │
│  │ AWS Lightsail│  │AWS Lightsail│  │ AWS RDS     │              │
│  │    $5/mo    │  │    $5/mo    │  │  FREE        │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │    Cache    │  │   Storage   │  │ Notifications│              │
│  │   (Redis)   │  │    (S3)     │  │   (Firebase) │              │
│  │             │  │             │  │             │              │
│  │AWS ElastiCache│ │   AWS S3    │  │    FCM      │              │
│  │    FREE      │  │  $0-2/mo    │  │    FREE      │              │
│  └─────────────┘  └─────────────┘  └─────────────┘              │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐                              │
│  │   DNS/SSL   │  │  Monitoring │                              │
│  │ (Cloudflare)│  │(Prometheus) │                              │
│  │             │  │             │                              │
│  │    FREE     │  │  Included   │                              │
│  └─────────────┘  └─────────────┘                              │
└─────────────────────────────────────────────────────────────────┘
```

## Cost Breakdown (First 3 Months)

| Service | Cost/Month | Purpose | Free Tier Details |
|---------|------------|---------|-------------------|
| **AWS Lightsail (2GB)** | **$10** | App server + Backend | First 750 hours free |
| **AWS RDS PostgreSQL** | **$0** | Database | 750 hours free, 20GB storage |
| **AWS ElastiCache Redis** | **$0** | Cache | 750 hours free, 1 node |
| **AWS S3** | **$0-2** | File storage | 5GB free, then $0.023/GB |
| **Cloudflare** | **$0** | DNS/SSL/CDN | Always free |
| **Firebase FCM** | **$0** | Push notifications | 500K messages/day free |
| **Firebase Auth** | **$0** | User authentication | 10K users free |
| **GitHub Codespaces** | **$0** | Development environment | 120 hours free/month |
| **TOTAL** | **$10-12** | **Full sandbox** | **~90% cost savings vs paid alternatives** |

## Prerequisites

### Required Accounts
1. **AWS Account** - Free tier eligible
2. **Google Cloud/Firebase** - Free tier
3. **Cloudflare** - Free account
4. **GitHub** - For Codespaces

### Required Tools
- Docker & Docker Compose
- Flutter SDK (for local development)
- AWS CLI
- Firebase CLI
- Git

## Step-by-Step Setup Guide

### Step 1: AWS Infrastructure Setup

#### 1.1 Create AWS Lightsail Instance
```bash
# Using AWS CLI (or Web Console)
aws lightsail create-instances \
  --instance-names agentmitra-sandbox \
  --availability-zone us-east-1a \
  --blueprint-id ubuntu_22_04 \
  --bundle-id nano_3_0 \  # 2GB RAM, 1 vCPU, 40GB SSD - $10/month
  --user-data file://scripts/aws/user-data.sh
```

#### 1.2 Setup RDS PostgreSQL Database
```bash
# Create RDS instance (free tier)
aws rds create-db-instance \
  --db-instance-identifier agentmitra-db \
  --db-instance-class db.t4g.micro \
  --engine postgres \
  --master-username admin \
  --master-user-password $(openssl rand -base64 12) \
  --allocated-storage 20 \
  --vpc-security-group-ids $SECURITY_GROUP_ID
```

#### 1.3 Setup ElastiCache Redis
```bash
# Create Redis cluster (free tier)
aws elasticache create-cache-cluster \
  --cache-cluster-id agentmitra-cache \
  --cache-node-type cache.t4g.micro \
  --engine redis \
  --num-cache-nodes 1 \
  --security-group-ids $SECURITY_GROUP_ID
```

#### 1.4 Configure Security Groups
```bash
# Allow necessary ports
aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0  # SSH (restrict in production)

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 80 \
  --cidr 0.0.0.0/0  # HTTP

aws ec2 authorize-security-group-ingress \
  --group-id $SECURITY_GROUP_ID \
  --protocol tcp \
  --port 443 \
  --cidr 0.0.0.0/0  # HTTPS
```

### Step 2: Firebase Setup

#### 2.1 Create Firebase Project
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and create project
firebase login
firebase projects:create agentmitra-sandbox
firebase use agentmitra-sandbox
```

#### 2.2 Configure Firebase Services
```bash
# Enable required services
firebase services:list  # Check available services

# Configure FCM (already enabled by default)
# Configure Authentication
firebase auth:config --project agentmitra-sandbox
```

#### 2.3 Update Flutter Firebase Configuration
```dart
// lib/firebase/firebase_options.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    final environment = AppConfig().environment;

    if (environment == 'sandbox') {
      return sandbox;
    }
    // ... other environments

    return sandbox; // default to sandbox
  }

  static const FirebaseOptions sandbox = FirebaseOptions(
    apiKey: 'your-sandbox-api-key',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'agentmitra-sandbox',
    storageBucket: 'agentmitra-sandbox.appspot.com',
    measurementId: 'G-ABCDEFGHIJ',
  );
}
```

### Step 3: Application Deployment

#### 3.1 Prepare Environment Variables
```bash
# Create .env.sandbox file
cat > .env.sandbox << EOF
# Application
APP_NAME=Agent Mitra Sandbox
ENVIRONMENT=sandbox
DEBUG=true

# Database (AWS RDS)
DATABASE_URL=postgresql://admin:password@agentmitra-db.xxxx.us-east-1.rds.amazonaws.com:5432/agentmitra_db

# Redis (AWS ElastiCache)
REDIS_URL=redis://agentmitra-cache.xxxx.ng.0001.use1.cache.amazonaws.com:6379

# AWS S3
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
MINIO_ENDPOINT=s3.amazonaws.com
MINIO_BUCKET_NAME=agentmitra-sandbox-media

# Firebase
FIREBASE_API_KEY=your-sandbox-api-key
FIREBASE_PROJECT_ID=agentmitra-sandbox
FIREBASE_APP_ID=1:123456789:web:abcdef123456
FIREBASE_MESSAGING_SENDER_ID=123456789

# Security
JWT_SECRET_KEY=$(openssl rand -hex 32)

# CORS (restrict to your domains)
CORS_ORIGINS=https://sandbox.agentmitra.com,https://app-sandbox.agentmitra.com
EOF
```

#### 3.2 Deploy to AWS Lightsail
```bash
# SSH into Lightsail instance
ssh -i ~/.ssh/lightsail-key.pem ubuntu@your-instance-ip

# Install Docker and dependencies
sudo apt update
sudo apt install -y docker.io docker-compose git

# Clone repository
git clone https://github.com/yourusername/agentmitra.git
cd agentmitra

# Copy environment file
cp .env.sandbox .env

# Build and start services
docker-compose -f docker-compose.sandbox.yml up -d --build
```

### Step 4: Domain & SSL Setup

#### 4.1 Configure Cloudflare
```bash
# Add domain to Cloudflare
# Point nameservers to Cloudflare

# Create DNS records
# A record: sandbox.agentmitra.com -> Lightsail IP
# CNAME: api.sandbox.agentmitra.com -> sandbox.agentmitra.com

# Enable SSL (Always Use HTTPS)
# SSL/TLS -> Overview -> Full (strict)
```

#### 4.2 SSL Certificate Setup
```bash
# SSL is handled by Cloudflare, but for direct connections:
sudo certbot --nginx -d sandbox.agentmitra.com -d api.sandbox.agentmitra.com
```

### Step 5: Cost Monitoring & Alerts

#### 5.1 AWS Cost Monitoring
```bash
# Set up billing alerts
aws budgets create-budget \
  --budget-name sandbox-budget \
  --budget-limit Amount=20,Unit=USD \
  --time-unit MONTHLY \
  --budget-type COST

# Enable Cost Explorer
aws ce create-cost-category-definition \
  --name sandbox-cost-tracking \
  --rule-version 1.0 \
  --rules '[{"value":"Sandbox","rule":{"tags":{"key":"Environment","values":["sandbox"]}}}]'
```

#### 5.2 Firebase Cost Monitoring
```bash
# Monitor Firebase usage
firebase projects:list --json | jq '.[] | select(.projectId=="agentmitra-sandbox")'

# Set up Firebase alerts in Console
# Go to Firebase Console -> Project Settings -> Integrations -> Cloud Monitoring
```

#### 5.3 Application-Level Cost Tracking
```dart
// lib/core/services/cost_monitor_service.dart
class CostMonitorService {
  // Track Firebase usage
  static void trackFirebaseUsage(String service, Map<String, dynamic> data) {
    if (!kReleaseMode) return; // Only track in production/sandbox

    firebaseAnalytics.logEvent(
      name: 'firebase_usage',
      parameters: {
        'service': service,
        'timestamp': DateTime.now().toIso8601String(),
        ...data,
      },
    );
  }

  // Track AWS resource usage
  static void trackAWSUsage(String service, Map<String, dynamic> data) {
    // Send to monitoring endpoint
    ApiService.post('/api/v1/monitoring/aws-usage', {
      'service': service,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

### Step 6: Team Access & Collaboration

#### 6.1 Development Environment Access

**Option A: GitHub Codespaces (Recommended)**
```yaml
# .devcontainer/devcontainer.json
{
  "name": "Agent Mitra Sandbox Development",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/flutter:latest": {},
    "ghcr.io/devcontainers/features/aws-cli:latest": {},
    "ghcr.io/devcontainers/features/docker-in-docker:latest": {}
  },
  "forwardPorts": [3000, 8000, 8080],
  "customizations": {
    "vscode": {
      "extensions": [
        "Dart-Code.flutter",
        "ms-vscode.vscode-json",
        "ms-vscode.vscode-yaml",
        "ms-azuretools.vscode-docker"
      ]
    }
  },
  "postCreateCommand": "flutter config --enable-web && flutter pub get"
}
```

**Option B: Local Development with Remote Backend**
```bash
# Connect to sandbox database
export DATABASE_URL="postgresql://admin:password@sandbox-db.xxxx.rds.amazonaws.com:5432/agentmitra_db"

# Run local backend
cd backend
python main.py

# Run local Flutter app
cd ..
flutter run --flavor sandbox
```

#### 6.2 Database Access for Team
```bash
# Create read-only database user
psql -h $DB_HOST -U admin -d agentmitra_db << EOF
CREATE USER team_member WITH PASSWORD 'secure_password';
GRANT CONNECT ON DATABASE agentmitra_db TO team_member;
GRANT USAGE ON SCHEMA public TO team_member;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO team_member;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO team_member;
EOF

# Team members can now connect with read-only access
psql -h $DB_HOST -U team_member -d agentmitra_db
```

#### 6.3 Shared File Storage
```bash
# Create shared S3 bucket policy
aws s3api create-bucket \
  --bucket agentmitra-sandbox-shared \
  --region us-east-1

# Set up bucket policy for team access
aws s3api put-bucket-policy \
  --bucket agentmitra-sandbox-shared \
  --policy file://policies/team-bucket-policy.json
```

### Step 7: Testing & Validation

#### 7.1 Automated Testing
```yaml
# .github/workflows/sandbox-tests.yml
name: Sandbox Tests
on:
  push:
    branches: [sandbox]
  pull_request:
    branches: [sandbox]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.13.x'
      - run: flutter test
      - run: flutter build apk --flavor sandbox

  api-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: |
          cd backend
          pip install -r requirements.txt
          python -m pytest tests/ -v
```

#### 7.2 Manual Testing Checklist
```markdown
## Sandbox Validation Checklist

### Backend Services
- [ ] API health endpoint: GET /health
- [ ] Database connection
- [ ] Redis cache operations
- [ ] File upload to S3
- [ ] Firebase token registration

### Frontend Applications
- [ ] Flutter web app loads
- [ ] Mobile app connects to sandbox API
- [ ] Authentication works
- [ ] Push notifications received
- [ ] File uploads/downloads work

### External Integrations
- [ ] Firebase FCM messages
- [ ] AWS S3 file operations
- [ ] Cloudflare SSL certificates
- [ ] Domain resolution
```

## Cost Optimization Strategies

### 1. Resource Right-Sizing
- Use Lightsail nano instance for development ($5/month)
- Scale to micro only when needed ($10/month)
- Use spot instances for testing environments

### 2. Firebase Cost Controls
```dart
// Implement usage throttling
class FirebaseThrottler {
  static final Map<String, DateTime> _lastCall = {};

  static bool canMakeCall(String operation, {Duration throttle = const Duration(seconds: 1)}) {
    final lastCall = _lastCall[operation];
    if (lastCall == null) {
      _lastCall[operation] = DateTime.now();
      return true;
    }

    final timeSinceLastCall = DateTime.now().difference(lastCall);
    if (timeSinceLastCall > throttle) {
      _lastCall[operation] = DateTime.now();
      return true;
    }

    return false;
  }
}
```

### 3. Automated Shutdown
```bash
# Schedule automatic shutdown for non-business hours
aws lightsail create-instance-snapshot \
  --instance-snapshot-name daily-backup \
  --instance-name agentmitra-sandbox

# Use Lambda to auto-stop/start instances
aws lambda create-function \
  --function-name sandbox-scheduler \
  --runtime python3.9 \
  --handler lambda_function.lambda_handler \
  --code file://scripts/aws/lambda-scheduler.zip
```

### 4. Monitoring & Alerts
```bash
# Set up cost anomaly detection
aws ce create-anomaly-monitor \
  --anomaly-monitor-name sandbox-cost-monitor \
  --type CUSTOM \
  --monitor-specification '{
    "Dimensions": {
      "Key": "SERVICE",
      "Values": ["Amazon Elastic Compute Cloud - Compute", "Amazon Relational Database Service"]
    }
  }'
```

## Migration to Production

### Phase 1: Environment Separation (Month 1-2)
- Duplicate sandbox configuration
- Create separate AWS account for production
- Implement proper CI/CD pipelines

### Phase 2: Scaling (Month 2-3)
- Implement load balancing
- Set up auto-scaling groups
- Add monitoring and alerting

### Phase 3: Optimization (Month 3+)
- Implement caching strategies
- Database query optimization
- CDN configuration for assets

## Troubleshooting

### Common Issues

#### Database Connection Issues
```bash
# Check RDS connectivity
telnet agentmitra-db.xxxx.rds.amazonaws.com 5432

# Verify security group rules
aws ec2 describe-security-groups --group-ids $SECURITY_GROUP_ID
```

#### Firebase Configuration Issues
```bash
# Verify Firebase project
firebase projects:list

# Check Firebase configuration
firebase use agentmitra-sandbox
firebase functions:list
```

#### SSL/Certificate Issues
```bash
# Check Cloudflare SSL status
curl -I https://sandbox.agentmitra.com

# Verify certificate
openssl s_client -connect sandbox.agentmitra.com:443 -servername sandbox.agentmitra.com
```

## Support & Maintenance

### Regular Tasks
- **Weekly**: Review AWS cost reports
- **Monthly**: Update dependencies and security patches
- **Quarterly**: Review and optimize resource allocation

### Backup Strategy
```bash
# Automated backups
aws backup create-backup-plan \
  --backup-plan file://backup-plan.json

# Database snapshots
aws rds create-db-snapshot \
  --db-instance-identifier agentmitra-db \
  --db-snapshot-identifier weekly-backup-$(date +%Y%m%d)
```

This sandbox setup provides a production-like environment while keeping costs under $15/month for the first 3 months, making it ideal for startup development and testing.
