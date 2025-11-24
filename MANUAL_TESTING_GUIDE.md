# Manual Testing Guide

## Quick Start

### 1. Start React Portal
```bash
cd config-portal
npm install  # if not already done
npm start
```
Portal will be available at: `http://localhost:3013`

### 2. Flutter App
The Flutter app should already be running. If not:
```bash
flutter run -d chrome
```

## Testing Checklist

### Flutter App - Campaign Builder

1. **Navigate to Campaign Builder**
   - Route: `/campaign-builder`
   - Or use the demo menu to navigate

2. **Create a Campaign**
   - Fill in campaign details
   - Select campaign type (acquisition, retention, upselling, behavioral)
   - Choose channels (WhatsApp, SMS, Email)
   - Set target audience
   - Save campaign

3. **View Campaign Performance**
   - Navigate to `/campaign-performance`
   - Check analytics dashboard
   - View metrics: sent, delivered, opened, clicked, converted

4. **Manage Callback Requests**
   - View callback requests list
   - Filter by status (pending, assigned, completed)
   - Filter by priority (high, medium, low)
   - Assign callbacks to agents
   - Mark callbacks as completed

### React Portal - Campaigns Page

1. **Access Campaigns Page**
   - URL: `http://localhost:3013/campaigns`
   - Should show list of campaigns

2. **Test Filtering**
   - Filter by status (active, draft, completed)
   - Filter by campaign type
   - Search by campaign name

3. **Test Actions**
   - Create new campaign
   - Edit existing campaign
   - Launch campaign
   - View campaign analytics
   - Delete campaign (if allowed)

### React Portal - Callbacks Page

1. **Access Callbacks Page**
   - URL: `http://localhost:3013/callbacks`
   - Should show list of callback requests

2. **Test Filtering**
   - Filter by status (pending, assigned, completed)
   - Filter by priority (high, medium, low)
   - Filter by request type
   - Search by customer name

3. **Test Actions**
   - Assign callback to agent
   - Mark callback as completed
   - Add notes/activities
   - View callback details
   - Update callback status

## API Testing (After FeatureHub Fix)

### Option 1: Configure FeatureHub
```bash
# Start FeatureHub
docker run -d -p 8080:8080 featurehub/edge:latest

# Add to backend/.env:
FEATUREHUB_URL=http://localhost:8080
FEATUREHUB_API_KEY=your-api-key
FEATUREHUB_SDK_KEY=your-sdk-key
FEATUREHUB_ENVIRONMENT=development
```

### Option 2: Test with OTP Authentication
```bash
# Send OTP
curl -X POST http://localhost:8012/api/v1/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+919876543220"}'

# Verify OTP (use OTP from SMS/logs)
curl -X POST http://localhost:8012/api/v1/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+919876543220", "otp": "123456"}'

# Use access_token from response for API calls
```

### Option 3: Run Test Script
```bash
./scripts/test-with-auth.sh
```

## Expected Test Data

After migration V24, you should have:

- **5 Campaign Templates**:
  - Welcome New Customer
  - Policy Renewal Reminder
  - Upsell Premium Plan
  - Payment Reminder
  - Claim Status Update

- **2 Campaigns**:
  - Q1 2024 Renewal Drive (active)
  - New Customer Onboarding (draft)

- **4 Callback Requests**:
  - High priority: Policy issue (pending)
  - Medium priority: Payment problem (pending)
  - Low priority: General inquiry (assigned)
  - High priority: Claim assistance (completed)

## Troubleshooting

### Backend Not Starting
- Check if port 8012 is available
- Check database connection in `flyway.conf`
- Verify `.env` file exists in `backend/` directory

### Authentication Failing
- Check FeatureHub configuration
- Check backend logs: `tail -f logs/app.log`
- Try OTP authentication instead

### React Portal Not Loading
- Check if backend is running
- Verify API proxy in `package.json` points to correct backend URL
- Check browser console for errors

### Flutter App Issues
- Check if backend is accessible from Flutter app
- Verify API base URL in Flutter configuration
- Check Flutter console for errors

## Next Steps After Testing

1. Fix FeatureHub integration for authentication
2. Test end-to-end campaign creation flow
3. Test callback assignment and completion workflow
4. Verify analytics and reporting features
5. Test with real data (if available)

