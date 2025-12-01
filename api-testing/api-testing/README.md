# Agent Mitra API Testing Suite

This directory contains the comprehensive API testing setup for the Agent Mitra backend using Postman and Newman.

## 📁 Directory Structure

```
api-testing/
├── postman/
│   ├── agent-mitra-api-collection.json          # Postman collection
│   └── agent-mitra-local.postman_environment.json # Environment variables
├── scripts/
│   └── run-api-tests.sh                         # Newman test runner
├── reports/                                      # Generated test reports (auto-excluded from git)
└── README.md                                    # This file
```

## 🚀 Quick Start

### Prerequisites

1. **Backend running**: Make sure the Agent Mitra backend is running on `http://localhost:8015`
2. **Pioneer services**: Ensure Pioneer containers are running (`docker-compose up pioneer services`)
3. **Node.js**: Required for Newman and HTML reporter

### Install Newman (if not already installed)

```bash
npm install -g newman newman-reporter-html
```

### Run API Tests

```bash
cd api-testing/scripts
./run-api-tests.sh
```

The script will:
- ✅ Run all API tests using Newman
- 📊 Generate HTML report with detailed results
- 🌐 Auto-open the report in your browser
- 📋 Provide CLI output with test status

## 📋 Test Coverage

### ✅ Working Endpoints (v1.0)

#### Authentication
- **POST** `/api/v1/auth/login` - Super Admin & Provider Admin login

#### Health Check
- **GET** `/health` - System health status

#### Feature Flags
- **GET** `/api/v1/feature-flags/check/{flag_name}` - **PUBLIC** - Check flag status
- **GET** `/api/v1/feature-flags/user/{user_id}` - **ADMIN** - Get user's flags
- **GET** `/api/v1/feature-flags/all` - **ADMIN** - Get all flags (local DB)
- **POST** `/api/v1/feature-flags/flags` - **ADMIN** - Create Pioneer flag
- **PUT** `/api/v1/feature-flags/flags/{flag_id}` - **ADMIN** - Update Pioneer flag
- **DELETE** `/api/v1/feature-flags/flags/{flag_id}` - **ADMIN** - Delete Pioneer flag

### 🔐 Security Testing

- **Super Admin Access**: Full access to all admin endpoints
- **Provider Admin Access**: Correctly denied (403) on admin endpoints
- **Public Access**: Unauthenticated access to public endpoints only

## 📊 Report Features

The HTML reports include:
- ✅ Test execution summary
- 📈 Pass/fail statistics
- ⏱️ Response times
- 📋 Detailed request/response data
- 🔍 Error analysis
- 📊 Visual charts and graphs

## 🔧 Postman Collection

### Import Instructions

1. Open Postman
2. Click "Import" button
3. Select "File"
4. Choose `postman/agent-mitra-api-collection.json`
5. Select `postman/agent-mitra-local.postman_environment.json` as environment

### Environment Variables

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `base_url` | Backend API URL | `http://localhost:8015` |
| `super_admin_token` | JWT for super admin | Auto-set by login test |
| `provider_admin_token` | JWT for provider admin | Auto-set by login test |
| `super_admin_user_id` | Super admin user ID | `550e8400-e29b-41d4-a716-446655440000` |
| `test_flag_id` | Created test flag ID | Auto-set by create test |

## 🎯 Test Scenarios

### Authentication Flow
1. Login as Super Admin → Get token
2. Login as Provider Admin → Get token
3. Verify permissions in response

### Feature Flag Operations
1. **Public Access**: Check flag status without authentication
2. **Admin CRUD**: Create → Update → Delete flag cycle
3. **Access Control**: Verify 403 for non-admin users

### Performance & Reliability
- Response time validation (< 2000ms)
- Proper HTTP status codes
- JSON response validation

## 📈 Adding New Tests

### To add new API endpoints:

1. **Edit the collection** in Postman
2. **Add the new request** with proper authentication
3. **Add test scripts** for validation
4. **Export and update** the collection JSON
5. **Commit changes** to git

### Test Script Template

```javascript
pm.test("Test description", function () {
    // Status code check
    pm.response.to.have.status(200);

    // Response validation
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('expected_field');

    // Set collection variables if needed
    pm.collectionVariables.set('variable_name', jsonData.value);
});
```

## 🚨 Troubleshooting

### Common Issues

**Newman not found:**
```bash
npm install -g newman newman-reporter-html
```

**Backend not running:**
```bash
cd backend && python -m uvicorn main:app --host 127.0.0.1 --port 8015 --reload
```

**Pioneer services not running:**
```bash
docker-compose -f docker-compose.prod.yml up -d pioneer-compass-server pioneer-nats pioneer-scout
```

**Permission denied on script:**
```bash
chmod +x api-testing/scripts/run-api-tests.sh
```

## 📋 Future Enhancements

- [ ] Add more API endpoints as they become available
- [ ] Performance testing with load simulation
- [ ] Automated CI/CD integration
- [ ] Multi-environment support (dev/staging/prod)
- [ ] Data-driven testing for edge cases

---

## 📞 Support

For issues with API testing setup or questions about the test suite, check:

1. Backend logs: `tail -f backend/logs/app.log`
2. Newman verbose output: Add `--verbose` flag to test script
3. Postman console for request debugging

---

**Generated HTML reports are automatically excluded from git to keep repository clean.** 📁
