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

```mermaid
---
config:
  layout: elk
---
flowchart LR
 subgraph subGraph0["📱 End Users"]
        Mobile["Flutter Mobile App<br>iOS + Android"]
        WhatsApp["WhatsApp Business<br>Customer Communication"]
  end
 subgraph subGraph1["🌐 Global Edge (CloudFront)"]
        CDN["CloudFront CDN<br>Global Distribution<br>310+ Edge Locations"]
        WAF["WAF &amp; Shield<br>DDoS Protection<br>SSL Termination"]
        Route53["Route 53<br>Global DNS<br>Health Checks"]
  end
 subgraph Microservices["Microservices"]
        API["FastAPI Backend<br>REST APIs<br>GraphQL"]
        Chatbot["Chatbot Service<br>NLP Processing<br>Intent Recognition"]
        WhatsAppSvc["WhatsApp Service<br>Message Processing<br>Template Management"]
        VideoSvc["Video Processing<br>Content Moderation<br>YouTube Integration"]
        RealtimeSvc["WebSocket Server<br>Real-time Updates<br>Live Dashboards"]
  end
 subgraph subGraph3["🚀 Application Layer (ECS Fargate)"]
        ALB["Application Load Balancer<br>Auto Scaling<br>SSL Termination"]
        Microservices
  end
 subgraph subGraph4["🤖 AI/ML Layer (Lambda + External APIs)"]
        OpenAI["OpenAI API<br>Chatbot Responses<br>Content Generation"]
        Perplexity["Perplexity API<br>Enhanced Search<br>Knowledge Base"]
        AWSComprehend["AWS Comprehend<br>Text Analysis<br>Sentiment Analysis"]
        CustomML["Custom ML Models<br>Predictive Analytics<br>Recommendation Engine"]
  end
 subgraph subGraph5["Primary Region (Mumbai)"]
        AuroraPrimary["Aurora PostgreSQL<br>Primary DB<br>Auto-scaling"]
        RedisPrimary["Redis Cluster<br>Session Cache<br>Application Cache"]
  end
 subgraph subGraph6["Secondary Region (Singapore)"]
        AuroraReplica["Aurora Read Replicas<br>Performance Optimization<br>Disaster Recovery"]
        RedisReplica["Redis Replica<br>Global Cache<br>Failover Support"]
  end
 subgraph subGraph7["💾 Data Layer (Multi-Region)"]
        subGraph5
        subGraph6
        S3["S3 Storage<br>File Storage<br>CDN Origin<br>Lifecycle Policies"]
  end
 subgraph subGraph8["📊 Monitoring & Analytics"]
        CloudWatch["CloudWatch<br>Metrics &amp; Logs<br>Custom Dashboards"]
        NewRelic["New Relic APM<br>Performance Monitoring<br>Distributed Tracing"]
        Sentry["Sentry<br>Error Tracking<br>Release Health"]
        Mixpanel["Mixpanel<br>User Analytics<br>Behavioral Insights"]
  end
    Mobile --> CDN
    WhatsApp --> WhatsAppSvc
    CDN --> WAF
    WAF --> ALB
    ALB --> API & Chatbot & WhatsAppSvc & VideoSvc & RealtimeSvc
    API --> AuroraPrimary & RedisPrimary & S3 & CloudWatch
    Chatbot --> OpenAI & Perplexity & CloudWatch
    VideoSvc --> AWSComprehend & CustomML & S3 & CloudWatch
    AuroraPrimary --> AuroraReplica
    RedisPrimary --> RedisReplica
    WhatsAppSvc --> CloudWatch
    CloudWatch --> NewRelic & Sentry & Mixpanel
     Mobile:::primary
     WhatsApp:::primary
     CDN:::secondary
     WAF:::secondary
     Route53:::secondary
     API:::infra
     Chatbot:::infra
     WhatsAppSvc:::infra
     VideoSvc:::infra
     RealtimeSvc:::infra
     ALB:::secondary
     OpenAI:::infra
     Perplexity:::infra
     AWSComprehend:::infra
     CustomML:::infra
     AuroraPrimary:::infra
     RedisPrimary:::infra
     AuroraReplica:::infra
     RedisReplica:::infra
     S3:::infra
     CloudWatch:::monitoring
     NewRelic:::monitoring
     Sentry:::monitoring
     Mixpanel:::monitoring
    classDef primary fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef secondary fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef infra fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef monitoring fill:#fff3e0,stroke:#e65100,stroke-width:2px
```

### 2.2 Cost-Optimized Infrastructure Components

#### AWS Service Selection (Cost-Focused)

```mermaid
pie title AWS Cost Distribution (₹15,000/month)
    "Compute (ECS Fargate, Lambda)" : 40
    "Storage (Aurora, S3, EFS)" : 25
    "Network & CDN (CloudFront, ALB)" : 20
    "Monitoring (CloudWatch, X-Ray)" : 15
```

```mermaid
---
config:
  layout: elk
---
flowchart TB
 subgraph Compute["🏗️ Compute Layer (₹13,500/month)"]
        ECS["ECS Fargate<br>₹8,000/month<br>Auto-scaling containers"]
        Lambda["Lambda Functions<br>₹2,000/month<br>Event-driven processing"]
        EC2["EC2 Reserved<br>₹3,000/month<br>Predictable workloads"]
        Batch["AWS Batch<br>₹500/month<br>Video processing"]
  end
 subgraph Storage["💾 Storage Layer (₹7,300/month)"]
        Aurora["Aurora PostgreSQL<br>₹4,000/month<br>Primary database"]
        S3Std["S3 Standard<br>₹1,500/month<br>App assets &amp; media"]
        S3IA["S3 Infrequent Access<br>₹800/month<br>Archive data"]
        EFS["EFS<br>₹1,000/month<br>Shared file storage"]
  end
 subgraph Network["🌐 Network & CDN (₹4,200/month)"]
        CloudFront["CloudFront CDN<br>₹2,500/month<br>Global distribution"]
        ALB["Application Load Balancer<br>₹1,000/month<br>Traffic routing"]
        Route53["Route 53<br>₹200/month<br>DNS management"]
        NAT["NAT Gateway<br>₹500/month<br>Outbound traffic"]
  end
 subgraph Monitoring["📊 Monitoring (₹3,000/month)"]
        CloudWatch["CloudWatch<br>₹800/month<br>Metrics &amp; logs"]
        XRay["X-Ray<br>₹400/month<br>Distributed tracing"]
        Sentry["Sentry<br>₹1,200/month<br>Error tracking"]
        Dashboards["Custom Dashboards<br>₹600/month<br>Business metrics"]
  end
    ECS -. "Auto-scaling" .-> CostOpt["💡 Cost Optimization"]
    Aurora -. Serverless .-> CostOpt
    CloudFront -. Edge caching .-> CostOpt
    CloudWatch -. Usage monitoring .-> CostOpt
     ECS:::compute
     Lambda:::compute
     EC2:::compute
     Batch:::compute
     Aurora:::storage
     S3Std:::storage
     S3IA:::storage
     EFS:::storage
     CloudFront:::network
     ALB:::network
     Route53:::network
     NAT:::network
     CloudWatch:::monitoring
     XRay:::monitoring
     Sentry:::monitoring
     Dashboards:::monitoring
     CostOpt:::optimization
    classDef compute fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef storage fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef network fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef monitoring fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef optimization fill:#fce4ec,stroke:#c2185b,stroke-width:2px
```

#### Multi-Region Deployment Strategy

```mermaid
graph TD
    subgraph "🌏 Global Users"
        India[🇮🇳 Indian Users<br/>90% traffic<br/>Mumbai latency: <50ms]
        Global[🌍 Global Users<br/>10% traffic<br/>CDN optimized]
    end

    subgraph "📍 Primary Region: Mumbai (ap-south-1)"
        MumbaiECS[ECS Fargate<br/>Primary Application<br/>Auto-scaling]
        MumbaiDB[(Aurora PostgreSQL<br/>Primary Database<br/>ACUs: 2-16)]
        MumbaiRedis[(Redis Cluster<br/>Primary Cache<br/>Session storage)]
        MumbaiS3[S3 Bucket<br/>Primary Storage<br/>Media & Assets]
    end

    subgraph "📍 Secondary Region: Singapore (ap-southeast-1)"
        SingaporeECS[ECS Fargate<br/>Failover Application<br/>On-demand scaling]
        SingaporeDB[(Aurora Read Replicas<br/>Disaster Recovery<br/>Read performance)]
        SingaporeRedis[(Redis Replica<br/>Global Cache<br/>Failover support)]
        SingaporeS3[S3 Cross-Region<br/>Replication<br/>Backup storage]
    end

    subgraph "🌐 Global Infrastructure"
        CloudFront[CloudFront CDN<br/>310+ Edge Locations<br/>Global Distribution]
        Route53[Route 53<br/>Global DNS<br/>Health-based routing]
        CloudWatch[CloudWatch<br/>Multi-region monitoring<br/>Centralized alerts]
    end

    %% Traffic flow
    India --> CloudFront
    Global --> CloudFront
    CloudFront --> Route53

    Route53 -->|"Primary (90%)"| MumbaiECS
    Route53 -->|"Failover (10%)"| SingaporeECS

    MumbaiECS --> MumbaiDB
    MumbaiECS --> MumbaiRedis
    MumbaiECS --> MumbaiS3

    SingaporeECS --> SingaporeDB
    SingaporeECS --> SingaporeRedis
    SingaporeECS --> SingaporeS3

    %% Cross-region replication
    MumbaiDB -.->|"Aurora Global DB"| SingaporeDB
    MumbaiRedis -.->|"Redis replication"| SingaporeRedis
    MumbaiS3 -.->|"Cross-region replication"| SingaporeS3

    %% Monitoring connections
    MumbaiECS --> CloudWatch
    MumbaiDB --> CloudWatch
    SingaporeECS --> CloudWatch
    SingaporeDB --> CloudWatch

    %% Styling
    classDef primary fill:#e8f5e8,stroke:#2e7d32,stroke-width:3px
    classDef secondary fill:#fff3e0,stroke:#ef6c00,stroke-width:2px
    classDef global fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef users fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px

    class MumbaiECS,MumbaiDB,MumbaiRedis,MumbaiS3 primary
    class SingaporeECS,SingaporeDB,SingaporeRedis,SingaporeS3 secondary
    class CloudFront,Route53,CloudWatch global
    class India,Global users
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
├── PostgreSQL 16+ (Primary database)
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
        version: rds.AuroraPostgresEngineVersion.VER_16_3
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

```mermaid
graph LR
    subgraph "👨‍💻 Developer"
        Push[Git Push<br/>feature/* → main]
        PR[Pull Request<br/>Code Review]
    end

    subgraph "🔧 Build Stage (GitHub Actions)"
        Lint[Code Quality<br/>ESLint, Prettier<br/>SonarQube]
        Test[Testing Suite<br/>Unit Tests<br/>Integration Tests]
        Security[Security Scan<br/>SAST, Dependencies<br/>Container Scan]
        Build[Build Artifacts<br/>Flutter APK/AAB<br/>Docker Images]
    end

    subgraph "📦 Container Stage"
        MultiStage[Multi-stage<br/>Docker Build<br/>Dev/Prod Images]
        Scan[Security Scan<br/>Trivy, Docker Scout<br/>Vulnerability Check]
        Sign[Image Signing<br/>Attestation<br/>SBOM Generation]
    end

    subgraph "🚀 Deployment Stage"
        BlueGreen[Blue-Green<br/>Deployment<br/>Zero Downtime]
        Migrate[Database<br/>Migration<br/>Automated Rollback]
        FeatureFlags[Feature Flags<br/>Gradual Rollout<br/>A/B Testing]
        LoadTest[Performance<br/>Load Testing<br/>Stress Testing]
    end

    subgraph "🔍 Post-Deployment"
        Health[Health Checks<br/>API Endpoints<br/>Database Connectivity]
        Validate[Performance<br/>Validation<br/>Response Times]
        Smoke[Smoke Tests<br/>Critical Paths<br/>User Journeys]
        Rollback[Rollback Ready<br/>Automated<br/>One-Click]
    end

    subgraph "📊 Production"
        ECS[ECS Fargate<br/>Application<br/>Running]
        Aurora[(Aurora DB<br/>Migrated<br/>Healthy)]
        CloudWatch[Monitoring<br/>Active<br/>Alerting]
    end

    %% Flow connections
    Push --> Lint
    PR --> Lint

    Lint --> Test
    Test --> Security
    Security --> Build

    Build --> MultiStage
    MultiStage --> Scan
    Scan --> Sign

    Sign --> BlueGreen
    BlueGreen --> Migrate
    Migrate --> FeatureFlags
    FeatureFlags --> LoadTest

    LoadTest --> Health
    Health --> Validate
    Validate --> Smoke

    Smoke --> ECS
    Rollback -.->|"If issues"| BlueGreen

    ECS --> CloudWatch
    Aurora --> CloudWatch

    %% Styling
    classDef dev fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef build fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px
    classDef container fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef deploy fill:#fff3e0,stroke:#f57c00,stroke-width:2px
    classDef post fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef prod fill:#e0f2f1,stroke:#00695c,stroke-width:2px

    class Push,PR dev
    class Lint,Test,Security,Build build
    class MultiStage,Scan,Sign container
    class BlueGreen,Migrate,FeatureFlags,LoadTest deploy
    class Health,Validate,Smoke,Rollback post
    class ECS,Aurora,CloudWatch prod
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
├── AWS CloudWatch (Application performance)
├── AWS X-Ray (Distributed tracing)
├── Prometheus + Grafana (Custom dashboards)
└── Open-source error tracking (Custom solution)

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

  - name: "AWS Cost Spike (>25% increase)"
    condition: "aws_daily_cost > baseline_cost * 1.25"
    channels: ["slack", "email", "sms"]
    escalation: "1 hour"
    frequency: "every hour"

warning_alerts:
  - name: "High Memory Usage (>80%)"
    condition: "memory_usage > 80"
    channels: ["slack"]
    escalation: "15 minutes"

  - name: "Payment Failure Rate (>5%)"
    condition: "payment_failures > 0.05"
    channels: ["email", "slack"]
    escalation: "30 minutes"

  - name: "AWS Cost Increase (>15% increase)"
    condition: "aws_daily_cost > baseline_cost * 1.15"
    channels: ["slack", "email"]
    escalation: "4 hours"
    frequency: "every hour"

info_alerts:
  - name: "New User Registration Spike"
    condition: "new_users > 100"
    channels: ["slack"]
    escalation: "none"

  - name: "AWS Cost Trend (>5% weekly increase)"
    condition: "aws_weekly_cost_trend > 0.05"
    channels: ["slack"]
    escalation: "none"
    frequency: "daily"
```

## 5. Database Architecture & Design

### 5.1 Database Design Philosophy

#### Multi-Tenant Architecture

```mermaid
graph TD
    subgraph "🏢 Multi-Tenant Database Design"
        subgraph "Option 1: Separate Databases"
            DB1[(Database 1<br/>LIC Insurance<br/>tenant_lic)]
            DB2[(Database 2<br/>HDFC Insurance<br/>tenant_hdfc)]
            DB3[(Database 3<br/>ICICI Insurance<br/>tenant_icici)]
        end

        subgraph "Option 2: Shared Database + tenant_id"
            SharedDB[(Shared PostgreSQL<br/>All Tenants<br/>Single Database)]
            TenantTable1[users<br/>tenant_id: 1<br/>LIC data]
            TenantTable2[users<br/>tenant_id: 2<br/>HDFC data]
            TenantTable3[users<br/>tenant_id: 3<br/>ICICI data]
        end

        subgraph "Option 3: Schema-based (Chosen)"
            Schema1[lic_schema<br/>users, policies<br/>agent_lic_*]
            Schema2[hdfc_schema<br/>users, policies<br/>agent_hdfc_*]
            Schema3[icici_schema<br/>users, policies<br/>agent_icici_*]
            SharedSchema[shared_schema<br/>reference data<br/>countries, etc.]
        end
    end

    subgraph "🔒 Security & Isolation"
        RLS[Row Level Security<br/>tenant_id filtering<br/>Automatic enforcement]
        Audit[Audit Logging<br/>All data changes<br/>Compliance tracking]
        Encryption[Encryption at Rest<br/>AES-256<br/>Transparent encryption]
    end

    subgraph "⚡ Performance & Scaling"
        ReadReplicas[(Read Replicas<br/>Performance<br/>Load distribution)]
        Partitioning[Table Partitioning<br/>Time-based<br/>Provider-based]
        Indexing[Composite Indexes<br/>Query optimization<br/>Covering indexes]
        Redis[(Redis Cache<br/>Session storage<br/>Query caching)]
    end

    %% Connections
    DB1 --> RLS
    DB2 --> RLS
    DB3 --> RLS

    SharedDB --> TenantTable1
    SharedDB --> TenantTable2
    SharedDB --> TenantTable3
    TenantTable1 --> RLS
    TenantTable2 --> RLS
    TenantTable3 --> RLS

    Schema1 --> RLS
    Schema2 --> RLS
    Schema3 --> RLS
    SharedSchema --> RLS

    RLS --> Audit
    Audit --> Encryption

    RLS --> ReadReplicas
    ReadReplicas --> Partitioning
    Partitioning --> Indexing
    Indexing --> Redis

    %% Styling
    classDef database fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef security fill:#fce4ec,stroke:#c2185b,stroke-width:2px
    classDef performance fill:#e8f5e8,stroke:#388e3c,stroke-width:2px

    class DB1,DB2,DB3,SharedDB,Schema1,Schema2,Schema3,SharedSchema,TenantTable1,TenantTable2,TenantTable3 database
    class RLS,Audit,Encryption security
    class ReadReplicas,Partitioning,Indexing,Redis performance
```

**🎯 Selected Approach: Schema-based separation with tenant_id**
- ✅ Strong isolation between insurance providers
- ✅ Cost-effective (single database instance)
- ✅ Flexible scaling and maintenance
- ✅ Row-level security for granular access control

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
├── AWS CloudWatch (₹2,000/month) - APM and monitoring
├── AWS X-Ray (₹400/month) - Distributed tracing
├── Mixpanel (₹5,000/month) - User analytics
├── Prometheus + Grafana (₹500/month) - Self-hosted monitoring
└── Open-source alerting (Free) - Custom error tracking

🤖 AI/ML Services:
├── OpenAI API (₹15,000/month) - Chatbot and analytics
├── Perplexity API (₹8,000/month) - Enhanced search
├── AWS Comprehend (₹1,000/month) - Text analysis
└── Custom ML Models (₹3,000/month) - Predictive analytics

📱 Communication Services:
├── WhatsApp Business API (₹5,000/month) - Business messaging
├── Twilio (₹2,000/month) - SMS and voice (backup)
├── Microsoft Graph API (Included in O365) - Email, calendar, and collaboration
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
├── Penpot (Free) - Open source UI/UX design
├── Inkscape (Free) - Vector graphics and asset creation
└── Direct integration (Free) - Design handoff via shared assets

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

```mermaid
graph TD
    subgraph "💻 Local Development (MacBook Pro M2)"
        subgraph "🖥️ Hardware"
            CPU[Apple M2<br/>8-core CPU<br/>10-core GPU]
            RAM[16GB Unified Memory]
            Storage[512GB SSD]
            Display[16-inch Retina Display]
        end

        subgraph "📦 Local Services (Docker)"
            PostgresLocal[(PostgreSQL 16<br/>Database<br/>Local data)]
            RedisLocal[(Redis 7<br/>Caching<br/>Session store)]
            NginxLocal[Nginx<br/>Reverse Proxy<br/>Port 8080]
            ElasticLocal[(Elasticsearch<br/>Search<br/>Optional)]
            MinIOLocal[MinIO<br/>Object Storage<br/>S3 compatible]
        end

        subgraph "🔧 Development Tools"
            FlutterSDK[Flutter SDK<br/>Latest stable<br/>Hot reload]
            Python311[Python 3.11<br/>Backend dev<br/>Virtual env]
            Node18[Node.js 18<br/>Build tools<br/>npm/yarn]
            VSCode[VS Code<br/>Primary IDE<br/>Extensions]
            Git[Git & GitHub<br/>Version control<br/>Collaboration]
        end
    end

    subgraph "☁️ Production Environment (AWS)"
        subgraph "🏗️ Infrastructure Scale"
            ECSProd[ECS Fargate<br/>4-8 vCPU containers<br/>Auto-scaling]
            AuroraProd[(Aurora PostgreSQL<br/>2-16 ACUs<br/>Auto-scaling)]
            RedisProd[(Redis ElastiCache<br/>2-8 nodes cluster<br/>High availability)]
            CloudFrontProd[CloudFront CDN<br/>310+ Edge Locations<br/>Global distribution]
            Route53Prod[Route 53<br/>Global DNS<br/>Health checks]
        end

        subgraph "📊 Production Services"
            ALB[Application Load Balancer<br/>4-8 instances<br/>Traffic routing]
            ASG[Auto Scaling Groups<br/>2-10 instances<br/>Demand scaling]
            ReadReplicas[(Read Replicas<br/>2-4 replicas<br/>Performance boost)]
            EdgeLocations[CDN Edge Locations<br/>50+ locations<br/>Low latency]
            MonitoringStack[Monitoring Stack<br/>10+ services<br/>Observability]
        end
    end

    subgraph "⚡ Performance Comparison"
        LocalPerf[Local Performance<br/>Database: <10ms<br/>API: <50ms<br/>Build: 2-3 min<br/>Tests: 30-60s<br/>Memory: 8-12GB]
        ProdPerf[Production Performance<br/>Database: <20ms<br/>API: <100ms global<br/>CDN: <50ms global<br/>Uptime: 99.9%<br/>Users: 10,000+ concurrent]
    end

    %% Connections for local environment
    FlutterSDK --> NginxLocal
    Python311 --> PostgresLocal
    Python311 --> RedisLocal
    VSCode --> FlutterSDK
    VSCode --> Python311
    VSCode --> Git

    NginxLocal --> PostgresLocal
    NginxLocal --> RedisLocal

    %% Connections for production environment
    ECSProd --> AuroraProd
    ECSProd --> RedisProd
    ALB --> ECSProd
    CloudFrontProd --> ALB
    Route53Prod --> CloudFrontProd

    AuroraProd --> ReadReplicas
    RedisProd --> MonitoringStack

    ASG --> ECSProd

    %% Styling
    classDef local fill:#e3f2fd,stroke:#1976d2,stroke-width:2px
    classDef prod fill:#e8f5e8,stroke:#388e3c,stroke-width:2px
    classDef perf fill:#fff3e0,stroke:#f57c00,stroke-width:2px

    class CPU,RAM,Storage,Display,PostgresLocal,RedisLocal,NginxLocal,ElasticLocal,MinIOLocal,FlutterSDK,Python311,Node18,VSCode,Git local
    class ECSProd,AuroraProd,RedisProd,CloudFrontProd,Route53Prod,ALB,ASG,ReadReplicas,EdgeLocations,MonitoringStack prod
    class LocalPerf,ProdPerf perf
```

#### Performance Comparison Matrix
| Metric | Local Development | Production (AWS) |
|--------|------------------|------------------|
| **Database Response** | <10ms (same machine) | <20ms (primary region) |
| **API Response** | <50ms (localhost) | <100ms (global average) |
| **CDN Response** | N/A | <50ms (global) |
| **Build Time** | 2-3 minutes (Flutter) | 10-15 minutes (CI/CD) |
| **Concurrent Users** | 1 (developer only) | 10,000+ (horizontal scaling) |
| **Uptime SLA** | N/A | 99.9% |
| **Memory Usage** | 8-12GB (development) | Auto-scaling (cost-optimized) |
| **Storage** | 512GB SSD (local) | Unlimited (S3 + Aurora) |

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
├── Redis/CDN cached configuration (1-hour TTL)
├── Real-time flag updates via cache invalidation
├── Gradual rollout capabilities with percentage-based targeting
└── Emergency kill switches with instant cache purge

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

```mermaid
gantt
    title Agent Mitra Implementation Roadmap (24 months)
    dateFormat YYYY-MM-DD
    section Phase 1: MVP (Months 1-6)
        Infrastructure Setup          :done, infra1, 2024-01-01, 2024-02-15
        Flutter Mobile App            :done, app1, 2024-02-01, 2024-04-30
        Basic Authentication          :done, auth1, 2024-02-15, 2024-03-15
        Policy Management             :done, policy1, 2024-03-01, 2024-04-15
        WhatsApp Integration          :done, whatsapp1, 2024-03-15, 2024-05-01
        Video Upload (YouTube)        :done, video1, 2024-04-01, 2024-05-15
        Customer Dashboard            :done, dashboard1, 2024-04-15, 2024-06-01
        Testing & Launch              :active, test1, 2024-05-15, 2024-06-15

    section Phase 2: Growth (Months 7-12)
        Advanced Analytics           :analytics2, after test1, 30d
        Real-time Dashboards         :realtime2, after analytics2, 45d
        Marketing Campaigns          :campaigns2, after realtime2, 30d
        Multi-tenant Features        :multitenant2, after campaigns2, 45d
        Advanced Chatbot             :chatbot2, after multitenant2, 30d
        Video Recommendations        :video2, after chatbot2, 30d
        Performance Optimization     :perf2, after video2, 30d

    section Phase 3: Enterprise (Months 13-24)
        Global Multi-region          :global3, after perf2, 60d
        Advanced Security            :security3, after global3, 45d
        ERP/CRM Integrations         :integrations3, after security3, 60d
        Enterprise Compliance        :compliance3, after integrations3, 45d
        Real-time Collaboration      :collaboration3, after compliance3, 30d
        Advanced BI                  :bi3, after collaboration3, 45d
        Enterprise Launch            :launch3, after bi3, 30d
```

#### Phase 1: MVP Infrastructure (₹15,000/month)
```mermaid
pie title Phase 1 Cost Distribution (₹15,000/month)
    "Compute (ECS)" : 53
    "Database (Aurora)" : 27
    "Network & CDN" : 17
    "Monitoring" : 3
```

**🎯 Deliverables:**
- ✅ Flutter mobile app (iOS + Android)
- ✅ Basic authentication (OTP + Biometric)
- ✅ Policy management (CRUD operations)
- ✅ WhatsApp integration (Basic messaging)
- ✅ Video upload (YouTube integration)
- ✅ Customer dashboard (Essential metrics)

**📈 Expected Performance:**
- Response Time: <200ms average
- Concurrent Users: 1,000
- Uptime: 99.5%
- Monthly Active Users: 700 (Target)

#### Phase 2: Growth Infrastructure (₹45,000/month)
```mermaid
pie title Phase 2 Cost Distribution (₹45,000/month)
    "Compute (ECS)" : 44
    "Database (Aurora)" : 18
    "Network & CDN" : 11
    "Monitoring" : 9
    "AI/ML Services" : 7
    "Load Balancing" : 4
    "Advanced Features" : 7
```

**🎯 Deliverables:**
- Advanced analytics (Predictive modeling)
- Real-time dashboards (WebSocket updates)
- Marketing automation (Campaign management)
- Multi-tenant features (Provider management)
- Advanced chatbot (NLP capabilities)
- Video recommendation engine (AI-powered)

**📈 Expected Performance:**
- Response Time: <150ms average
- Concurrent Users: 5,000
- Uptime: 99.9%
- Monthly Active Users: 5,000

#### Phase 3: Enterprise Infrastructure (₹150,000/month)
```mermaid
pie title Phase 3 Cost Distribution (₹150,000/month)
    "Compute (ECS Multi-region)" : 40
    "Database (Global Aurora)" : 17
    "Network & CDN" : 10
    "Monitoring (Enterprise)" : 10
    "AI/ML Services (Advanced)" : 8
    "Security Services" : 3
    "Load Balancing (Global)" : 5
    "Caching (Multi-region)" : 7
```

**🎯 Deliverables:**
- Global multi-region deployment
- Advanced security (Zero-trust architecture)
- Enterprise integrations (ERP, CRM systems)
- Advanced compliance (IRDAI enterprise features)
- Real-time collaboration features
- Advanced business intelligence

**📈 Expected Performance:**
- Response Time: <100ms average
- Concurrent Users: 50,000
- Uptime: 99.95%
- Monthly Active Users: 50,000

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
