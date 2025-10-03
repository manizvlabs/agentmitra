# Agent Mitra - Deployment Design & Infrastructure Architecture

## 1. Deployment Philosophy & Cost Optimization Strategy

### 1.1 Core Deployment Principles
- **Cost-Effective Scaling**: Start lean, scale intelligently based on user growth
- **Performance-First**: Maintain sub-200ms response times even during peak loads
- **Security-Compliance**: IRDAI and DPDP compliant infrastructure from day one
- **Developer Productivity**: Fast local development with production parity
- **Monitoring-Driven**: Comprehensive observability for proactive optimization

### 1.2 Cost Optimization Strategy

```
💰 COST OPTIMIZATION FRAMEWORK

🎯 Optimization Targets:
├── Infrastructure: 40% cost reduction through smart scaling
├── Database: 35% savings with efficient indexing and caching
├── CDN & Storage: 15% reduction via compression and lifecycle policies
└── Monitoring: 10% savings through targeted observability

📊 Scaling Strategy:
├── Phase 1 (MVP): 700 users, ₹15,000/month target
├── Phase 2 (Growth): 5,000 users, ₹45,000/month target
├── Phase 3 (Scale): 50,000 users, ₹150,000/month target
└── Phase 4 (Enterprise): 500,000 users, ₹450,000/month target

🔧 Cost Control Mechanisms:
├── Auto-scaling based on demand patterns
├── Reserved instances for predictable workloads
├── Spot instances for batch processing
├── Intelligent caching and CDN optimization
└── Database query optimization and indexing
```

## 2. Infrastructure Architecture (Cost-Optimized)

### 2.1 Overall Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT MITRA - CLOUD ARCHITECTURE             │
├─────────────────────────────────────────────────────────────────┤
│  🌐 GLOBAL LOAD BALANCER (AWS CloudFront)                      │
│  ├── CDN for static assets (Images, Videos, JS/CSS)           │
│  ├── SSL Termination & DDoS Protection                        │
│  └── Geographic routing for optimal performance               │
├─────────────────────────────────────────────────────────────────┤
│  🚀 APPLICATION LAYER (AWS ECS Fargate)                       │
│  ├── Flutter Mobile App (Client-side)                         │
│  ├── Python FastAPI Backend (Serverless)                      │
│  ├── WhatsApp Webhook Handler (Event-driven)                  │
│  ├── Video Processing Queue (Async)                           │
│  └── Real-time WebSocket Server (Live updates)                │
├─────────────────────────────────────────────────────────────────┤
│  💾 DATA LAYER (Multi-Region PostgreSQL + Redis)              │
│  ├── Primary DB: Aurora PostgreSQL (Auto-scaling)             │
│  ├── Read Replicas: 2 regions for performance                 │
│  ├── Redis Cluster: Session storage & caching                 │
│  └── Backup: Automated daily with 30-day retention           │
├─────────────────────────────────────────────────────────────────┤
│  🤖 AI/ML LAYER (Serverless Functions)                        │
│  ├── OpenAI API Integration (Chatbot responses)               │
│  ├── Video Analysis (Content moderation & tagging)            │
│  ├── Predictive Analytics (Churn & revenue forecasting)       │
│  └── Recommendation Engine (Personalized content)             │
├─────────────────────────────────────────────────────────────────┤
│  📊 ANALYTICS & MONITORING (Integrated Stack)                 │
│  ├── Application Performance Monitoring (APM)                 │
│  ├── Real User Monitoring (RUM)                              │
│  ├── Error Tracking & Alerting                               │
│  └── Business Intelligence Dashboard                         │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Cost-Optimized Infrastructure Components

#### AWS Service Selection (Cost-Focused)
```
💰 COST-EFFECTIVE AWS SERVICES

🏗️ Compute (40% of infra cost):
├── ECS Fargate: ₹8,000/month (Serverless containers)
├── Lambda: ₹2,000/month (Event-driven functions)
├── EC2 Reserved: ₹3,000/month (Predictable workloads)
└── Batch: ₹500/month (Video processing)

💾 Storage (25% of infra cost):
├── S3 Standard: ₹1,500/month (App assets)
├── S3 IA: ₹800/month (Infrequent access)
├── Aurora Serverless: ₹4,000/month (Database)
└── EFS: ₹1,000/month (Shared file storage)

🌐 Network & CDN (20% of infra cost):
├── CloudFront: ₹2,500/month (Global CDN)
├── Route 53: ₹200/month (DNS & routing)
├── ALB: ₹1,000/month (Load balancing)
└── NAT Gateway: ₹500/month (Outbound traffic)

📊 Monitoring (15% of infra cost):
├── CloudWatch: ₹800/month (Metrics & logs)
├── X-Ray: ₹400/month (Distributed tracing)
├── Sentry: ₹1,200/month (Error tracking)
└── Custom Dashboards: ₹600/month (Business metrics)

TOTAL MONTHLY ESTIMATE: ₹15,000 - ₹20,000
```

#### Multi-Region Deployment Strategy
```
🌍 MULTI-REGION DEPLOYMENT (HIGH AVAILABILITY)

📍 Primary Region: Asia Pacific (Mumbai) - ap-south-1
├── Closest to Indian users (Latency: <50ms)
├── Local compliance (IRDAI data residency)
├── Cost-effective for Indian traffic (90%)
└── Primary database and application servers

📍 Secondary Region: Asia Pacific (Singapore) - ap-southeast-1
├── Disaster recovery and failover
├── Global user support (10% international traffic)
├── Read replicas for performance
└── Backup and analytics processing

🔄 Cross-Region Features:
├── Database replication (Aurora Global Database)
├── CDN edge locations (CloudFront global distribution)
├── DNS failover (Route 53 health checks)
└── Monitoring and alerting (Multi-region CloudWatch)
```

## 3. Local Development Environment Setup

### 3.1 MacBook Development Environment

#### Hardware Requirements
```
💻 MACBOOK DEVELOPMENT SETUP

🖥️ Minimum Specifications:
├── MacBook Pro M1/M2 (8GB RAM, 256GB SSD)
├── macOS Monterey or later
├── Xcode 14+ (iOS development)
├── Android Studio (Android development)
└── Docker Desktop for Mac (Container development)

📦 Development Tools:
├── Flutter SDK (Latest stable)
├── Python 3.11+ (Backend development)
├── Node.js 18+ (Build tools)
├── Git & GitHub Desktop (Version control)
└── VS Code + Extensions (Primary IDE)
```

#### Local Development Stack
```bash
# Local development environment setup
/local-development/
├── docker-compose.yml          # Local services orchestration
├── flutter-app/               # Mobile app source code
├── python-backend/            # FastAPI application
├── postgres-local/            # Local PostgreSQL database
├── redis-local/               # Local Redis cache
├── nginx-local/               # Local reverse proxy
└── monitoring-local/          # Local monitoring setup
```

#### One-Click Local Setup Script
```bash
#!/bin/bash
# setup-local-environment.sh

echo "🚀 Setting up Agent Mitra local development environment..."

# 1. Install Dependencies
brew install flutter python@3.11 postgresql redis nginx docker

# 2. Setup Flutter
flutter doctor
flutter pub get

# 3. Setup Python Backend
cd python-backend
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# 4. Start Local Services
docker-compose up -d postgres redis nginx

# 5. Run Database Migrations
python manage.py migrate

# 6. Start Development Servers
flutter run -d ios    # iOS development
# OR
flutter run -d android # Android development

# 7. Backend Development Server
uvicorn main:app --reload --host 0.0.0.0 --port 8000

echo "✅ Local development environment ready!"
echo "📱 Flutter app: http://localhost:3000"
echo "🔗 Backend API: http://localhost:8000"
echo "📊 Database: postgresql://localhost:5432/agent_mitra"
```

### 3.2 Development Workflow & Tools

#### Version Control Strategy
```
🔄 GIT WORKFLOW STRATEGY

🌿 Branch Structure:
├── main (Production-ready code)
├── develop (Integration branch)
├── feature/* (New features)
├── bugfix/* (Bug fixes)
├── hotfix/* (Critical fixes)
└── release/* (Release preparation)

📝 Commit Conventions:
├── feat: New feature implementation
├── fix: Bug fix
├── docs: Documentation updates
├── style: Code style changes
├── refactor: Code refactoring
├── test: Test additions/modifications
└── chore: Maintenance tasks

🔄 Pull Request Process:
├── Code review by senior developers
├── Automated testing (Unit + Integration)
├── Security scanning (SAST/DAST)
├── Performance testing (Load testing)
└── Manual QA verification
```

#### Development Tools & IDE Setup
```
🛠️ DEVELOPMENT TOOL STACK

📱 Flutter Development:
├── Flutter SDK (Latest stable)
├── Dart DevTools (Performance profiling)
├── Flutter Inspector (UI debugging)
├── Device Preview (Multi-device testing)
└── Flutter Analyze (Code quality)

🔧 Backend Development:
├── Python 3.11+ (Primary language)
├── FastAPI (Web framework)
├── SQLAlchemy (ORM)
├── Alembic (Database migrations)
├── Pytest (Testing framework)
└── Black/Flake8 (Code formatting)

📊 Database Development:
├── PostgreSQL 15+ (Primary database)
├── pgAdmin (Database management)
├── DBeaver (Query development)
├── Redis (Caching and sessions)
└── Elasticsearch (Search and analytics)

🔍 Testing & Quality:
├── Jest (Unit testing)
├── Cypress (E2E testing)
├── SonarQube (Code quality)
├── Lighthouse (Performance auditing)
└── OWASP ZAP (Security testing)
```

## 4. Production Deployment Strategy

### 4.1 Production Infrastructure Setup

#### AWS Infrastructure as Code (IaC)
```yaml
# AWS CDK Infrastructure Definition
# infrastructure/lib/agent-mitra-stack.ts

import * as cdk from 'aws-cdk-lib';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as rds from 'aws-cdk-lib/aws-rds';
import * as elasticache from 'aws-cdk-lib/aws-elasticache';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';

export class AgentMitraStack extends cdk.Stack {
  constructor(scope: cdk.App, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // 1. Aurora PostgreSQL Database (Serverless)
    const database = new rds.DatabaseCluster(this, 'AgentMitraDB', {
      engine: rds.DatabaseClusterEngine.auroraPostgres({
        version: rds.AuroraPostgresEngineVersion.VER_15_3
      }),
      serverlessV2MinCapacity: 0.5,
      serverlessV2MaxCapacity: 4,
      writer: rds.ClusterInstance.serverlessV2('writer'),
      readers: [
        rds.ClusterInstance.serverlessV2('reader1'),
        rds.ClusterInstance.serverlessV2('reader2')
      ],
      backup: {
        retention: cdk.Duration.days(30),
        preferredWindow: '03:00-04:00'
      }
    });

    // 2. Redis Cluster for Caching
    const cache = new elasticache.CfnServerlessCache(this, 'AgentMitraCache', {
      engine: 'redis',
      serverlessCacheName: 'agent-mitra-cache'
    });

    // 3. ECS Fargate Cluster
    const cluster = new ecs.Cluster(this, 'AgentMitraCluster', {
      clusterName: 'agent-mitra-cluster'
    });

    // 4. Application Load Balancer
    const loadBalancer = new elbv2.ApplicationLoadBalancer(this, 'AgentMitraALB', {
      loadBalancerName: 'agent-mitra-alb',
      internetFacing: true,
      vpcSubnets: { subnetType: ec2.SubnetType.PUBLIC }
    });

    // 5. CloudFront CDN
    const cdn = new cloudfront.Distribution(this, 'AgentMitraCDN', {
      defaultBehavior: {
        origin: new origins.LoadBalancerV2Origin(loadBalancer),
        cachePolicy: cloudfront.CachePolicy.CACHING_OPTIMIZED,
        compress: true
      }
    });
  }
}
```

### 4.2 Deployment Pipeline (CI/CD)

#### Automated Deployment Pipeline
```
🚀 CI/CD PIPELINE ARCHITECTURE

🔧 Build Stage (GitHub Actions):
├── Code Quality Checks (ESLint, Prettier, SonarQube)
├── Unit Tests (Jest, Pytest)
├── Integration Tests (Database, API endpoints)
├── Security Scanning (SAST, Dependency checks)
└── Build Artifacts (Flutter APK/AAB, Docker images)

📦 Container Stage:
├── Multi-stage Docker builds (Development/Production)
├── Security scanning (Trivy, Docker Scout)
├── Vulnerability assessment (Grype)
└── Image signing and attestation

🚀 Deployment Stage:
├── Blue-Green deployments (Zero-downtime)
├── Database migrations (Automated rollbacks)
├── Feature flag updates (Gradual rollouts)
├── Performance testing (Load and stress tests)
└── Monitoring setup (Metrics and alerting)

🔍 Post-Deployment:
├── Health checks (API endpoints, database connectivity)
├── Performance validation (Response times, error rates)
├── User acceptance testing (Automated smoke tests)
└── Rollback capability (If issues detected)
```

#### Deployment Configuration
```yaml
# GitHub Actions Workflow
# .github/workflows/deploy.yml

name: Deploy to Production
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production

    steps:
      - uses: actions/checkout@v3

      # 1. Build and Test
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test

      # 2. Build Application
      - name: Build Flutter app
        run: flutter build apk --release

      # 3. Deploy to AWS
      - name: Deploy to ECS
        uses: aws-actions/amazon-ecs-deploy-task-definition@v1
        with:
          task-definition: agent-mitra-task
          service: agent-mitra-service
          cluster: agent-mitra-cluster

      # 4. Database Migration
      - name: Run migrations
        run: python manage.py migrate

      # 5. Health Check
      - name: Verify deployment
        run: curl -f https://api.agentmitra.com/health
```

### 4.3 Monitoring & Observability Setup

#### Comprehensive Monitoring Stack
```
📊 MONITORING & OBSERVABILITY ARCHITECTURE

🎯 Application Performance Monitoring (APM):
├── New Relic (Application performance)
├── DataDog (Infrastructure monitoring)
├── Sentry (Error tracking and alerting)
└── Grafana (Custom dashboards and visualization)

📈 Business Intelligence:
├── Mixpanel (User behavior analytics)
├── Amplitude (Product analytics)
├── Hotjar (User experience insights)
└── Google Analytics (Marketing attribution)

🔍 Security Monitoring:
├── AWS GuardDuty (Threat detection)
├── AWS Security Hub (Security posture)
├── CloudTrail (API activity logging)
└── Custom SIEM (Security events correlation)

💰 Cost Monitoring:
├── AWS Cost Explorer (Cost analysis)
├── CloudWatch Cost and Usage Reports
├── Custom cost dashboards (Business-specific)
└── Budget alerts and anomaly detection
```

#### Alert Configuration
```yaml
# Alert Rules Configuration
# monitoring/alerts.yml

critical_alerts:
  - name: "API Response Time > 500ms"
    condition: "response_time_p95 > 500"
    channels: ["slack", "email", "sms"]
    escalation: "5 minutes"

  - name: "Database Connection Failures"
    condition: "db_connection_errors > 5"
    channels: ["slack", "pagerduty"]
    escalation: "immediate"

warning_alerts:
  - name: "High Memory Usage (>80%)"
    condition: "memory_usage > 80"
    channels: ["slack"]
    escalation: "15 minutes"

  - name: "Payment Failure Rate (>5%)"
    condition: "payment_failures > 0.05"
    channels: ["email", "slack"]
    escalation: "30 minutes"

info_alerts:
  - name: "New User Registration Spike"
    condition: "new_users > 100"
    channels: ["slack"]
    escalation: "none"
```

## 5. Database Architecture & Design

### 5.1 Database Design Philosophy

#### Multi-Tenant Architecture
```
🏢 MULTI-TENANT DATABASE DESIGN

🎯 Tenant Isolation Strategy:
├── Separate Databases (Strong isolation)
├── Shared Database with tenant_id (Cost-effective)
├── Schema-based separation (Balanced approach)
└── Row-level security (Granular access control)

📊 Scaling Strategy:
├── Read Replicas (Performance optimization)
├── Partitioning (Large dataset management)
├── Indexing (Query performance)
└── Caching (Response time optimization)
```

#### Data Modeling Principles
```
📋 DATABASE DESIGN PRINCIPLES

🔒 Security-First Design:
├── Encryption at rest (AES-256)
├── Row-level security (RLS)
├── Audit logging (All data changes)
└── GDPR/DPDP compliance (Data retention)

⚡ Performance-Optimized:
├── Proper indexing (Composite indexes)
├── Query optimization (EXPLAIN ANALYZE)
├── Caching strategies (Redis integration)
└── Connection pooling (Efficient resource usage)

📈 Scalability-Focused:
├── Horizontal partitioning (Sharding ready)
├── Read/write splitting (Replica optimization)
├── Time-based partitioning (Historical data)
└── Compression (Storage optimization)
```

### 5.2 Core Database Schema Design

#### User Management Tables
```sql
-- Users table (Multi-tenant user management)
CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL,
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(15) UNIQUE,
    password_hash VARCHAR(255),
    role user_role_enum NOT NULL, -- policyholder, agent, provider_admin, super_admin
    status user_status_enum DEFAULT 'active',
    mfa_enabled BOOLEAN DEFAULT false,
    biometric_enabled BOOLEAN DEFAULT false,
    trial_end_date TIMESTAMP,
    subscription_plan VARCHAR(50),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- User Sessions table (JWT token management)
CREATE TABLE user_sessions (
    session_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    access_token_hash VARCHAR(255),
    refresh_token_hash VARCHAR(255),
    device_info JSONB,
    ip_address INET,
    expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- User Permissions table (RBAC implementation)
CREATE TABLE user_permissions (
    permission_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    permission_name VARCHAR(100),
    resource_type VARCHAR(50),
    resource_id UUID,
    granted_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    granted_by UUID REFERENCES users(user_id)
);
```

#### Insurance Policy Management Tables
```sql
-- Insurance Providers table (Multi-provider support)
CREATE TABLE insurance_providers (
    provider_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_code VARCHAR(20) UNIQUE NOT NULL, -- LIC, STAR_HEALTH, etc.
    provider_name VARCHAR(255) NOT NULL,
    provider_type VARCHAR(50), -- LIFE, HEALTH, GENERAL
    api_endpoint VARCHAR(500),
    api_credentials JSONB,
    status provider_status_enum DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Agents table (Insurance agent management)
CREATE TABLE agents (
    agent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    provider_id UUID REFERENCES insurance_providers(provider_id),
    agent_code VARCHAR(50) UNIQUE,
    license_number VARCHAR(100),
    territory VARCHAR(255),
    commission_rate DECIMAL(5,2),
    whatsapp_business_number VARCHAR(15),
    status agent_status_enum DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Policyholders table (Customer management)
CREATE TABLE policyholders (
    policyholder_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    agent_id UUID REFERENCES agents(agent_id),
    provider_id UUID REFERENCES insurance_providers(provider_id),
    customer_id VARCHAR(100), -- Provider-specific customer ID
    risk_profile JSONB,
    communication_preferences JSONB,
    language_preference VARCHAR(10) DEFAULT 'en',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insurance Policies table (Policy management)
CREATE TABLE insurance_policies (
    policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_number VARCHAR(100) UNIQUE NOT NULL,
    policyholder_id UUID REFERENCES policyholders(policyholder_id),
    agent_id UUID REFERENCES agents(agent_id),
    provider_id UUID REFERENCES insurance_providers(provider_id),
    policy_type VARCHAR(100),
    plan_name VARCHAR(255),
    sum_assured DECIMAL(15,2),
    premium_amount DECIMAL(12,2),
    premium_frequency VARCHAR(20), -- MONTHLY, QUARTERLY, ANNUAL
    start_date DATE,
    maturity_date DATE,
    status policy_status_enum DEFAULT 'active',
    policy_document_url VARCHAR(500),
    nominee_details JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### Content Management Tables
```sql
-- Video Content table (Agent educational content)
CREATE TABLE video_content (
    video_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES agents(agent_id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url VARCHAR(500) NOT NULL, -- YouTube URL
    thumbnail_url VARCHAR(500),
    duration_seconds INTEGER,
    category video_category_enum,
    tags TEXT[],
    language VARCHAR(10) DEFAULT 'en',
    difficulty_level VARCHAR(20),
    target_audience VARCHAR(50)[],
    view_count INTEGER DEFAULT 0,
    avg_watch_time DECIMAL(6,2),
    completion_rate DECIMAL(5,2),
    rating DECIMAL(3,2),
    status content_status_enum DEFAULT 'published',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Chatbot Knowledge Base table (FAQ and Q&A)
CREATE TABLE chatbot_knowledge_base (
    kb_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category VARCHAR(100),
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    intent VARCHAR(100),
    entities JSONB,
    language VARCHAR(10) DEFAULT 'en',
    usage_count INTEGER DEFAULT 0,
    accuracy_score DECIMAL(3,2),
    last_updated TIMESTAMP DEFAULT NOW()
);

-- WhatsApp Templates table (Message templates)
CREATE TABLE whatsapp_templates (
    template_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_name VARCHAR(100) UNIQUE NOT NULL,
    category template_category_enum,
    language VARCHAR(10) DEFAULT 'en',
    content TEXT NOT NULL,
    variables JSONB,
    status template_status_enum DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Analytics & Business Intelligence Tables
```sql
-- Customer Analytics table (Behavioral data)
CREATE TABLE customer_analytics (
    analytics_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    event_type VARCHAR(100) NOT NULL,
    event_data JSONB,
    session_id VARCHAR(255),
    timestamp TIMESTAMP DEFAULT NOW(),
    device_info JSONB,
    location_info JSONB
);

-- Agent Performance table (Business metrics)
CREATE TABLE agent_performance (
    performance_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES agents(agent_id),
    metric_name VARCHAR(100) NOT NULL,
    metric_value DECIMAL(15,4),
    metric_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- System Audit Logs table (Compliance and security)
CREATE TABLE audit_logs (
    log_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(user_id),
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(50),
    resource_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    timestamp TIMESTAMP DEFAULT NOW()
);
```

### 5.3 Database Performance Optimization

#### Indexing Strategy
```sql
-- Performance-critical indexes
CREATE INDEX idx_users_tenant_status ON users(tenant_id, status);
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_policies_policyholder_status ON insurance_policies(policyholder_id, status);
CREATE INDEX idx_policies_agent_provider ON insurance_policies(agent_id, provider_id);
CREATE INDEX idx_analytics_user_timestamp ON customer_analytics(user_id, timestamp DESC);
CREATE INDEX idx_performance_agent_date ON agent_performance(agent_id, metric_date DESC);

-- Composite indexes for complex queries
CREATE INDEX idx_policies_comprehensive ON insurance_policies(
    provider_id, agent_id, status, premium_amount, maturity_date
);

-- Partial indexes for specific use cases
CREATE INDEX idx_active_policies ON insurance_policies(policy_number)
WHERE status = 'active';

-- JSONB indexes for flexible queries
CREATE INDEX idx_policy_nominee ON insurance_policies USING GIN((nominee_details->'name'));
```

#### Partitioning Strategy
```sql
-- Time-based partitioning for analytics data
CREATE TABLE customer_analytics_partitioned (
    LIKE customer_analytics INCLUDING ALL
) PARTITION BY RANGE (timestamp);

-- Create partitions for each month
CREATE TABLE customer_analytics_2024_01 PARTITION OF customer_analytics_partitioned
FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');

CREATE TABLE customer_analytics_2024_02 PARTITION OF customer_analytics_partitioned
FOR VALUES FROM ('2024-02-01') TO ('2024-03-01');

-- Provider-based partitioning for multi-tenant isolation
CREATE TABLE insurance_policies_partitioned (
    LIKE insurance_policies INCLUDING ALL
) PARTITION BY LIST (provider_id);
```

## 6. Required Subscriptions, Tools & Software

### 6.1 Production Subscriptions & Services

#### Essential Subscriptions (Monthly Cost Estimate)
```
💳 PRODUCTION SUBSCRIPTION REQUIREMENTS

🔐 Security & Compliance:
├── AWS WAF (₹2,000/month) - DDoS protection
├── AWS GuardDuty (₹1,500/month) - Threat detection
├── AWS Security Hub (₹800/month) - Security posture
├── SSL Certificate (₹5,000/year) - HTTPS encryption
└── Domain Registration (₹800/year) - agentmitra.com

📊 Monitoring & Analytics:
├── New Relic (₹8,000/month) - APM and monitoring
├── Sentry (₹3,000/month) - Error tracking
├── Mixpanel (₹5,000/month) - User analytics
├── CloudWatch (₹2,000/month) - AWS monitoring
└── Grafana Cloud (₹1,500/month) - Dashboard hosting

🤖 AI/ML Services:
├── OpenAI API (₹15,000/month) - Chatbot and analytics
├── Perplexity API (₹8,000/month) - Enhanced search
├── AWS Comprehend (₹1,000/month) - Text analysis
└── Custom ML Models (₹3,000/month) - Predictive analytics

📱 Communication Services:
├── WhatsApp Business API (₹5,000/month) - Business messaging
├── Twilio (₹2,000/month) - SMS and voice (backup)
├── SendGrid (₹1,500/month) - Email delivery
└── Push Notifications (₹500/month) - Mobile app notifications

🎥 Content & Media:
├── YouTube API (₹2,000/month) - Video integration
├── AWS Elemental MediaConvert (₹1,000/month) - Video processing
├── AWS S3 (₹1,500/month) - File storage
└── CloudFront CDN (₹2,500/month) - Content delivery

💾 Database & Storage:
├── Aurora PostgreSQL (₹4,000/month) - Primary database
├── Redis ElastiCache (₹1,500/month) - Caching layer
├── Database Backups (₹500/month) - Automated backups
└── Archive Storage (₹300/month) - Long-term retention

TOTAL MONTHLY SUBSCRIPTION COST: ₹45,000 - ₹55,000
```

### 6.2 Development Tools & Software

#### One-Time Purchase Software
```
🛠️ DEVELOPMENT SOFTWARE (One-time purchases)

💻 Development IDEs:
├── Visual Studio Code (Free) - Primary code editor
├── Android Studio (Free) - Android development
├── Xcode (Free) - iOS development
└── pgAdmin (Free) - Database management

🗂️ Version Control & Collaboration:
├── Git (Free) - Version control system
├── GitHub Enterprise (₹150,000/year) - Private repositories
└── GitHub Copilot (₹800/month) - AI code completion

📊 Database & Analytics Tools:
├── DBeaver (Free) - Universal database tool
├── Postman (Free) - API testing and documentation
├── Draw.io (Free) - Architecture diagramming
└── Lucidchart (₹6,000/year) - Professional diagramming

🧪 Testing & Quality Tools:
├── BrowserStack (₹15,000/month) - Cross-device testing
├── LoadRunner (₹200,000/year) - Performance testing
├── SonarQube (₹100,000/year) - Code quality
└── OWASP ZAP (Free) - Security testing

📱 Mobile Development Tools:
├── Flutter SDK (Free) - Cross-platform framework
├── Firebase (Free tier) - Backend services
├── App Store Connect (₹8,000/year) - iOS publishing
└── Google Play Console (₹2,000/year) - Android publishing

🎨 Design & UX Tools:
├── Figma (₹10,000/year) - UI/UX design
├── Adobe Creative Suite (₹40,000/year) - Asset creation
└── Zeplin (₹8,000/year) - Design handoff

TOTAL ONE-TIME SOFTWARE COST: ₹50,000 - ₹80,000
```

#### Open Source Alternatives (Cost-Free)
```
🔓 OPEN SOURCE ALTERNATIVES

📊 Monitoring & Observability:
├── Prometheus (Free) - Metrics collection
├── Grafana (Free) - Dashboard visualization
├── ELK Stack (Free) - Log aggregation
└── Jaeger (Free) - Distributed tracing

🗂️ Version Control:
├── GitLab CE (Free) - Self-hosted Git platform
├── Gitea (Free) - Lightweight Git service

💾 Database Tools:
├── PostgreSQL (Free) - Primary database
├── Redis (Free) - Caching and sessions
├── MongoDB (Free) - Document database (optional)

🔒 Security Tools:
├── OWASP ZAP (Free) - Web application security
├── sqlmap (Free) - Database security testing
└── nikto (Free) - Web server security scanning

🧪 Testing Tools:
├── Jest (Free) - JavaScript testing framework
├── Pytest (Free) - Python testing framework
├── Selenium (Free) - Browser automation
└── Appium (Free) - Mobile app testing

📱 Development Tools:
├── Flutter (Free) - Cross-platform framework
├── FastAPI (Free) - Python web framework
├── Docker (Free) - Container platform
└── Kubernetes (Free) - Container orchestration

🎨 Design Tools:
├── Penpot (Free) - Open source design tool
├── Inkscape (Free) - Vector graphics editor
└── GIMP (Free) - Image manipulation
```

## 7. Local vs Production Environment Comparison

### 7.1 Environment Specifications

#### Local Development Environment (MacBook)
```
💻 LOCAL DEVELOPMENT (MacBook Pro M2)

🖥️ Hardware Specifications:
├── MacBook Pro M2 (16GB RAM, 512GB SSD)
├── Processor: Apple M2 (8-core CPU, 10-core GPU)
├── Memory: 16GB Unified Memory
├── Storage: 512GB SSD
└── Display: 16-inch Retina display

📦 Local Services (Docker Containers):
├── PostgreSQL 15 (Database)
├── Redis 7 (Caching)
├── Nginx (Reverse proxy)
├── Elasticsearch (Search)
└── MinIO (Object storage)

🔧 Development Tools:
├── Flutter SDK (Latest)
├── Python 3.11 (Backend)
├── Node.js 18 (Build tools)
├── Git & GitHub Desktop
└── VS Code with extensions

⚡ Performance Characteristics:
├── Database Response: <10ms (Local)
├── API Response: <50ms (Local)
├── Build Time: 2-3 minutes (Flutter)
├── Test Execution: 30-60 seconds
└── Memory Usage: 8-12GB during development
```

#### Production Environment (AWS)
```
☁️ PRODUCTION ENVIRONMENT (AWS Cloud)

🏗️ Infrastructure Scale:
├── ECS Fargate: 4-8 vCPU containers
├── Aurora PostgreSQL: 2-16 ACUs (Auto-scaling)
├── Redis ElastiCache: 2-8 nodes cluster
├── CloudFront: Global CDN with 310+ PoPs
└── Route 53: Global DNS with health checks

📊 Production Services:
├── Load Balancer (ALB): 4-8 instances
├── Auto Scaling Groups: 2-10 instances
├── Read Replicas: 2-4 database replicas
├── CDN Edge Locations: 50+ global locations
└── Monitoring Stack: 10+ services

⚡ Performance Characteristics:
├── Database Response: <20ms (Primary region)
├── API Response: <100ms (Global average)
├── CDN Response: <50ms (Global)
├── Uptime: 99.9% SLA
└── Concurrent Users: 10,000+ (Horizontal scaling)
```

### 7.2 Environment Configuration Management

#### Environment Variables Management
```bash
# Environment configuration
# .env.local (Local development)
DATABASE_URL=postgresql://localhost:5432/agent_mitra_local
REDIS_URL=redis://localhost:6379
AWS_ACCESS_KEY_ID=local_dev_key
AWS_SECRET_ACCESS_KEY=local_dev_secret
OPENAI_API_KEY=your_openai_key
WHATSAPP_ACCESS_TOKEN=your_whatsapp_token

# .env.production (Production deployment)
DATABASE_URL=postgresql://prod-db-host:5432/agent_mitra_prod
REDIS_URL=redis://prod-redis-cluster:6379
AWS_ACCESS_KEY_ID=prod_access_key
AWS_SECRET_ACCESS_KEY=prod_secret_key
OPENAI_API_KEY=prod_openai_key
WHATSAPP_ACCESS_TOKEN=prod_whatsapp_token
```

#### Configuration Management Strategy
```
⚙️ CONFIGURATION MANAGEMENT

📝 Environment-Specific Config:
├── Development (Local): Fast refresh, debug logging
├── Staging (Pre-production): Production-like, test data
├── Production (Live): Optimized, monitoring enabled

🔧 Feature Flags:
├── Database-driven configuration
├── Real-time flag updates
├── Gradual rollout capabilities
└── Emergency kill switches

🌐 Localization:
├── CDN-hosted translation files
├── Runtime language switching
├── Fallback language support
└── Translation management interface

📊 Monitoring Configuration:
├── Log levels (DEBUG/STAGING/PRODUCTION)
├── Metric collection settings
├── Alert thresholds
└── Performance profiling
```

## 8. Implementation Roadmap & Cost Projections

### 8.1 Phased Implementation Plan

#### Phase 1: MVP Infrastructure (₹15,000/month)
```
🚀 PHASE 1: MINIMUM VIABLE INFRASTRUCTURE

💰 Monthly Cost Breakdown:
├── AWS ECS Fargate: ₹8,000 (Application hosting)
├── Aurora PostgreSQL: ₹4,000 (Database)
├── Redis ElastiCache: ₹1,500 (Caching)
├── CloudFront CDN: ₹2,500 (Content delivery)
├── Route 53 DNS: ₹200 (Domain management)
└── Monitoring Basic: ₹800 (Essential monitoring)

🎯 Deliverables:
├── Flutter mobile app (iOS + Android)
├── Basic authentication (OTP + Biometric)
├── Policy management (CRUD operations)
├── WhatsApp integration (Basic messaging)
├── Video upload (YouTube integration)
└── Customer dashboard (Essential metrics)

📈 Expected Performance:
├── Response Time: <200ms average
├── Concurrent Users: 1,000
├── Uptime: 99.5%
└── Monthly Active Users: 700 (Target)
```

#### Phase 2: Growth Infrastructure (₹45,000/month)
```
📈 PHASE 2: SCALED INFRASTRUCTURE

💰 Monthly Cost Breakdown:
├── AWS ECS Fargate: ₹20,000 (Increased capacity)
├── Aurora PostgreSQL: ₹8,000 (Read replicas)
├── Redis ElastiCache: ₹3,000 (Cluster mode)
├── CloudFront CDN: ₹5,000 (Global distribution)
├── Load Balancer: ₹2,000 (High availability)
├── Monitoring Advanced: ₹4,000 (APM + Analytics)
└── AI/ML Services: ₹3,000 (OpenAI + Custom models)

🎯 Deliverables:
├── Advanced analytics (Predictive modeling)
├── Real-time dashboards (WebSocket updates)
├── Marketing automation (Campaign management)
├── Multi-tenant features (Provider management)
├── Advanced chatbot (NLP capabilities)
└── Video recommendation engine (AI-powered)

📈 Expected Performance:
├── Response Time: <150ms average
├── Concurrent Users: 5,000
├── Uptime: 99.9%
└── Monthly Active Users: 5,000
```

#### Phase 3: Enterprise Infrastructure (₹150,000/month)
```
🏢 PHASE 3: ENTERPRISE-SCALE INFRASTRUCTURE

💰 Monthly Cost Breakdown:
├── AWS ECS Fargate: ₹60,000 (Multi-region deployment)
├── Aurora PostgreSQL: ₹25,000 (Global database)
├── Redis ElastiCache: ₹10,000 (Multi-region cluster)
├── CloudFront CDN: ₹15,000 (Enterprise CDN)
├── Load Balancer: ₹8,000 (Global load balancing)
├── Monitoring Enterprise: ₹15,000 (Full observability)
├── AI/ML Services: ₹12,000 (Advanced ML models)
└── Security Services: ₹5,000 (Enterprise security)

🎯 Deliverables:
├── Global multi-region deployment
├── Advanced security (Zero-trust architecture)
├── Enterprise integrations (ERP, CRM systems)
├── Advanced compliance (IRDAI enterprise features)
├── Real-time collaboration features
└── Advanced business intelligence

📈 Expected Performance:
├── Response Time: <100ms average
├── Concurrent Users: 50,000
├── Uptime: 99.95%
└── Monthly Active Users: 50,000
```

### 8.2 Cost Optimization Strategies

#### Intelligent Cost Management
```
💡 COST OPTIMIZATION TECHNIQUES

🔧 Infrastructure Optimization:
├── Right-sizing instances (CPU/Memory optimization)
├── Auto-scaling policies (Demand-based scaling)
├── Reserved instances (1-3 year commitments)
├── Spot instances (Batch processing workloads)

💾 Storage Optimization:
├── S3 lifecycle policies (Archive old data)
├── Database compression (Table compression)
├── CDN optimization (Cache hit ratio >95%)
├── Data deduplication (Remove redundant data)

🌐 Network Optimization:
├── CDN edge caching (Reduce origin requests)
├── Compression (Gzip/Brotli for all responses)
├── Request optimization (Minimize API calls)
├── WebSocket optimization (Efficient real-time updates)

📊 Monitoring-Driven Optimization:
├── Performance monitoring (Identify bottlenecks)
├── Cost monitoring (Track spending patterns)
├── Usage analytics (Understand user behavior)
├── Predictive scaling (Anticipate demand spikes)
```

#### Automated Cost Controls
```python
# Cost optimization automation
class CostOptimizer:
    async def optimize_infrastructure(self):
        # 1. Analyze current usage patterns
        usage_data = await self.get_usage_metrics()

        # 2. Identify optimization opportunities
        optimizations = await self.identify_optimizations(usage_data)

        # 3. Apply optimizations automatically
        for optimization in optimizations:
            await self.apply_optimization(optimization)

        # 4. Monitor and validate improvements
        await self.validate_optimizations()

    async def apply_optimization(self, optimization):
        if optimization.type == "right_sizing":
            await self.resize_instances(optimization.instances)
        elif optimization.type == "auto_scaling":
            await self.update_scaling_policies(optimization.policies)
        elif optimization.type == "reserved_instances":
            await self.purchase_reserved_capacity(optimization.requirements)
```

This deployment design provides a comprehensive, cost-effective, and scalable infrastructure for Agent Mitra while ensuring high performance, security compliance, and excellent developer experience. The architecture supports your growth from 700 users to enterprise scale while maintaining cost efficiency through intelligent optimization strategies.

**Ready for your review! Please let me know if you'd like me to proceed with the remaining deliverables or make any adjustments to this deployment design.**
