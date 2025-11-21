# Agent Mitra - Getting Started Guide

> **Development Starting Point** | **MacBook Ready** ✅ | **Step-by-Step Guide**

## 🎯 Development Starting Point

Based on `project-plan.md`, we follow **Phase 1: Foundation & Setup (Weeks 1-2)** as our starting point.

### Recommended Development Order

```
📋 PHASE 1: FOUNDATION & SETUP
├── Week 1: Project Structure & Local Environment
│   ├── ✅ Step 1: Local Development Setup (THIS GUIDE)
│   ├── ✅ Step 2: Project Structure Implementation
│   ├── ✅ Step 3: CI/CD Pipeline Setup
│   └── ✅ Step 4: Feature Flags (don't use any mock data, only work with real data by adding seed data using flyway into real database)
│
└── Week 2: Database Design & Migration Setup
    ├── ✅ Step 1: Database Schema Creation (Flyway)
    ├── ✅ Step 2: ORM Configuration (SQLAlchemy)
    ├── ✅ Step 3: Seed Data & Testing
    └── ✅ Step 4: Performance Optimization
```

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites Check

```bash
# Run this to check what you have installed
./scripts/verify-local-services.sh
```

### One-Command Setup

```bash
# Run automated setup (installs everything needed)
./scripts/setup-local-environment.sh
```

### Manual Setup (If Preferred)

Follow the detailed guide: [`docs/development/LOCAL_DEVELOPMENT_SETUP.md`](./LOCAL_DEVELOPMENT_SETUP.md)

---

## 📋 What You Need (Software Checklist)

### ✅ Required Software (MacBook)

| Software | Version | Status | Installation |
|----------|---------|--------|--------------|
| **macOS** | 12.0+ | ✅ | Already installed |
| **Homebrew** | Latest | ⚠️ | `brew install` |
| **Git** | 2.40+ | ⚠️ | `brew install git` |
| **Docker Desktop** | 24.0+ | ⚠️ | [Download](https://www.docker.com/products/docker-desktop) |
| **Python** | 3.11+ | ⚠️ | `brew install python@3.11` |
| **Node.js** | 20.x LTS | ⚠️ | `brew install node@20` |
| **Flutter** | 3.24+ | ⚠️ | `brew install --cask flutter` |
| **PostgreSQL** | 16.x | ⚠️ | `brew install postgresql@16` |
| **Redis** | 7.x | ⚠️ | `brew install redis` |
| **Flyway** | 10.x | ⚠️ | `brew install flyway` |

### ✅ Optional but Recommended

- **VS Code** - IDE
- **Postman** - API testing
- **DBeaver** - Database GUI
- **Android Studio** - Android emulator
- **Xcode** - iOS development (Mac only)

---

## 🖥️ MacBook Infrastructure Readiness

### ✅ MacBook is Ready!

Your MacBook is **fully compatible** with all development requirements:

#### ✅ System Requirements Met
- **macOS**: ✅ Compatible (12.0+)
- **RAM**: ✅ 16GB+ recommended (32GB ideal)
- **Storage**: ✅ 256GB+ SSD (512GB+ ideal)
- **Processor**: ✅ Apple Silicon (M1/M2/M3) or Intel Core i5+

#### ✅ Native Services Support
- **PostgreSQL 16**: ✅ Native via Homebrew
- **Redis 7**: ✅ Native via Homebrew
- **Docker Desktop**: ✅ Native Apple Silicon support
- **Flutter**: ✅ Full macOS support
- **Python**: ✅ Native via Homebrew

#### ✅ Development Tools Support
- **VS Code**: ✅ Full macOS support
- **Xcode**: ✅ Native macOS (for iOS development)
- **Android Studio**: ✅ macOS compatible
- **Git**: ✅ Native macOS support

---

## 📖 Development Starting Point

### Step 1: Environment Setup (Day 1)

```bash
# 1. Clone repository (if not already done)
git clone <repository-url>
cd agentmitra

# 2. Run automated setup
./scripts/setup-local-environment.sh

# 3. Verify all services
./scripts/verify-local-services.sh
```

**Expected Output:**
```
✅ PostgreSQL: Running
✅ Redis: Running
✅ Python: Installed (3.11.x)
✅ Node.js: Installed (20.x.x)
✅ Flutter: Installed (3.24.x)
✅ Flyway: Installed
```

### Step 2: Database Setup (Day 2)

```bash
# 1. Copy Flyway configuration
cp flyway.conf.example flyway.conf

# 2. Review and update flyway.conf if needed
nano flyway.conf

# 3. Create migration directory structure
mkdir -p db/migration

# 4. Create initial migration files (see database-design.md)
# V1__Create_shared_schema.sql
# V2__Create_tenant_schemas.sql
# V3__Create_lic_schema_tables.sql

# 5. Run Flyway migrations
flyway -configFiles=flyway.conf migrate

# 6. Verify migrations
flyway -configFiles=flyway.conf info
```

### Step 3: Backend Setup (Day 3)

```bash
# 1. Navigate to backend directory
cd backend

# 2. Activate virtual environment
source venv/bin/activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Set up environment variables
cp .env.example .env.local
nano .env.local  # Update with local settings

# 5. Start backend server
uvicorn main:app --reload --port 8012

# 6. Test API (in another terminal)
curl http://localhost:8012/health
```

### Step 4: Flutter Setup (Day 4)

```bash
# 1. Navigate to project root
cd agentmitra

# 2. Get Flutter dependencies
flutter pub get

# 3. Verify Flutter setup
flutter doctor

# 4. Run Flutter app
flutter run
```

### Step 5: Project Structure Implementation (Day 5)

Follow `project-structure.md` to implement:
- ✅ Complete directory structure
- ✅ Feature modules
- ✅ Shared resources
- ✅ Configuration files

---

## 🗂️ Reference Documents

### Core Design Documents

1. **Project Structure**: [`discovery/design/project-structure.md`](../../discovery/design/project-structure.md)
   - Complete directory structure
   - Feature modules organization
   - Backend structure

2. **Database Design**: [`discovery/design/database-design.md`](../../discovery/design/database-design.md)
   - Complete database schema
   - Multi-tenant architecture
   - Migration strategy

3. **Project Plan**: [`discovery/implementation/project-plan.md`](../../discovery/implementation/project-plan.md)
   - 20-week implementation timeline
   - Phase-by-phase breakdown
   - Resource allocation

### Development Guides

- **Local Setup**: [`docs/development/LOCAL_DEVELOPMENT_SETUP.md`](./LOCAL_DEVELOPMENT_SETUP.md)
- **Database Migrations**: See Flyway section below
- **API Development**: See `python-backend-design.md`
- **Flutter Development**: See `pages-design.md` and `wireframes.md`

---

## 🗄️ Database Setup with Flyway

### Why Flyway?

- ✅ **Version Control**: Track all database changes
- ✅ **Reproducibility**: Same database state across environments
- ✅ **Rollback**: Easy to revert migrations
- ✅ **Team Collaboration**: Shared migration files

### Flyway Migration Structure

```
db/migration/
├── V1__Create_shared_schema.sql
├── V2__Create_tenant_schemas.sql
├── V3__Create_lic_schema_tables.sql
├── V4__Create_user_management_tables.sql
├── V5__Create_insurance_domain_tables.sql
├── V6__Create_payment_tables.sql
├── V7__Create_communication_tables.sql
├── V8__Create_presentation_tables.sql  # New!
├── V9__Create_analytics_tables.sql
└── V10__Create_portal_tables.sql
```

### Creating Migrations

```bash
# 1. Create migration file
touch db/migration/V8__Create_presentation_tables.sql

# 2. Add SQL from database-design.md
# (Copy presentation carousel tables)

# 3. Run migration
flyway -configFiles=flyway.conf migrate

# 4. Verify
flyway -configFiles=flyway.conf info
```

### Migration Naming Convention

```
V{version}__{description}.sql

Examples:
- V1__Create_shared_schema.sql
- V8__Create_presentation_tables.sql
- V9__Add_presentation_analytics.sql
```

---

## 🔄 Daily Development Workflow

### Morning Start

```bash
# 1. Start services (if not auto-started)
brew services start postgresql@16
brew services start redis

# 2. Activate Python environment
cd backend
source venv/bin/activate

# 3. Start backend (Terminal 1)
uvicorn main:app --reload --port 8012

# 4. Start Flutter (Terminal 2)
cd agentmitra
flutter run
```

### Before Committing

```bash
# 1. Run tests
flutter test
cd backend && pytest

# 2. Run linters
flutter analyze
cd backend && black . && flake8 .

# 3. Check database migrations
flyway -configFiles=flyway.conf validate

# 4. Commit changes
git add .
git commit -m "feat: description"
```

---

## 🐛 Troubleshooting

### Common Issues

#### PostgreSQL Won't Start
```bash
# Check status
brew services list | grep postgresql

# Restart
brew services restart postgresql@16

# Check logs
tail -f /opt/homebrew/var/log/postgresql@16.log
```

#### Redis Connection Failed
```bash
# Check status
brew services list | grep redis

# Restart
brew services restart redis

# Test connection
redis-cli ping
```

#### Flutter Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check doctor
flutter doctor -v
```

#### Python Environment Issues
```bash
# Recreate virtual environment
cd backend
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## 📊 Development Progress Tracking

### Week 1 Checklist

- [ ] Local development environment set up
- [ ] All required software installed
- [ ] PostgreSQL and Redis running
- [ ] Database migrations created
- [ ] Backend server running
- [ ] Flutter app running
- [ ] Project structure implemented
- [ ] CI/CD pipelines configured

### Week 2 Checklist

- [ ] Database schema complete
- [ ] Flyway migrations working
- [ ] ORM models created
- [ ] Seed data loaded
- [ ] Database performance optimized

---

## 🎓 Learning Resources

### Flutter
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

### Python/FastAPI
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)

### PostgreSQL
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Flyway Documentation](https://flywaydb.org/documentation/)

### Database Design
- Review `database-design.md` for complete schema
- Review `multitenant-architecture-design.md` for multi-tenant patterns

---

## ✅ Next Steps

1. **Complete Setup**: Run `./scripts/setup-local-environment.sh`
2. **Verify Services**: Run `./scripts/verify-local-services.sh`
3. **Read Documentation**: Review all design documents
4. **Start Development**: Follow Phase 1 Week 1 tasks
5. **Join Team**: Set up communication channels

---

**Ready to Start?** Run the setup script and begin development! 🚀

```bash
./scripts/setup-local-environment.sh
```

---

**Last Updated:** 2024-01-XX  
**MacBook Compatibility:** ✅ Fully Compatible  
**Setup Time:** ~30-45 minutes

