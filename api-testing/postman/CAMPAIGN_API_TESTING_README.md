# 🎯 Agent Mitra Campaign API Testing Suite

Comprehensive API testing suite for the Agent Mitra Campaign Management system using Postman and Newman.

## 📋 Overview

This testing suite covers all campaign-related API endpoints with real database integration, ensuring:

- ✅ **Real Database Queries** - No mocks, all data comes from actual PostgreSQL database
- ✅ **JWT Authentication** - Role-based access control with senior/junior agent testing
- ✅ **Comprehensive Coverage** - All CRUD operations, analytics, and recommendations
- ✅ **Automated Reporting** - HTML reports with detailed test results and metrics

## 🔗 API Endpoints Tested

### 🎯 Authentication
- `POST /auth/login` - JWT token generation for campaign testing

### 📋 Campaign Templates
- `GET /campaigns/templates` - List all templates
- `GET /campaigns/templates?category=acquisition` - Filter templates by category

### 📝 Campaign Management
- `GET /campaigns` - List campaigns (with filters)
- `POST /campaigns` - Create new campaign
- `GET /campaigns/{id}` - Get campaign details
- `PUT /campaigns/{id}` - Update campaign
- `POST /campaigns/{id}/launch` - Launch campaign

### 📊 Campaign Analytics
- `GET /campaigns/{id}/analytics` - Real-time analytics with database metrics
  - Total sent, delivered, opened, clicked, converted
  - ROI calculations based on actual budget/investment
  - Delivery rates and engagement metrics

### 💡 Campaign Recommendations
- `GET /campaigns/recommendations` - Personalized recommendations
  - Based on agent's real campaign history
  - Uses actual policies sold and performance data

### 📋 Template-based Creation
- `POST /campaigns/templates/{id}/create` - Create campaign from template

## 🛠️ Setup & Prerequisites

### System Requirements
```bash
# Node.js and npm
node --version  # v16+
npm --version   # v7+

# Newman CLI
npm install -g newman newman-reporter-html

# Optional: jq for enhanced reporting
brew install jq  # macOS
```

### Backend Server
Ensure the backend is running on the target environment:

```bash
# Local development
cd backend && python -m uvicorn main:app --host 127.0.0.1 --port 8015 --reload

# Check health
curl http://localhost:8015/health
```

## 🚀 Running Tests

### Quick Start
```bash
# Run all campaign tests against local environment
cd api-testing/api-testing/postman
./test-campaigns-newman.sh local

# Or specify environment explicitly
./test-campaigns-newman.sh local
./test-campaigns-newman.sh staging
./test-campaigns-newman.sh production
```

### Manual Newman Execution
```bash
# Run with Newman directly
newman run agent-mitra-campaigns-collection.json \
  --environment agent-mitra-local.postman_environment.json \
  --reporters cli,html,json \
  --reporter-html-export reports/campaign-test-report.html \
  --reporter-json-export reports/campaign-test-results.json
```

### Test Results
```
🎯 Agent Mitra Campaign API Newman Testing Suite
================================================
Environment: local
Timestamp: 2025-12-02 07:15:00

[INFO] Checking prerequisites...
[SUCCESS] Prerequisites check passed
[INFO] Checking backend connectivity...
[SUCCESS] Backend is accessible
[INFO] Setting up reports directory...
[SUCCESS] Reports directory ready
[INFO] Starting Newman tests...

📊 TEST RESULTS SUMMARY
========================
Total Requests: 12
Passed: 12
Failed: 0
Success Rate: 100%
```

## 📊 Test Reports

### Generated Files
```
reports/
├── campaign-api-test-report.html      # 📊 Detailed HTML report
├── campaign-api-test-results.json     # 📋 Raw test data
├── campaign-api-test-results.xml      # 🧪 JUnit XML for CI/CD
└── campaign-api-test-[env]-[timestamp]-*  # Timestamped archives
```

### HTML Report Features
- ✅ **Visual Test Results** - Pass/fail status with color coding
- ✅ **Response Times** - Performance metrics for each request
- ✅ **Request/Response Details** - Full API call inspection
- ✅ **Error Analysis** - Detailed failure reasons
- ✅ **Environment Info** - Test environment and configuration

## 🔐 Test Users & Roles

| User | Phone | Role | Campaign Access |
|------|-------|------|-----------------|
| Senior Agent | +919876543203 | Agent | ✅ Full CRUD + Analytics |
| Junior Agent | +919876543204 | Agent | ❌ Limited (inactive) |
| Super Admin | +919876543200 | Admin | ❌ No agent association |
| Provider Admin | +919876543201 | Admin | ❌ No agent association |

## 🎯 Real Database Integration

### Analytics Data Source
```sql
-- Real campaign metrics
SELECT campaign_id, budget, estimated_cost, total_sent,
       total_delivered, total_opened, total_clicked, total_converted
FROM lic_schema.campaigns
WHERE campaign_id = ? AND agent_id = ?

-- ROI calculation
ROI = ((total_revenue - budget) / budget) * 100
```

### Recommendations Data Source
```sql
-- Agent performance data
SELECT agent_id, total_policies_sold
FROM lic_schema.agents
WHERE agent_id = ?

-- Campaign history analysis
SELECT campaign_id, status, roi_percentage
FROM lic_schema.campaigns
WHERE agent_id = ? AND status IN ('active', 'completed')
ORDER BY created_at DESC
```

## 📈 Test Scenarios

### ✅ Success Scenarios
- **Campaign Creation**: Senior agent creates campaign with valid data
- **Analytics Access**: Real metrics returned for launched campaigns
- **Recommendations**: Personalized suggestions based on agent history
- **Template Usage**: Campaign creation from existing templates

### ❌ Failure Scenarios
- **Unauthorized Access**: Junior agent (inactive) cannot create campaigns
- **Invalid Data**: Missing required fields or invalid UUIDs
- **Non-existent Resources**: Accessing campaigns that don't exist
- **Authentication Failure**: Invalid or expired JWT tokens

## 🔧 Configuration

### Environment Variables
```json
{
  "senior_agent_token": "JWT_TOKEN_HERE",
  "junior_agent_token": "JWT_TOKEN_HERE",
  "senior_agent_user_id": "df23ccb2-5fe1-47ed-95de-e00bd0aefaa1",
  "junior_agent_user_id": "a473bf8a-32ce-41b9-8419-3400f1a1165b",
  "campaign_id": "AUTO_GENERATED",
  "template_id": "AUTO_DETECTED"
}
```

### Test Data
- **Campaigns**: Created during testing with unique timestamps
- **Templates**: Uses existing templates from database
- **Analytics**: Based on real campaign execution data
- **Recommendations**: Generated from agent performance metrics

## 🚨 Troubleshooting

### Common Issues

**Newman not found:**
```bash
npm install -g newman newman-reporter-html
```

**Backend not accessible:**
```bash
# Check if backend is running
curl http://localhost:8015/health

# Start backend
cd backend && python -m uvicorn main:app --host 127.0.0.1 --port 8015 --reload
```

**Database connection issues:**
- Ensure PostgreSQL is running
- Check database migrations are applied
- Verify campaign seed data exists

**Authentication failures:**
- Ensure test users exist in database
- Check JWT token expiration
- Verify user roles and permissions

### Debug Mode
```bash
# Run with verbose output
./test-campaigns-newman.sh local --verbose

# Run single request
newman run agent-mitra-campaigns-collection.json \
  --environment agent-mitra-local.postman_environment.json \
  --folder "📝 CAMPAIGN MANAGEMENT" \
  --verbose
```

## 📊 CI/CD Integration

### GitHub Actions Example
```yaml
- name: Run Campaign API Tests
  run: |
    cd api-testing/api-testing/postman
    ./test-campaigns-newman.sh staging

- name: Upload Test Reports
  uses: actions/upload-artifact@v2
  with:
    name: campaign-api-test-reports
    path: api-testing/api-testing/postman/reports/
```

### Jenkins Pipeline
```groovy
stage('Campaign API Tests') {
    steps {
        sh '''
            cd api-testing/api-testing/postman
            ./test-campaigns-newman.sh staging
        '''
    }
    post {
        always {
            publishHTML([
                allowMissing: false,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'api-testing/api-testing/postman/reports',
                reportFiles: 'campaign-api-test-report.html',
                reportName: 'Campaign API Test Report'
            ])
        }
    }
}
```

## 🎯 Key Features Tested

- ✅ **Real Database Queries** - All endpoints use actual database data
- ✅ **JWT Authentication** - Proper token-based authentication
- ✅ **Role-Based Access** - Senior/Junior agent permissions
- ✅ **Data Validation** - Comprehensive input validation
- ✅ **Error Handling** - Proper error responses and status codes
- ✅ **Performance** - Response time validation
- ✅ **Analytics Accuracy** - Real ROI and engagement calculations
- ✅ **Personalization** - Agent-specific recommendations

## 📞 Support

For issues or questions:
1. Check the HTML test reports for detailed error information
2. Review the JSON results for API response analysis
3. Ensure backend and database are properly configured
4. Verify test user accounts exist in the target environment

---

**Generated Reports Location**: `api-testing/api-testing/postman/reports/`
**Collection File**: `agent-mitra-campaigns-collection.json`
**Test Script**: `test-campaigns-newman.sh`
