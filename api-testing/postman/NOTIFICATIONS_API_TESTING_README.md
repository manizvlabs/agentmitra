# Agent Mitra Notification API Testing Suite

## 📋 Overview

This comprehensive testing suite validates the **Notification Management API** endpoints for the Agent Mitra platform. The suite includes Postman collections, Newman automation scripts, and detailed reporting for all notification-related functionality.

## 🎯 Test Coverage

### ✅ **Authentication & Authorization**
- Multi-role authentication (Super Admin, Senior Agent, Policyholder)
- JWT token validation
- RBAC (Role-Based Access Control) verification

### ✅ **Core Notification Management**
- **GET** `/api/v1/notifications/` - List notifications with pagination & filtering
- **GET** `/api/v1/notifications/statistics` - Comprehensive notification statistics
- **GET** `/api/v1/notifications/{id}` - Retrieve specific notification
- **POST** `/api/v1/notifications/` - Create new notification
- **PATCH** `/api/v1/notifications/{id}/read` - Mark notification as read
- **PATCH** `/api/v1/notifications/read` - Bulk mark multiple notifications as read
- **DELETE** `/api/v1/notifications/{id}` - Delete notification

### ✅ **Bulk Operations**
- **POST** `/api/v1/notifications/bulk` - Create multiple notifications
- **POST** `/api/v1/notifications/test` - Send test notification

### ✅ **Settings Management**
- **GET** `/api/v1/notifications/settings` - Get user notification preferences
- **PUT** `/api/v1/notifications/settings` - Update notification settings

### ✅ **Device Management**
- **POST** `/api/v1/notifications/device-token` - Register FCM device token

### ✅ **Advanced Filtering**
- Filter by notification type (system, policy, payment, claim, renewal, marketing)
- Filter by priority level (low, medium, high, critical)
- Filter by read status (read/unread)
- Date range filtering

### ✅ **Error Handling & Edge Cases**
- 401 Unauthorized access tests
- 404 Not Found scenarios
- Invalid request validation
- Malformed data handling

## 📁 File Structure

```
api-testing/postman/
├── agent-mitra-notifications-collection.json    # Main Postman collection
├── agent-mitra-local.postman_environment.json   # Environment variables
├── test-notifications-newman.sh                # Newman test automation script
├── NOTIFICATIONS_API_TESTING_README.md         # This documentation
└── reports/                                     # Generated test reports
    ├── notification-api-test-report.html       # Beautiful HTML report
    ├── notification-api-test-results.json      # Detailed JSON results
    └── notification-api-test-results.xml       # JUnit XML for CI/CD
```

## 🚀 Quick Start

### Prerequisites

1. **Backend Server**: Ensure Agent Mitra backend is running on `localhost:8015`
2. **Database**: Notification tables must be properly migrated
3. **Node.js & Newman**: Install Newman CLI globally
   ```bash
   npm install -g newman newman-reporter-html
   ```

### Run Tests

#### Option 1: Automated Newman Script (Recommended)
```bash
# Run against local environment (default)
./test-notifications-newman.sh

# Run against staging
./test-notifications-newman.sh staging

# Run against production
./test-notifications-newman.sh production
```

#### Option 2: Manual Postman Testing
1. Open Postman application
2. Import collection: `agent-mitra-notifications-collection.json`
3. Import environment: `agent-mitra-local.postman_environment.json`
4. Run collection manually or via Postman's Runner

## 📊 Test Results & Reporting

### Automated Reports Generated

After running tests, you'll get:

1. **📄 HTML Report** (`notification-api-test-report.html`)
   - Beautiful, interactive dashboard
   - Detailed request/response logs
   - Test execution timeline
   - Assertion results with screenshots

2. **📋 JSON Results** (`notification-api-test-results.json`)
   - Complete test execution data
   - Response times and metadata
   - Environment variables used

3. **📊 JUnit XML** (`notification-api-test-results.xml`)
   - CI/CD integration ready
   - Test framework compatibility

### Sample Report Features

- ✅ **Pass/Fail Indicators**: Visual status for each test
- 📈 **Performance Metrics**: Response times and throughput
- 🔍 **Request Details**: Full request/response inspection
- 🐛 **Failure Analysis**: Detailed error messages
- 📊 **Statistics Dashboard**: Success rates and trends

## 🔧 Environment Variables

The test suite uses these environment variables (defined in `agent-mitra-local.postman_environment.json`):

### 🔐 **Authentication Tokens**
- `super_admin_token` - JWT for Super Admin
- `senior_agent_token` - JWT for Senior Agent
- `policyholder_token` - JWT for Policyholder

### 🏠 **API Configuration**
- `base_url` - Full API endpoint URL
- `api_host` - Base host URL
- `api_version` - API version path

### 👤 **User Credentials**
- `super_admin_phone` - Super Admin phone number
- `senior_agent_phone` - Senior Agent phone number
- `policyholder_phone` - Policyholder phone number

### 🔔 **Test Data**
- `notification_id` - ID of created test notification
- `device_token` - Test FCM device token

## 🧪 Test Scenarios

### Authentication Flow
```
1. Login as Super Admin → Get JWT token
2. Login as Senior Agent → Get JWT token
3. Login as Policyholder → Get JWT token
```

### CRUD Operations
```
1. Create Notification → Store ID
2. Get Single Notification → Verify data
3. Mark as Read → Verify status change
4. Mark Multiple as Read → Bulk operation
5. Delete Notification → Verify removal
```

### Bulk Operations
```
1. Create Multiple Notifications → Bulk creation
2. Send Test Notification → Immediate delivery
3. Verify Statistics → Check counts and types
```

### Settings Management
```
1. Get Current Settings → Verify defaults
2. Update Settings → Modify preferences
3. Verify Settings Updated → Confirm changes
```

### Device Token Management
```
1. Register Device Token → FCM integration
2. Verify Token Stored → Backend validation
```

## 🎯 Assertions & Validations

Each test includes comprehensive assertions:

### ✅ **HTTP Status Codes**
- 200 OK for successful operations
- 201 Created for resource creation
- 401 Unauthorized for auth failures
- 404 Not Found for missing resources

### ✅ **Response Structure**
- Valid JSON response format
- Required fields presence
- Data type validation
- Array/object structure checks

### ✅ **Business Logic**
- Notification read/unread status
- Statistics calculation accuracy
- Filtering functionality
- Bulk operation success

### ✅ **Data Integrity**
- UUID format validation
- Timestamp presence
- Foreign key relationships
- Enum value constraints

## 🔍 Troubleshooting

### Common Issues

#### ❌ **Server Not Responding**
```bash
# Check if backend is running
ps aux | grep uvicorn

# Start backend server
cd backend && PYTHONPATH=backend ./venv/bin/python -m uvicorn main:app --host 127.0.0.1 --port 8015 --reload
```

#### ❌ **Authentication Failures**
- Verify test user credentials in environment file
- Check database has seeded users
- Ensure RBAC permissions are configured

#### ❌ **Database Errors**
- Run database migrations
- Check tenant_id constraints
- Verify notification tables exist

#### ❌ **Newman Not Found**
```bash
# Install Newman globally
npm install -g newman newman-reporter-html

# Verify installation
newman --version
```

### Debug Mode

Run tests with verbose output:
```bash
./test-notifications-newman.sh local --verbose
```

Check individual request failures in the HTML report.

## 📈 Performance Benchmarks

Expected performance metrics:

- **Response Time**: < 500ms for simple requests
- **Bulk Operations**: < 2s for 10 notifications
- **Statistics Queries**: < 1s for large datasets
- **Concurrent Users**: Supports multiple test sessions

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run Notification API Tests
  run: |
    cd api-testing/postman
    ./test-notifications-newman.sh local

- name: Upload Test Reports
  uses: actions/upload-artifact@v3
  with:
    name: notification-api-test-reports
    path: api-testing/postman/reports/
```

### Jenkins Pipeline Example
```groovy
stage('Notification API Tests') {
    steps {
        sh '''
            cd api-testing/postman
            ./test-notifications-newman.sh local
        '''
    }
    post {
        always {
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'api-testing/postman/reports',
                reportFiles: 'notification-api-test-report.html',
                reportName: 'Notification API Test Report'
            ])
        }
    }
}
```

## 🤝 Contributing

### Adding New Tests

1. **Open Postman**: Import the collection
2. **Add Request**: Create new request in appropriate folder
3. **Add Tests**: Include comprehensive test assertions
4. **Update Collection**: Export and commit changes
5. **Update README**: Document new test scenarios

### Test Naming Convention

```
[HTTP_METHOD] [Endpoint] - [Purpose]
Example: GET Single Notification - Verify data integrity
```

### Assertion Best Practices

```javascript
// Status code checks
pm.test("Status code is 200", function () {
    pm.response.to.have.status(200);
});

// Response structure validation
pm.test("Response has required fields", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData).to.have.property('id');
    pm.expect(jsonData).to.have.property('title');
});

// Business logic validation
pm.test("Notification is unread initially", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.is_read).to.be.false;
});
```

## 📞 Support

For issues or questions:

1. **Check Logs**: Review Newman output and HTML reports
2. **Database Issues**: Verify migrations and data seeding
3. **API Changes**: Update collection if endpoints change
4. **Environment Issues**: Check environment variable configuration

## 🎉 Success Criteria

**✅ 100% Test Pass Rate Required**

- All HTTP requests return expected status codes
- All response assertions pass
- No authentication failures
- No database constraint violations
- All business logic validations succeed

---

**🎯 Ready to test? Run `./test-notifications-newman.sh` and achieve 100% success!**
