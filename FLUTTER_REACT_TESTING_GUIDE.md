# Flutter & React Portal Testing Guide

## Prerequisites ✅

- ✅ Backend API running on http://localhost:8012
- ✅ Database migrated with seed data
- ✅ Authentication fixed and working
- ✅ Flutter installed (3.13.1)
- ✅ React Portal dependencies installed

## Testing Flutter App - Campaign Builder

### 1. Start Flutter App

```bash
cd /Users/manish/Documents/GitHub/zero/agentmitra

# Option 1: Run on Chrome (Web)
flutter run -d chrome

# Option 2: Run on iOS Simulator (if available)
flutter run -d ios

# Option 3: Run on Android Emulator (if available)
flutter run -d android
```

### 2. Navigate to Campaign Builder

**Route:** `/campaign-builder`

**Ways to access:**
1. Use the demo menu/welcome screen
2. Navigate directly via route: `/campaign-builder`
3. From agent dashboard → Campaign Builder option

### 3. Test Campaign Creation

**Steps:**
1. ✅ Fill in campaign name (e.g., "Q4 2024 Retention Drive")
2. ✅ Select campaign type:
   - Acquisition
   - Retention
   - Upselling
   - Behavioral
3. ✅ Choose primary channel (WhatsApp, SMS, Email)
4. ✅ Add multiple channels if needed
5. ✅ Write campaign message with personalization tags
6. ✅ Set target audience (All, Segments, Custom)
7. ✅ Set schedule (Immediate, Scheduled, Recurring)
8. ✅ Set budget and estimated cost
9. ✅ Save campaign

**Expected Result:**
- Campaign saved successfully
- Appears in campaign list
- Can view/edit campaign details

### 4. Test Campaign Performance Analytics

**Route:** `/campaign-performance`

**Features to test:**
- View campaign metrics:
  - Total sent
  - Delivered
  - Opened
  - Clicked
  - Converted
  - ROI percentage
- Filter by date range
- Compare campaigns
- View detailed analytics

### 5. Test Callback Request Management

**Features to test:**
- View callback requests list
- Filter by status (pending, assigned, completed)
- Filter by priority (high, medium, low)
- Assign callback to agent
- Mark callback as completed
- View callback details and activities

## Testing React Portal - Campaigns & Callbacks

### 1. Start React Portal

```bash
cd /Users/manish/Documents/GitHub/zero/agentmitra/config-portal
npm start
```

**Portal URL:** http://localhost:3013

### 2. Login to Portal

**Note:** Portal requires authentication. You may need to:
- Login with agent credentials
- Or configure authentication bypass for testing

### 3. Test Campaigns Page

**Route:** `/campaigns`

**Features to test:**

#### Campaign List
- ✅ View all campaigns
- ✅ Filter by status (active, draft, completed, paused)
- ✅ Filter by campaign type
- ✅ Search by campaign name
- ✅ Sort by various columns

#### Campaign Actions
- ✅ Create new campaign
- ✅ Edit existing campaign
- ✅ Launch campaign
- ✅ Pause campaign
- ✅ View campaign analytics
- ✅ Delete campaign (if allowed)

#### Campaign Creation Form
- Fill all required fields
- Select campaign type and channels
- Set targeting rules
- Configure schedule
- Set budget
- Save campaign

### 4. Test Callbacks Page

**Route:** `/callbacks`

**Features to test:**

#### Callback List
- ✅ View all callback requests
- ✅ Filter by status (pending, assigned, completed)
- ✅ Filter by priority (high, medium, low)
- ✅ Filter by request type
- ✅ Search by customer name
- ✅ Sort by priority score, due date, etc.

#### Callback Actions
- ✅ Assign callback to agent
- ✅ Update callback status
- ✅ Mark callback as completed
- ✅ Add notes/activities
- ✅ View callback details
- ✅ View callback history/activities

#### Callback Details
- View customer information
- View request description
- View priority score and SLA
- View assigned agent
- View resolution details
- View satisfaction rating

## API Endpoints Being Used

### Campaigns API
- `GET /api/v1/campaigns` - List campaigns
- `GET /api/v1/campaigns/{id}` - Get campaign details
- `POST /api/v1/campaigns` - Create campaign
- `PUT /api/v1/campaigns/{id}` - Update campaign
- `POST /api/v1/campaigns/{id}/launch` - Launch campaign
- `GET /api/v1/campaigns/{id}/analytics` - Get analytics
- `GET /api/v1/campaigns/templates` - Get templates
- `GET /api/v1/campaigns/recommendations` - Get recommendations

### Callbacks API
- `GET /api/v1/callbacks` - List callbacks
- `GET /api/v1/callbacks/{id}` - Get callback details
- `POST /api/v1/callbacks` - Create callback
- `PUT /api/v1/callbacks/{id}/status` - Update status
- `POST /api/v1/callbacks/{id}/assign` - Assign callback
- `POST /api/v1/callbacks/{id}/complete` - Complete callback

## Expected Test Data

After migration V24, you should see:

### Campaigns (2)
1. **Q1 2024 Renewal Drive**
   - Type: Retention
   - Status: Active
   - Channels: WhatsApp, SMS
   - Metrics: 485 sent, 462 delivered, 342 opened, 98 clicked, 23 converted

2. **New Customer Onboarding**
   - Type: Acquisition
   - Status: Draft
   - Channels: WhatsApp, Email

### Callback Requests (4)
1. **High Priority - Policy Issue** (Pending)
   - Customer: Rajesh Kumar
   - Priority Score: 90.5
   - SLA: 2 hours

2. **Medium Priority - Payment Problem** (Pending)
   - Customer: Priya Sharma
   - Priority Score: 87.0
   - SLA: 8 hours

3. **Low Priority - General Inquiry** (Assigned)
   - Customer: Amit Singh
   - Priority Score: 66.0
   - SLA: 24 hours

4. **High Priority - Claim Assistance** (Completed)
   - Customer: Sneha Patel
   - Priority Score: 85.0
   - Satisfaction: 5/5

## Troubleshooting

### Flutter App Issues

**App won't start:**
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

**API connection errors:**
- Check backend is running: `curl http://localhost:8012/health`
- Verify API base URL in Flutter config
- Check CORS settings in backend

**Authentication errors:**
- Verify token is stored correctly
- Check token expiration
- Re-authenticate if needed

### React Portal Issues

**Portal won't start:**
```bash
cd config-portal
rm -rf node_modules package-lock.json
npm install
npm start
```

**API connection errors:**
- Check `REACT_APP_API_URL` in `.env` file
- Verify backend is running
- Check browser console for CORS errors

**Authentication errors:**
- Check localStorage for `access_token`
- Verify login endpoint works
- Check token format and expiration

## Success Criteria

### Flutter App ✅
- [ ] Campaign Builder screen loads
- [ ] Can create new campaign
- [ ] Campaign appears in list
- [ ] Can view campaign performance
- [ ] Can manage callback requests
- [ ] Filters work correctly
- [ ] Data syncs with backend

### React Portal ✅
- [ ] Campaigns page loads
- [ ] Can view campaign list
- [ ] Can create/edit campaigns
- [ ] Can launch campaigns
- [ ] Callbacks page loads
- [ ] Can filter callbacks
- [ ] Can assign/complete callbacks
- [ ] Data syncs with backend

## Next Steps After Testing

1. Document any bugs found
2. Test edge cases (empty lists, errors, etc.)
3. Test with different user roles
4. Performance testing with large datasets
5. Test offline functionality (if applicable)

