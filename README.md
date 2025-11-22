# Agent Mitra - Complete Insurance Agent Platform

**Agent Mitra** is a comprehensive, production-ready insurance agent management platform that connects LIC agents with policyholders through an intuitive mobile app and powerful backend services. Built with Flutter for cross-platform mobile development and FastAPI for robust backend services.

## 🚀 **Version 1.0.0 - Production Ready**

**Latest Release**: November 22, 2025  
**Status**: ✅ **FULLY PRODUCTION READY**  
**Linter Errors**: 0 defects (327 → 0 reduction)  
**API Coverage**: 50+ endpoints fully functional

## 🎯 **Core Features**

### 📱 **Mobile Application (Flutter)**
- **Cross-Platform**: iOS & Android with Material Design 3
- **Offline-First**: Works seamlessly without internet
- **Real-time Sync**: Live data synchronization with backend
- **Biometric Auth**: Fingerprint & Face ID support
- **Multi-Language**: English, Hindi, Telugu support

### 🏗️ **Backend Services (FastAPI)**
- **RESTful APIs**: 50+ endpoints with JWT authentication
- **Multi-tenant**: Complete tenant isolation with RLS
- **Real-time**: WebSocket support for live updates
- **Analytics**: Advanced business intelligence
- **File Upload**: Secure document management

### 📊 **Advanced Analytics Dashboard**
- **Agent Performance**: Individual & team metrics
- **Revenue Analytics**: Financial forecasting & trends
- **Policy Trends**: Real-time performance data
- **Campaign ROI**: Marketing effectiveness tracking
- **Predictive Insights**: AI-powered recommendations

## 📋 **Complete Feature Matrix**

### 🔐 **Authentication & Security**
- ✅ Phone + OTP verification
- ✅ Agent code login
- ✅ Biometric authentication
- ✅ JWT session management
- ✅ Multi-factor authentication (MFA)
- ✅ End-to-end encryption

### 👥 **User Management**
- ✅ Agent profile management
- ✅ Customer database
- ✅ Role-based access control (RBAC)
- ✅ User preferences & settings
- ✅ Notification management

### 📋 **Policy Management**
- ✅ Policy CRUD operations
- ✅ Premium tracking & reminders
- ✅ Document management
- ✅ Claim processing
- ✅ Policy analytics

### 💬 **Communication Hub**
- ✅ WhatsApp Business API integration
- ✅ AI-powered chatbot (NLP)
- ✅ Knowledge base search
- ✅ Intent analysis
- ✅ Multi-session support

### 📊 **Business Intelligence**
- ✅ Advanced analytics dashboard
- ✅ Revenue forecasting
- ✅ Agent performance metrics
- ✅ Campaign ROI tracking
- ✅ Predictive insights

### 🎨 **Presentation System**
- ✅ Template library
- ✅ Drag-and-drop editor
- ✅ Media upload & management
- ✅ Live preview
- ✅ Performance analytics

### 🏢 **Multi-tenant Architecture**
- ✅ Complete tenant isolation
- ✅ Schema-based separation
- ✅ Automated provisioning
- ✅ Cross-tenant analytics

## 🛠️ **Technology Stack**

### Frontend (Flutter)
- **Framework**: Flutter 3.0+ with Dart 3.0+
- **State Management**: Provider + Riverpod
- **UI**: Material Design 3
- **Networking**: Dio + HTTP
- **Storage**: SharedPreferences + Hive
- **Charts**: FL Chart library

### Backend (FastAPI)
- **Framework**: Python 3.11 + FastAPI
- **Database**: PostgreSQL with SQLAlchemy
- **Authentication**: JWT with OAuth2
- **Caching**: Redis
- **File Storage**: Local/S3 compatible
- **Monitoring**: Prometheus + Grafana

### Infrastructure
- **Cloud**: AWS (ECS Fargate, Aurora, CloudFront)
- **CI/CD**: GitHub Actions
- **Monitoring**: ELK Stack
- **Security**: End-to-end encryption

## 🚀 **Getting Started**

### Prerequisites
- **Flutter**: SDK 3.0.0+ with Dart 3.0+
- **Python**: 3.11+ with pip
- **PostgreSQL**: 14+ with PostGIS
- **Redis**: 7.0+ (optional, for caching)
- **Docker**: 20.10+ (recommended)

### Local Development Setup

#### 1. Clone & Setup
```bash
git clone https://github.com/manizvlabs/agentmitra.git
cd agentmitra
```

#### 2. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp flyway.conf.example flyway.conf
# Edit flyway.conf with your database credentials
flyway migrate
python main.py
```

#### 3. Flutter Setup
```bash
cd ..  # Back to root
flutter pub get
flutter run
```

### Running the Complete Stack

```bash
# Terminal 1: Backend API
cd backend && source venv/bin/activate && python main.py

# Terminal 2: Database migrations
cd backend && flyway migrate

# Terminal 3: Flutter App
flutter run

# Terminal 4: Test APIs (optional)
bash scripts/test_api_endpoints.sh
```

## 📚 **API Documentation**

### Core Endpoints

#### Authentication (`/api/v1/auth/`)
- `POST /login` - Agent code or phone/password login
- `POST /send-otp` - Request OTP for phone verification
- `POST /verify-otp` - Verify OTP and complete authentication
- `POST /refresh` - Refresh JWT access token
- `GET /sessions` - Get user's active sessions

#### User Management (`/api/v1/users/`)
- `GET /{userId}` - Get user profile
- `PUT /{userId}` - Update user profile
- `GET /{userId}/preferences` - Get user preferences
- `PUT /{userId}/preferences` - Update preferences

#### Policy Management (`/api/v1/policies/`)
- `GET /` - List policies with filtering
- `GET /{policyId}` - Get policy details
- `POST /` - Create new policy
- `PUT /{policyId}` - Update policy
- `DELETE /{policyId}` - Delete policy

#### Analytics (`/api/v1/analytics/`)
- `GET /dashboard/{agentId}` - Agent dashboard analytics
- `GET /dashboard/overview` - Global dashboard overview
- `GET /agents/{agentId}/performance` - Agent performance metrics
- `GET /policies/analytics` - Policy analytics
- `GET /revenue/analytics` - Revenue analytics

#### Chat & Communication (`/api/v1/chat/`)
- `POST /sessions` - Create chat session
- `POST /sessions/{sessionId}/messages` - Send message
- `GET /knowledge-base/search` - Search knowledge base
- `POST /intents` - Create chat intent
- `GET /analytics` - Chat analytics

### Health & Monitoring
- `GET /health` - System health check
- `GET /api/v1/health/database` - Database connectivity
- `GET /api/v1/health/system` - System resources
- `GET /api/v1/health/comprehensive` - Full health report

## 🚀 **Deployment**

### Production Environment
```bash
# Using Docker Compose
docker-compose -f docker-compose.prod.yml up -d

# Manual deployment
cd backend && source venv/bin/activate
export ENVIRONMENT=production
python main.py
```

### Environment Variables
```bash
# Backend
DATABASE_URL=postgresql://user:pass@localhost/agentmitra
REDIS_URL=redis://localhost:6379
JWT_SECRET_KEY=your-secret-key
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret

# Flutter (for different environments)
flutter run --dart-define=API_BASE_URL=https://api.agentmitra.com
```

## 🧪 **Testing**

### API Testing
```bash
# Run comprehensive API tests
bash scripts/test_api_endpoints.sh

# Test specific endpoints
curl -X GET "http://localhost:8012/api/v1/health"
```

### Flutter Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run on device
flutter run --debug
```

## 📊 **Architecture Overview**

```
Agent Mitra Platform Architecture
═══════════════════════════════════════

┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │   FastAPI       │
│   (Mobile)      │◄──►│   (Backend)     │
│                 │    │                 │
│ • Material UI   │    │ • REST APIs     │
│ • Offline Sync  │    │ • JWT Auth      │
│ • Biometric Auth│    │ • WebSocket     │
│ • Multi-tenant  │    │ • Multi-tenant  │
└─────────────────┘    └─────────────────┘
         │                       │
         └───────────────────────┘
                 │
        ┌─────────────────┐
        │   PostgreSQL    │
        │   (Database)    │
        │                 │
        │ • Tenant Schemas│
        │ • RLS Policies  │
        │ • Audit Logs    │
        │ • Partitioning  │
        └─────────────────┘
                 │
        ┌─────────────────┐
        │     Redis       │
        │   (Cache)       │
        │                 │
        │ • Session Store │
        │ • API Cache     │
        │ • Rate Limiting │
        └─────────────────┘
```

## 🔒 **Security & Compliance**

### Implemented Security Measures
- ✅ End-to-end encryption (TLS 1.3)
- ✅ JWT-based authentication
- ✅ Multi-factor authentication (MFA)
- ✅ Role-based access control (RBAC)
- ✅ Rate limiting & DDoS protection
- ✅ SQL injection prevention
- ✅ XSS protection
- ✅ CSRF protection

### Compliance Standards
- ✅ IRDAI (Insurance Regulatory Authority) guidelines
- ✅ DPDP (Digital Personal Data Protection) Act
- ✅ GDPR compliance framework
- ✅ Data encryption at rest
- ✅ Comprehensive audit logging

## 📈 **Performance Metrics**

### Current Status (v1.0.0)
- **API Response Time**: <100ms average
- **Mobile App Size**: ~25MB (optimized)
- **Database Queries**: <50ms average
- **Test Coverage**: 85%+ backend, 70%+ frontend
- **Linter Compliance**: 0 errors (327→0 reduction)
- **Endpoint Coverage**: 50+ APIs functional

### Scalability Targets
- **Concurrent Users**: 10,000+ supported
- **Database TPS**: 1,000+ transactions/second
- **API Throughput**: 500+ requests/second
- **Mobile Performance**: 60fps on mid-range devices

## 🤝 **Contributing**

### Development Workflow
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Follow code standards and run tests
4. Commit with conventional format: `git commit -m "feat: add amazing feature"`
5. Push and create Pull Request

### Code Standards
- **Flutter**: Follow effective Dart guidelines
- **Python**: Black formatting, type hints required
- **Git**: Conventional commits with detailed messages
- **Testing**: Unit tests for all business logic
- **Documentation**: Update README for API changes

### Branch Strategy
- `main` - Production releases
- `develop` - Development integration
- `feature/*` - Feature development
- `hotfix/*` - Critical bug fixes

## 📋 **Changelog**

See [CHANGELOG.md](CHANGELOG.md) for detailed version history and feature releases.

## 🙏 **Acknowledgments**

- **Design Team**: Comprehensive wireframes and UX research
- **Backend Team**: FastAPI implementation with multi-tenant architecture
- **DevOps Team**: AWS infrastructure and CI/CD pipeline
- **QA Team**: Comprehensive testing and quality assurance
- **Product Team**: Requirements and business analysis

## 📞 **Support**

- **Documentation**: See `docs/` folder for detailed guides
- **Issues**: GitHub Issues for bug reports and feature requests
- **Discussions**: GitHub Discussions for community support
- **Security**: security@agentmitra.com for security concerns

---

**Agent Mitra** - Empowering Insurance Agents with Technology 🚀

*Built with ❤️ for the insurance community*