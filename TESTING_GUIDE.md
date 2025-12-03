# Agent Mitra - Web Build Testing Guide

## ✅ Build Status: **SUCCESS**

The Flutter web build completed successfully! The app is ready for testing.

---

## 📋 Pre-Deployment Checklist

Before testing, ensure these services are running:

### 1. Local Services (MacBook Brew)
```bash
# Start PostgreSQL 16
brew services start postgresql@16

# Start Redis
brew services start redis

# Verify database exists
psql -U agentmitra -d agentmitra_dev -c "SELECT schema_name FROM information_schema.schemata WHERE schema_name = 'lic_schema';"
```

### 2. Docker Services
The deployment script will handle Docker services automatically.

---

## 🚀 Quick Start - Deploy Everything

### Option 1: Use Deployment Script (Recommended)
```bash
cd /Users/manish/Documents/GitHub/zero/agentmitra
./scripts/deploy/start-prod.sh all
```

This will:
- ✅ Check Docker daemon
- ✅ Validate .env file
- ✅ Generate SSL certificates (if needed)
- ✅ Build Flutter web app (already done ✓)
- ✅ Start all Docker services (Backend, Portal, Nginx, Pioneer, MinIO, Monitoring)
- ✅ Setup MinIO bucket
- ✅ Deploy Flutter web app on Nginx (localhost:80)

### Option 2: Manual Docker Compose
```bash
cd /Users/manish/Documents/GitHub/zero/agentmitra
docker compose -f docker-compose.prod.yml up -d nginx backend portal minio pioneer-nats pioneer-compass-server pioneer-scout pioneer-compass-client
```

---

## 🌐 Service URLs After Deployment

| Service | URL | Credentials |
|---------|-----|-------------|
| **Flutter Web App** | http://localhost:80 | N/A |
| **Backend API** | http://localhost:8012 | See .env |
| **Config Portal** | http://localhost:3013 | See .env |
| **Pioneer Admin UI** | http://localhost:4000 | See Pioneer config |
| **Pioneer API** | http://localhost:4001 | See Pioneer config |
| **MinIO Console** | http://localhost:9001 | minioadmin / minioadmin |
| **MinIO API** | http://localhost:9000 | minioadmin / minioadmin |

---

## 🧪 Testing Credentials

### RBAC Test Users (All use password: `testpassword`)

| Role | Phone Number | Access Level |
|------|-------------|--------------|
| **Super Admin** | +919876543200 | Full system access (59 permissions) |
| **Provider Admin** | +919876543201 | Insurance provider management |
| **Regional Manager** | +919876543202 | Regional operations (19 permissions) |
| **Senior Agent** | +919876543203 | Agent operations + inherited permissions (16 permissions) |
| **Junior Agent** | +919876543204 | Basic agent operations (7 permissions) |
| **Policyholder** | +919876543205 | Customer access (5 permissions) |
| **Support Staff** | +919876543206 | Support operations (8 permissions) |

---

## 📱 Testing Workflow

### 1. Access the Application
```
Open browser: http://localhost:80
```

### 2. Test Navigation Architecture (Phase 1 Complete ✅)

#### Customer Portal (Policyholder)
- Login with: `+919876543205` / `testpassword`
- **Expected:** 5 bottom tabs navigation:
  - 🏠 Home (Customer Dashboard)
  - 📄 Policies
  - 💬 Chat
  - 📚 Learning
  - 👤 Profile

#### Agent Portal (Junior/Senior Agent)
- Login with: `+919876543204` (Junior) or `+919876543203` (Senior)
- **Expected:** 5 bottom tabs navigation:
  - 📊 Dashboard (with Presentation Carousel)
  - 👥 Customers
  - 📈 Analytics
  - 📢 Campaigns
  - 👤 Profile
- **Expected:** Hamburger menu with advanced tools

#### Admin Portal (Super Admin / Provider Admin / Regional Manager)
- Login with: `+919876543200` (Super Admin) or `+919876543201` (Provider Admin)
- **Expected:** Role-based navigation with contextual tabs
- **Expected:** Admin drawer menu with management tools

### 3. Test VyaptIX Branding
- ✅ Splash screen shows VyaptIX logo
- ✅ "Powered by VyaptIX®" displayed
- ✅ Copyright notice: "© 2025 Agent Mitra™. All Rights Reserved."
- ✅ Trademark information displayed
- ✅ Unified VyaptIX blue theme throughout app

### 4. Test Theme Consistency
- ✅ App bars use VyaptIX blue (#0083B0)
- ✅ Navigation bars use VyaptIX blue
- ✅ Buttons use VyaptIX blue
- ✅ Consistent color scheme across all screens

---

## 🔍 Verification Checklist

### Build Verification
- [x] Flutter web build completed successfully
- [x] Build output in `build/web/` directory
- [x] No compilation errors
- [x] All dependencies resolved

### Navigation Verification
- [ ] Customer navigation shows 5 tabs
- [ ] Agent navigation shows 5 tabs
- [ ] Admin navigation adapts to role
- [ ] Tab switching works correctly
- [ ] Drawer menus functional

### Branding Verification
- [ ] VyaptIX logo displays on splash screen
- [ ] Copyright footer appears
- [ ] Trademark symbols correct (™ and ®)
- [ ] Theme colors match VyaptIX brand

### API Integration Verification
- [ ] Backend API accessible at http://localhost:8012
- [ ] API proxy working through Nginx
- [ ] CORS headers configured correctly
- [ ] Authentication endpoints functional

---

## 🐛 Troubleshooting

### Issue: Nginx not serving Flutter app
```bash
# Check if nginx container is running
docker ps | grep nginx

# Check nginx logs
docker compose -f docker-compose.prod.yml logs nginx

# Verify build/web directory exists
ls -la build/web/

# Restart nginx
docker compose -f docker-compose.prod.yml restart nginx
```

### Issue: Backend API not accessible
```bash
# Check backend container
docker ps | grep backend

# Check backend logs
docker compose -f docker-compose.prod.yml logs backend

# Verify PostgreSQL is running
brew services list | grep postgresql

# Verify Redis is running
brew services list | grep redis
```

### Issue: CORS errors
- Check `.env` file has correct `CORS_ORIGINS` setting
- Should include: `http://localhost:80,http://localhost:8080`
- Restart backend after changing .env

### Issue: Flutter app shows blank screen
- Check browser console for errors (F12)
- Verify API_BASE_URL in .env points to http://localhost:8012
- Check network tab for failed API calls

---

## 📊 Service Status Commands

```bash
# View all service status
docker compose -f docker-compose.prod.yml ps

# View logs for specific service
docker compose -f docker-compose.prod.yml logs -f [service-name]

# Stop all services
docker compose -f docker-compose.prod.yml down

# Restart specific service
docker compose -f docker-compose.prod.yml restart [service-name]
```

---

## 🎯 What's Ready for Testing

### ✅ Phase 1: Navigation Architecture Foundation (COMPLETE)
- Customer Navigation Container (5 tabs)
- Agent Navigation Container (5 tabs + drawer)
- Admin Navigation Container (role-based)
- Navigation Router with RBAC protection
- Main app routing updated

### ✅ VyaptIX Branding (COMPLETE)
- VyaptIX logo widget
- Unified theme (VyaptIX blue)
- Copyright and trademark notices
- Splash screen branding
- Consistent theme across navigation

### ⏳ Phase 2-9: Pending Implementation
- Customer Portal screens (wireframe conformance)
- Agent Portal screens (with Presentation Carousel)
- Admin Portal screens
- Onboarding flow
- Config Portal updates

---

## 📝 Testing Notes

1. **First Time Setup:**
   - Ensure PostgreSQL and Redis are running locally
   - Run deployment script to start all services
   - Wait for all containers to be healthy (check with `docker ps`)

2. **Testing Navigation:**
   - Login with different user roles
   - Verify correct navigation container loads
   - Test tab switching
   - Test drawer menus

3. **Testing Branding:**
   - Check splash screen for VyaptIX logo
   - Verify copyright footer appears
   - Confirm theme colors match VyaptIX blue

4. **API Testing:**
   - Use Postman collections in `api-testing/postman/`
   - Test authentication endpoints
   - Verify RBAC permissions work correctly

---

## 🚀 Next Steps After Testing

Once Phase 1 testing is complete:
1. Proceed with Phase 2: Customer Portal Restructuring
2. Implement wireframe-conformant screens
3. Integrate real API endpoints
4. Remove all mock data

---

## 📞 Support

For issues or questions:
- Check logs: `docker compose -f docker-compose.prod.yml logs`
- Review deployment script: `scripts/deploy/start-prod.sh`
- Check nginx config: `nginx/nginx.conf`
- Review project plan: `docs/implementation/project-plan-1-Dec.md`

---

**Last Updated:** $(date)
**Build Status:** ✅ SUCCESS
**Ready for Testing:** ✅ YES
