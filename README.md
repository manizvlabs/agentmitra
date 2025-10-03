# Agent Mitra 📱

## Friend of Agents - World-Class Multi-Tenant Insurance Service Provider Platform

[![Version](https://img.shields.io/badge/version-0.0.1-blue.svg)](https://github.com/manizvlabs/agentmitra)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B.svg)](https://flutter.dev/)
[![Python](https://img.shields.io/badge/Python-3.9+-3776AB.svg)](https://python.org/)
[![License](https://img.shields.io/badge/License-Commercial-red.svg)]()

Agent Mitra is a revolutionary mobile-first platform designed specifically for LIC agents and policyholders in India. Built with a focus on simplicity for non-tech-savvy users while providing advanced AI/ML capabilities, the platform transforms traditional insurance agent-customer interactions into data-driven, automated, and highly engaging experiences.

## 🎯 Key Features

### 🤖 Smart AI/ML Capabilities
- **Predictive Analytics** for churn prediction and revenue forecasting
- **Personalized Recommendations** using advanced machine learning
- **Automated Insights** with real-time business intelligence
- **Smart Chatbot** with natural language processing and intent recognition

### 📱 Multi-Channel Communication
- **WhatsApp Business API** integration for seamless communication
- **Smart Context Sharing** between app and WhatsApp
- **Multi-language Support** (English, Telugu, Hindi) with future extensions
- **Template-based Messaging** with personalization

### 💰 Revenue Optimization
- **ROI Dashboards** with actionable business intelligence
- **Campaign Management** with A/B testing and automation
- **Commission Tracking** with real-time performance metrics
- **Lead Conversion Optimization** with predictive scoring

### 🔐 Enterprise-Grade Security
- **GDPR & IRDAI Compliance** built-in
- **End-to-End Encryption** for all sensitive data
- **Multi-Tenant Architecture** with complete data isolation
- **Role-Based Access Control** (RBAC) with granular permissions

### 🎨 User Experience Excellence
- **Clutter-Free Design** optimized for non-tech-savvy users
- **Progressive Disclosure** showing only relevant information
- **Dark/Light Theme** with CSS-based theming
- **Smart Search** across all content areas

## 🏗️ Architecture Overview

### Multi-Tenant Architecture
```
🏢 MULTI-TENANT ECOSYSTEM
├── Insurance Provider Tenants (LIC, HDFC, ICICI, etc.)
│   ├── Regional Managers & Senior Agents
│   └── Junior Agents & Support Staff
└── Independent Agents & Agent Networks
```

### Technology Stack
- **Frontend:** Flutter (iOS/Android cross-platform)
- **Backend:** Python with FastAPI/Microservices
- **Database:** PostgreSQL with tenant-specific schemas
- **Caching:** Redis with tenant isolation
- **File Storage:** AWS S3 with tenant-specific buckets
- **Authentication:** JWT with MFA support
- **Communication:** WhatsApp Business API, SMS, Email
- **Video Hosting:** YouTube Integration
- **Analytics:** Custom AI/ML pipeline

### Infrastructure
- **Cloud:** AWS with cost-optimized architecture
- **CI/CD:** GitHub Actions with automated testing
- **Monitoring:** Comprehensive logging and alerting
- **Security:** End-to-end encryption and compliance

## 📋 Project Structure

```
agentmitra/
├── lib/                    # Flutter mobile app
│   ├── main.dart          # App entry point
│   ├── screens/           # UI screens and pages
│   ├── widgets/           # Reusable UI components
│   ├── services/          # API and business logic
│   ├── models/            # Data models
│   └── utils/             # Utility functions
├── android/                # Android-specific files
├── ios/                    # iOS-specific files
├── web/                    # Web build (future)
├── linux/                  # Linux build (future)
├── macos/                  # macOS build (future)
├── windows/                # Windows build (future)
├── discovery/              # Design and architecture docs
│   ├── content/           # Core architecture docs
│   ├── design/            # UI/UX specifications
│   ├── deployment/        # Infrastructure design
│   └── miscellaneous/     # Supporting documents
├── docs/                   # Additional documentation
└── pubspec.yaml           # Flutter dependencies
```

## 🚀 Quick Start

### Prerequisites
- Flutter SDK (3.0+)
- Python (3.9+)
- PostgreSQL (14+)
- Redis (7+)
- Git

### Local Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/manizvlabs/agentmitra.git
   cd agentmitra
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up local environment**
   ```bash
   # Copy environment configuration
   cp .env.example .env

   # Configure your local settings
   # Database, Redis, API keys, etc.
   ```

4. **Run the development environment**
   ```bash
   # Start local services (Docker recommended)
   docker-compose up -d

   # Run Flutter app
   flutter run
   ```

### Development Commands

```bash
# Run tests
flutter test

# Build for production
flutter build apk
flutter build ios

# Code generation
flutter pub run build_runner build

# Clean and rebuild
flutter clean && flutter pub get
```

## 🎨 Design System

### Color Palette
- **Primary:** Agent Mitra Blue (#1976D2)
- **Secondary:** Success Green (#4CAF50)
- **Accent:** Warning Orange (#FF9800)
- **Error:** Alert Red (#F44336)
- **Background:** Clean White/Gray (#FFFFFF/#F5F5F5)

### Typography
- **Primary Font:** Roboto (Google Fonts)
- **Regional Fonts:** Noto Sans Telugu, Noto Sans Devanagari
- **Scales:** Material Design 3 typography scale

### Component Library
- **Buttons:** Elevated, Filled, Outlined, Text
- **Cards:** Material cards with shadows and elevation
- **Forms:** Text fields, dropdowns, checkboxes, radio buttons
- **Navigation:** Bottom tabs, side drawer, app bar

## 🔧 Configuration

### Feature Flags
All features are controlled by configurable feature flags that can be enabled/disabled without app redeployment:

```json
{
  "features": {
    "whatsapp_integration": true,
    "ai_chatbot": true,
    "roi_dashboards": true,
    "campaign_management": true,
    "video_tutorials": true
  }
}
```

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost:5432/agentmitra

# Redis
REDIS_URL=redis://localhost:6379

# API Keys
WHATSAPP_API_KEY=your_whatsapp_key
YOUTUBE_API_KEY=your_youtube_key

# JWT
JWT_SECRET=your_jwt_secret

# AWS (for production)
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
```

## 📊 Business Intelligence

### Key Metrics Tracked
- **User Engagement:** DAU, retention rates, session duration
- **Business Performance:** Conversion rates, revenue growth, commission tracking
- **Customer Satisfaction:** NPS scores, support ticket resolution
- **System Performance:** API response times, error rates, uptime

### Analytics Dashboard
- **Real-time Monitoring:** Live metrics and alerts
- **Custom Reports:** Configurable business intelligence reports
- **Predictive Analytics:** AI-powered trend forecasting
- **ROI Tracking:** Campaign performance and revenue attribution

## 🤝 Contributing

We welcome contributions to Agent Mitra! Please follow these guidelines:

### Development Workflow
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`flutter test`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Code Standards
- Follow Flutter best practices and Effective Dart guidelines
- Write comprehensive tests for new features
- Update documentation for API changes
- Use meaningful commit messages

### Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart

# Generate test coverage
flutter test --coverage
```

## 📝 Documentation

### Available Documentation
- **[Information Architecture](discovery/content/information-architecture.md)** - Complete site structure
- **[Wireframes](discovery/content/wireframes.md)** - UI/UX design specifications
- **[API Documentation](docs/api/)** - Backend API specifications
- **[Deployment Guide](discovery/deployment/deployment-design.md)** - Infrastructure setup
- **[Security Guide](docs/security/)** - Security and compliance

### Architecture Decision Records (ADRs)
- [Multitenant Architecture](discovery/content/multitenant-architecture-design.md)
- [Authentication Design](discovery/design/authentication-design.md)
- [Database Schema](discovery/deployment/database-schema.md)

## 🔒 Security & Compliance

### Regulatory Compliance
- **IRDAI Guidelines** for insurance applications
- **DPDP Act** for data protection and privacy
- **GDPR Compliance** for international users
- **PCI DSS** for payment processing

### Security Features
- **Data Encryption** at rest and in transit
- **Multi-Factor Authentication** (MFA)
- **Role-Based Access Control** (RBAC)
- **Audit Logging** for all user actions
- **Regular Security Audits** and penetration testing

## 📞 Support & Contact

### Getting Help
- **Documentation:** Check our [docs](docs/) first
- **Issues:** Report bugs on [GitHub Issues](https://github.com/manizvlabs/agentmitra/issues)
- **Discussions:** Join community discussions on [GitHub Discussions](https://github.com/manizvlabs/agentmitra/discussions)

### Business Inquiries
- **Email:** business@agentmitra.com
- **LinkedIn:** [Agent Mitra](https://linkedin.com/company/agentmitra)
- **Website:** [agentmitra.com](https://agentmitra.com)

### Technical Support
- **Email:** support@agentmitra.com
- **Response Time:** < 24 hours for critical issues
- **Documentation:** Comprehensive troubleshooting guides

## 📈 Roadmap

### Version 0.1.0 (MVP)
- [x] Core authentication and user management
- [x] Basic policy management
- [x] WhatsApp integration
- [x] Smart dashboards

### Version 0.2.0 (Beta)
- [ ] Campaign management system
- [ ] Advanced AI/ML features
- [ ] Multi-language support
- [ ] Video tutorial system

### Version 1.0.0 (Production)
- [ ] Full compliance certification
- [ ] Advanced analytics
- [ ] Third-party integrations
- [ ] Enterprise features

## 📄 License

This project is proprietary software owned by Agent Mitra. All rights reserved.

For licensing inquiries, please contact business@agentmitra.com

## 🙏 Acknowledgments

- **Flutter Team** for the amazing cross-platform framework
- **FastAPI** for the robust Python backend framework
- **PostgreSQL** for reliable data storage
- **Redis** for high-performance caching
- **AWS** for scalable cloud infrastructure

---

**Built with ❤️ for LIC agents and policyholders across India**

*Transforming insurance services, one agent at a time.*