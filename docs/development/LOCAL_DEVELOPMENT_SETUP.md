# Agent Mitra - Local Development Setup Guide

> **MacBook Compatible** ✅ | **Production Parity** ✅ | **One-Command Setup** ✅

## 📋 Table of Contents

- [1. Prerequisites & Software Requirements](#1-prerequisites--software-requirements)
- [2. MacBook Infrastructure Readiness](#2-macbook-infrastructure-readiness)
- [3. Quick Start (One-Command Setup)](#3-quick-start-one-command-setup)
- [4. Manual Setup (Step-by-Step)](#4-manual-setup-step-by-step)
- [5. Verification & Testing](#5-verification--testing)
- [6. Development Workflow](#6-development-workflow)
- [7. Troubleshooting](#7-troubleshooting)

---

## 1. Prerequisites & Software Requirements

### 1.1 Required Software (MacBook)

#### Core Development Tools
```bash
# ✅ Check what you have installed
which git
which docker
which python3
which node
which flutter
which psql
which redis-cli
```

#### Installation Checklist

| Software | Version | Installation Method | Purpose |
|----------|---------|-------------------|---------|
| **Git** | 2.40+ | `brew install git` | Version control |
| **Docker Desktop** | 24.0+ | [Download](https://www.docker.com/products/docker-desktop) | Containerization |
| **Python** | 3.11+ | `brew install python@3.11` | Backend development |
| **Node.js** | 20.x LTS | `brew install node@20` | Portal development |
| **Flutter** | 3.24+ | [Install Guide](#flutter-installation) | Mobile app |
| **PostgreSQL** | 16.x | `brew install postgresql@16` | Database (native) |
| **Redis** | 7.x | `brew install redis` | Cache (native) |
| **Flyway** | 10.x | `brew install flyway` | Database migrations |
| **Postman** | Latest | [Download](https://www.postman.com/downloads/) | API testing |
| **VS Code** | Latest | [Download](https://code.visualstudio.com/) | IDE (recommended) |

#### Optional but Recommended
- **DBeaver** or **pgAdmin** - Database GUI
- **TablePlus** - Database management
- **Android Studio** - Android emulator
- **Xcode** - iOS development (Mac only)
- **iTerm2** - Terminal replacement

### 1.2 Flutter Installation (MacBook)

```bash
# Install Flutter via Homebrew
brew install --cask flutter

# Verify installation
flutter doctor

# Install iOS development tools (Mac only)
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch

# Accept iOS licenses
sudo xcodebuild -license accept

# Install CocoaPods for iOS
sudo gem install cocoapods
```

### 1.3 Python Environment Setup

```bash
# Install Python 3.11
brew install python@3.11

# Create virtual environment
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install pip dependencies (will be created in backend/)
pip install --upgrade pip
```

### 1.4 Node.js Setup (For Portal)

```bash
# Install Node.js 20 LTS
brew install node@20

# Verify installation
node --version  # Should be v20.x.x
npm --version   # Should be 10.x.x

# Install global tools
npm install -g yarn
npm install -g @angular/cli  # If using Angular
```

---

## 2. MacBook Infrastructure Readiness

### 2.1 System Requirements

✅ **Minimum Requirements:**
- macOS 12.0 (Monterey) or later
- 16GB RAM (32GB recommended)
- 256GB SSD (512GB+ recommended)
- Apple Silicon (M1/M2/M3) or Intel Core i5+

✅ **Recommended Setup:**
- macOS 14.0 (Sonoma) or later
- 32GB RAM
- 512GB+ SSD
- Apple Silicon (M2/M3) for best performance

### 2.2 Native Services Setup (MacBook)

#### PostgreSQL 16 (Native Installation)

```bash
# Install PostgreSQL 16
brew install postgresql@16

# Start PostgreSQL service
brew services start postgresql@16

# Create database user
createuser -s agentmitra

# Create development database
createdb agentmitra_dev

# Verify connection
psql -U agentmitra -d agentmitra_dev -c "SELECT version();"
```

**Configuration:**
- Port: `5432` (default)
- User: `agentmitra`
- Password: (none by default, or set via `.env.local`)
- Data Directory: `/opt/homebrew/var/postgresql@16` (Apple Silicon) or `/usr/local/var/postgresql@16` (Intel)

#### Redis 7 (Native Installation)

```bash
# Install Redis 7
brew install redis

# Start Redis service
brew services start redis

# Verify Redis is running
redis-cli ping  # Should return "PONG"

# Test Redis connection
redis-cli set test "hello"
redis-cli get test  # Should return "hello"
```

**Configuration:**
- Port: `6379` (default)
- Data Directory: `/opt/homebrew/var/redis` (Apple Silicon) or `/usr/local/var/redis` (Intel)

### 2.3 Docker Setup (For Additional Services)

```bash
# Install Docker Desktop for Mac
# Download from: https://www.docker.com/products/docker-desktop

# Verify Docker installation
docker --version
docker-compose --version

# Start Docker Desktop application
# (Launch from Applications folder)

# Verify Docker is running
docker ps
```

**Docker Services (Optional):**
- Nginx (reverse proxy)
- Additional PostgreSQL instances (if needed)
- Redis Cluster (if needed for testing)

---

## 3. Quick Start (One-Command Setup)

### 3.1 Automated Setup Script

```bash
# Clone repository (if not already done)
git clone <repository-url>
cd agentmitra

# Run one-command setup
chmod +x scripts/setup-local-environment.sh
./scripts/setup-local-environment.sh

# This script will:
# ✅ Check all prerequisites
# ✅ Install missing software
# ✅ Set up PostgreSQL and Redis
# ✅ Create database schemas with Flyway
# ✅ Set up Python virtual environment
# ✅ Install Flutter dependencies
# ✅ Create .env.local file
# ✅ Verify all services
```

### 3.2 What Gets Set Up

```
✅ PostgreSQL 16 (native service)
✅ Redis 7 (native service)
✅ Database schemas (via Flyway)
✅ Python backend environment
✅ Flutter dependencies
✅ Environment variables
✅ Git hooks (optional)
```

---

## 4. Manual Setup (Step-by-Step)

### 4.1 Step 1: Install Homebrew (If Not Installed)

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify installation
brew --version
```

### 4.2 Step 2: Install Core Software

```bash
# Update Homebrew
brew update

# Install Git
brew install git

# Install Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop

# Install Python 3.11
brew install python@3.11

# Install Node.js 20 LTS
brew install node@20

# Install PostgreSQL 16
brew install postgresql@16

# Install Redis 7
brew install redis

# Install Flyway
brew install flyway

# Install Flutter
brew install --cask flutter
```

### 4.3 Step 3: Start Native Services

```bash
# Start PostgreSQL
brew services start postgresql@16

# Start Redis
brew services start redis

# Verify services are running
brew services list
```

### 4.4 Step 4: Database Setup with Flyway

```bash
# Navigate to project root
cd agentmitra

# Create Flyway configuration
# (See flyway.conf.example in project)

# Run Flyway migrations
flyway -configFiles=flyway.conf migrate

# Verify migrations
flyway -configFiles=flyway.conf info
```

### 4.5 Step 5: Python Backend Setup

```bash
# Navigate to backend directory
cd backend

# Create virtual environment
python3.11 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env.local
# Edit .env.local with your local settings

# Run database migrations (if using Alembic)
alembic upgrade head

# Start backend server
uvicorn main:app --reload --port 8000
```

### 4.6 Step 6: Flutter App Setup

```bash
# Navigate to project root
cd agentmitra

# Get Flutter dependencies
flutter pub get

# Verify Flutter setup
flutter doctor

# Run Flutter app
flutter run
```

### 4.7 Step 7: Portal Setup (Optional)

```bash
# Navigate to portal directory
cd config-portal/frontend

# Install dependencies
npm install

# Start development server
npm start
# or
yarn start
```

---

## 5. Verification & Testing

### 5.1 Service Verification Script

```bash
# Run verification script
chmod +x scripts/verify-local-services.sh
./scripts/verify-local-services.sh

# Expected output:
# ✅ PostgreSQL: Running on port 5432
# ✅ Redis: Running on port 6379
# ✅ Docker: Running
# ✅ Python: Version 3.11.x
# ✅ Node.js: Version 20.x.x
# ✅ Flutter: Version 3.24.x
# ✅ Flyway: Installed
```

### 5.2 Manual Verification

#### PostgreSQL Verification
```bash
# Connect to database
psql -U agentmitra -d agentmitra_dev

# Check schemas
\dn

# Check tables
\dt lic_schema.*

# Exit
\q
```

#### Redis Verification
```bash
# Connect to Redis
redis-cli

# Test commands
SET test "hello"
GET test
DEL test

# Exit
exit
```

#### Backend API Verification
```bash
# Start backend server
cd backend
source venv/bin/activate
uvicorn main:app --reload

# In another terminal, test API
curl http://localhost:8000/health
curl http://localhost:8000/api/v1/health
```

#### Flutter App Verification
```bash
# Run Flutter app
flutter run

# Run tests
flutter test

# Check for issues
flutter doctor -v
```

---

## 6. Development Workflow

### 6.1 Daily Development Start

```bash
# 1. Start native services (if not auto-started)
brew services start postgresql@16
brew services start redis

# 2. Activate Python environment
cd backend
source venv/bin/activate

# 3. Start backend server
uvicorn main:app --reload --port 8000

# 4. In another terminal, start Flutter app
cd agentmitra
flutter run

# 5. (Optional) Start Portal
cd config-portal/frontend
npm start
```

### 6.2 Database Migration Workflow

```bash
# Create new migration
flyway -configFiles=flyway.conf migrate

# Check migration status
flyway -configFiles=flyway.conf info

# Repair migrations (if needed)
flyway -configFiles=flyway.conf repair

# Validate migrations
flyway -configFiles=flyway.conf validate
```

### 6.3 Code Quality Checks

```bash
# Flutter
flutter analyze
flutter test

# Python
cd backend
source venv/bin/activate
pytest
black --check .
flake8 .

# Portal (if using)
cd config-portal/frontend
npm run lint
npm test
```

---

## 7. Troubleshooting

### 7.1 Common Issues

#### PostgreSQL Connection Issues
```bash
# Check if PostgreSQL is running
brew services list | grep postgresql

# Restart PostgreSQL
brew services restart postgresql@16

# Check PostgreSQL logs
tail -f /opt/homebrew/var/log/postgresql@16.log
```

#### Redis Connection Issues
```bash
# Check if Redis is running
brew services list | grep redis

# Restart Redis
brew services restart redis

# Test Redis connection
redis-cli ping
```

#### Flutter Issues
```bash
# Clean Flutter build
flutter clean
flutter pub get

# Reset Flutter
flutter doctor --android-licenses  # For Android
flutter doctor -v  # Check all issues
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

#### Port Conflicts
```bash
# Check what's using a port
lsof -i :5432  # PostgreSQL
lsof -i :6379  # Redis
lsof -i :8000  # Backend API
lsof -i :3000  # Portal

# Kill process if needed
kill -9 <PID>
```

### 7.2 MacBook-Specific Issues

#### Apple Silicon (M1/M2/M3) Compatibility
- ✅ All tools support Apple Silicon natively
- ✅ Use Homebrew for Apple Silicon: `/opt/homebrew`
- ✅ Docker Desktop has native Apple Silicon support

#### Intel Mac Compatibility
- ✅ All tools support Intel Macs
- ✅ Use Homebrew for Intel: `/usr/local`
- ✅ Docker Desktop supports Intel Macs

#### Permission Issues
```bash
# Fix PostgreSQL permissions
sudo chown -R $(whoami) /opt/homebrew/var/postgresql@16

# Fix Redis permissions
sudo chown -R $(whoami) /opt/homebrew/var/redis
```

---

## 8. Environment Variables

### 8.1 Create `.env.local` File

```bash
# Copy example file
cp .env.example .env.local

# Edit with your local settings
nano .env.local
```

### 8.2 Required Environment Variables

```bash
# Database
DATABASE_URL=postgresql://agentmitra@localhost:5432/agentmitra_dev
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=agentmitra
POSTGRES_PASSWORD=
POSTGRES_DB=agentmitra_dev

# Redis
REDIS_URL=redis://localhost:6379
REDIS_HOST=localhost
REDIS_PORT=6379

# Backend API
API_HOST=localhost
API_PORT=8000
API_URL=http://localhost:8000

# Flutter
FLUTTER_API_URL=http://localhost:8000
FLUTTER_USE_MOCK_DATA=true  # For development

# Feature Flags
ENABLE_MOCK_DATA=true
ENABLE_ANALYTICS=false
ENABLE_PAYMENT_PROCESSING=false
```

---

## 9. Next Steps

After completing setup:

1. ✅ **Verify all services** are running
2. ✅ **Run database migrations** with Flyway
3. ✅ **Start backend server** and test API
4. ✅ **Run Flutter app** and verify UI
5. ✅ **Read development guidelines** in `docs/development/`
6. ✅ **Follow project plan** in `discovery/implementation/project-plan.md`

---

## 10. Support & Resources

- **Project Structure**: `discovery/design/project-structure.md`
- **Database Design**: `discovery/design/database-design.md`
- **Project Plan**: `discovery/implementation/project-plan.md`
- **Deployment Guide**: `discovery/deployment/deployment-design.md`

---

**Last Updated:** 2024-01-XX  
**MacBook Compatibility:** ✅ Fully Compatible  
**Setup Time:** ~30-45 minutes (first time)

