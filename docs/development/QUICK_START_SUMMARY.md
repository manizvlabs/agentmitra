# Agent Mitra - Quick Start Summary

> **Status:** ✅ Setup Complete | **Backend:** Port 8012 | **Portal:** Port 3012

## ✅ Setup Complete!

All services are running and configured:

### Service Status

| Service | Status | Port | Details |
|---------|--------|------|---------|
| **PostgreSQL 16** | ✅ Running | 5432 | Database: `agentmitra_dev` |
| **Redis 7** | ✅ Running | 6379 | Cache service |
| **Backend API** | ✅ Running | **8012** | FastAPI server |
| **Docker** | ✅ Running | - | Container service |
| **Python 3.11** | ✅ Installed | - | Backend environment |
| **Node.js 20** | ✅ Installed | - | Portal environment |
| **Flutter 3.13** | ✅ Installed | - | Mobile app |
| **Flyway** | ✅ Installed | - | Database migrations |

---

## 🚀 Quick Commands

### Start Backend API (Port 8012)

```bash
cd backend
source venv/bin/activate
python main.py
# Or: uvicorn main:app --reload --port 8012
```

**Test:** `curl http://localhost:8012/health`

### Start Flutter App

```bash
flutter run
```

### Start Portal (Port 3012)

```bash
cd config-portal/frontend
npm start
# Configure to use port 3012
```

### Database Migrations (Flyway)

```bash
# Check migration status
flyway -configFiles=flyway.conf info

# Run migrations
flyway -configFiles=flyway.conf migrate

# Validate migrations
flyway -configFiles=flyway.conf validate
```

---

## 📋 Configuration Files

### Environment Variables

**File:** `.env.local` (create if needed)

```bash
# Backend API
API_PORT=8012
API_URL=http://localhost:8012

# Portal
PORTAL_PORT=3012
PORTAL_URL=http://localhost:3012

# Database
DATABASE_URL=postgresql://agentmitra:agentmitra_dev@localhost:5432/agentmitra_dev
POSTGRES_USER=agentmitra
POSTGRES_PASSWORD=agentmitra_dev
POSTGRES_DB=agentmitra_dev

# Redis
REDIS_URL=redis://localhost:6379

# Feature Flags
ENABLE_MOCK_DATA=false  # Use real data with seed data
```

### Flyway Configuration

**File:** `flyway.conf`

```properties
flyway.url=jdbc:postgresql://localhost:5432/agentmitra_dev
flyway.user=agentmitra
flyway.password=agentmitra_dev
flyway.schemas=shared,lic_schema,audit
flyway.locations=filesystem:db/migration
```

---

## 🗄️ Database Setup

### Current Database Status

- **Database:** `agentmitra_dev`
- **User:** `agentmitra`
- **Password:** `agentmitra_dev`
- **Schemas:** `shared`, `lic_schema`, `audit`
- **Migrations:** Ready (no migrations yet)

### Next Steps for Database

1. **Create Migration Files** in `db/migration/`:
   - `V1__Create_shared_schema.sql`
   - `V2__Create_tenant_schemas.sql`
   - `V3__Create_lic_schema_tables.sql`
   - `V8__Create_presentation_tables.sql`

2. **Add Seed Data** (not mock data):
   - Create seed data migrations: `R__Seed_initial_data.sql`
   - Use Flyway repeatable migrations for seed data

3. **Run Migrations:**
   ```bash
   flyway -configFiles=flyway.conf migrate
   ```

---

## 🔧 Development Workflow

### Daily Start

```bash
# 1. Start services (if not auto-started)
brew services start postgresql@16
brew services start redis

# 2. Start backend (Terminal 1)
cd backend
source venv/bin/activate
python main.py  # Runs on port 8012

# 3. Start Flutter (Terminal 2)
flutter run

# 4. Start Portal (Terminal 3, optional)
cd config-portal/frontend
npm start  # Configure for port 3012
```

### Verify Services

```bash
# Check all services
./scripts/verify-local-services.sh

# Test backend API
curl http://localhost:8012/health
curl http://localhost:8012/api/v1/health

# Test database
psql -U agentmitra -d agentmitra_dev -c "SELECT version();"
```

---

## 📝 Important Notes

### Port Configuration

- **Backend API:** Port **8012** (not 8000)
- **Portal:** Port **3012** (not 3000)
- **PostgreSQL:** Port 5432 (default)
- **Redis:** Port 6379 (default)

### Data Strategy

- ❌ **No Mock Data** - Use real data only
- ✅ **Seed Data** - Use Flyway migrations for initial data
- ✅ **Real Database** - All development uses `agentmitra_dev` database

### Database Credentials

- **User:** `agentmitra`
- **Password:** `agentmitra_dev`
- **Database:** `agentmitra_dev`

---

## 🐛 Troubleshooting

### Backend Not Starting

```bash
# Check if port 8012 is in use
lsof -i :8012

# Kill process if needed
kill -9 <PID>

# Restart backend
cd backend
source venv/bin/activate
python main.py
```

### Database Connection Issues

```bash
# Test connection
psql -U agentmitra -d agentmitra_dev

# Reset password if needed
psql -U $USER -d postgres -c "ALTER USER agentmitra WITH PASSWORD 'agentmitra_dev';"
```

### Flutter Issues

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

---

## ✅ Setup Verification Checklist

- [x] PostgreSQL 16 running and connected
- [x] Redis 7 running
- [x] Backend API running on port 8012
- [x] Python virtual environment created
- [x] Flutter dependencies installed
- [x] Flyway configured and working
- [x] Database user and database created
- [ ] Migration files created (next step)
- [ ] Seed data migrations created (next step)

---

## 🎯 Next Steps

1. **Create Database Migrations**
   - Review `discovery/design/database-design.md`
   - Create migration files in `db/migration/`
   - Add seed data migrations

2. **Run Migrations**
   ```bash
   flyway -configFiles=flyway.conf migrate
   ```

3. **Start Development**
   - Follow `project-plan.md` Phase 1 Week 1
   - Implement project structure
   - Begin backend API development

---

**Last Updated:** 2024-11-21  
**Backend Port:** 8012  
**Portal Port:** 3012  
**Status:** ✅ Ready for Development

