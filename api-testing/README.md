# 🧪 Agent Mitra API Testing Suite

Comprehensive API testing framework for Agent Mitra backend using Postman Collections and Newman.

## 📋 Overview

This testing suite provides automated API testing for the Agent Mitra application with **dynamic base URLs** for different environments (local, staging, production). It includes authentication testing, OTP services, feature flags, and comprehensive test coverage.

## 📁 Project Structure

```
api-testing/
├── postman/
│   ├── agent-mitra-api-collection.json                 # Main Postman collection
│   ├── agent-mitra-local.postman_environment.json      # Local development env
│   ├── agent-mitra-staging.postman_environment.json    # Staging environment
│   └── agent-mitra-production.postman_environment.json # Production environment
├── newman/
│   ├── run-tests.sh                         # Automated testing script
│   └── reports/                             # Generated test reports (auto-created)
└── README.md                                # This documentation
```

## 🚀 Quick Start

### Prerequisites

1. **Backend Running**: Ensure Agent Mitra backend is running on `http://localhost:8015`
2. **Newman Installed**: Install Newman CLI
   ```bash
   npm install -g newman newman-reporter-html
   ```
3. **Database**: Ensure PostgreSQL and Redis are running with seeded users

### Running Tests

```bash
# Run all tests (local environment by default)
cd api-testing/newman
./run-tests.sh all

# Run tests on different environments
./run-tests.sh all staging       # All tests on staging
./run-tests.sh auth production   # Auth tests on production

# Run specific test categories
./run-tests.sh auth local        # Authentication on local
./run-tests.sh otp staging       # OTP services on staging
./run-tests.sh health            # Health checks (local default)
./run-tests.sh features prod     # Feature flags on production
```

## 📊 Test Categories

### 🔐 Authentication & Authorization
**Endpoints Tested:**
- ✅ Super Admin Login (`+919876543200`)
- ✅ Provider Admin Login (`+919876543201`)
- ✅ Regional Manager Login (`+919876543202`)
- ✅ Senior Agent Login (`+919876543203`)
- ✅ Junior Agent Login (`+919876543204`)
- ✅ Policyholder Login (`+919876543205`)
- ✅ Support Staff Login (`+919876543206`)
- ✅ Logout functionality

**Features Verified:**
- JWT token generation
- Role-based permissions
- RBAC (Role-Based Access Control)
- Token validation

### 📱 OTP & External Services
**Endpoints Tested:**
- ✅ Send SMS OTP (Mock mode: returns `123456`)
- ✅ Send WhatsApp OTP (Mock mode: returns `123456`)
- ✅ SMS delivery status check
- ✅ WhatsApp delivery status check
- ✅ Send SMS messages
- ✅ Send WhatsApp messages
- ✅ AI Chat completion

**Features Verified:**
- Mock OTP functionality
- External service integration
- Message delivery tracking
- AI service integration

### 🏥 Health Check
**Endpoints Tested:**
- ✅ System health status
- ✅ Database connectivity
- ✅ Service availability

### 🚩 Feature Flags & Configuration
**Endpoints Tested:**
- ✅ Public feature flag status
- ✅ User-specific feature flags
- ✅ Admin feature flag management
- ✅ Create/Update/Delete feature flags
- ✅ Access control verification

## 🌐 Dynamic URL Configuration

The testing suite supports **dynamic base URLs** for different deployment environments:

### Environment Configurations

| Environment | Base URL | Host URL | API Path |
|-------------|----------|----------|----------|
| **Local** | `http://localhost:8015/api/v1` | `http://localhost:8015` | `/api/v1` |
| **Staging** | `https://api-staging.agentmitra.com/api/v1` | `https://api-staging.agentmitra.com` | `/api/v1` |
| **Production** | `https://api.agentmitra.com/api/v1` | `https://api.agentmitra.com` | `/api/v1` |

### URL Structure
- **API Endpoints**: `{{base_url}}/auth/login` → `http://localhost:8015/api/v1/auth/login`
- **Health Check**: `{{api_host}}/health` → `http://localhost:8015/health`
- **All endpoints** use `{{base_url}}` variable (includes `/api/v1`)

## 🔧 Environment Variables

### Connection & Configuration
| Variable | Value | Description |
|----------|-------|-------------|
| `base_url` | `http://localhost:8015` | 🔗 Base URL for API endpoints |

### Authentication Tokens
| Variable | Description |
|----------|-------------|
| `super_admin_token` | JWT token for Super Admin (+919876543200) |
| `provider_admin_token` | JWT token for Provider Admin (+919876543201) |
| `regional_manager_token` | JWT token for Regional Manager (+919876543202) |
| `senior_agent_token` | JWT token for Senior Agent (+919876543203) |
| `junior_agent_token` | JWT token for Junior Agent (+919876543204) |
| `policyholder_token` | JWT token for Policyholder (+919876543205) |
| `support_staff_token` | JWT token for Support Staff (+919876543206) |

### User Credentials
| Variable | Value | Description |
|----------|-------|-------------|
| `super_admin_phone` | `+919876543200` | Super Admin login |
| `super_admin_password` | `testpassword` | All users use same password |
| `provider_admin_phone` | `+919876543201` | Provider Admin login |
| `regional_manager_phone` | `+919876543202` | Regional Manager login |
| `senior_agent_phone` | `+919876543203` | Senior Agent login |
| `junior_agent_phone` | `+919876543204` | Junior Agent login |
| `policyholder_phone` | `+919876543205` | Policyholder login |
| `support_staff_phone` | `+919876543206` | Support Staff login |

### Test Data
| Variable | Value | Description |
|----------|-------|-------------|
| `test_phone_number` | `+919876543210` | 📱 Test phone for OTP |
| `test_otp` | `123456` | 📱 Mock OTP value |
| `message_id` | *(dynamic)* | 📱 Message ID from sends |

### User IDs & References
| Variable | Description |
|----------|-------------|
| `super_admin_user_id` | User ID for Super Admin |
| `provider_admin_user_id` | User ID for Provider Admin |
| `test_flag_id` | ID of created test feature flag |

## 🎯 User Roles & Permissions

| Role | Phone | Permissions | Description |
|------|-------|-------------|-------------|
| **Super Admin** | +919876543200 | 1 | Full system access (`system.admin`) |
| **Provider Admin** | +919876543201 | 29 | Insurance provider management |
| **Regional Manager** | +919876543202 | 20 | Regional operations |
| **Senior Agent** | +919876543203 | 16 | Agent operations + campaigns |
| **Junior Agent** | +919876543204 | 7 | Basic agent operations |
| **Policyholder** | +919876543205 | 5 | Customer access |
| **Support Staff** | +919876543206 | 8 | Support operations |

## 📈 Test Reports

Test reports are automatically generated in `api-testing/newman/reports/`:

- **HTML Reports**: Detailed test results with pass/fail status
- **CLI Output**: Real-time test execution with colored output
- **Timestamps**: Each run creates timestamped reports

Example report: `Authentication_report_20241201_143022.html`

## 🛠️ Manual Testing with Postman

1. **Import Collection**: Import `agent-mitra-api-collection.json`
2. **Import Environment**: Import `agent-mitra-local.postman_environment.json`
3. **Select Environment**: Choose "Agent Mitra Local Development"
4. **Run Tests**: Use Collection Runner or individual requests

## 🔄 CI/CD Integration

For automated testing in CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Run API Tests
  run: |
    cd api-testing/newman
    ./run-tests.sh all

- name: Upload Test Reports
  uses: actions/upload-artifact@v3
  with:
    name: api-test-reports
    path: api-testing/newman/reports/
```

## 🐛 Troubleshooting

### Backend Not Running
```bash
# Start backend
cd backend
PYTHONPATH=/Users/manish/Documents/GitHub/zero/agentmitra/backend \
./venv/bin/python -m uvicorn main:app --host 127.0.0.1 --port 8015 --reload
```

### Newman Not Installed
```bash
npm install -g newman newman-reporter-html
```

### Database Issues
```bash
# Ensure PostgreSQL and Redis are running
brew services start postgresql@16
brew services start redis
```

### Permission Errors
- Ensure all users have `testpassword` as password
- Check RBAC configuration in database
- Verify user roles are correctly assigned

## 📋 Test Coverage

### ✅ Implemented Tests
- [x] Authentication for all 7 user roles
- [x] JWT token validation
- [x] Role-based permissions verification
- [x] OTP mock functionality (SMS & WhatsApp)
- [x] External service status checks
- [x] AI service integration
- [x] Feature flag management
- [x] Health check endpoints

### 🔄 Future Enhancements
- [ ] Full API coverage (Policies, Customers, Analytics, etc.)
- [ ] Performance testing
- [ ] Load testing
- [ ] Integration with Flutter app tests
- [ ] Automated deployment verification

## 🤝 Contributing

1. **Add New Tests**: Update collection with new endpoints
2. **Update Environment**: Add new variables with proper categorization
3. **Modify Scripts**: Update Newman runner for new test categories
4. **Documentation**: Keep README and inline docs updated

## 📞 Support

For issues with API testing:
1. Check backend logs
2. Verify database connectivity
3. Review Newman reports
4. Check environment variable configuration

---

**Last Updated**: December 1, 2024
**Test Framework**: Postman Collections + Newman
**Environment**: Local Development
