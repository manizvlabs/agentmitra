# Agent Mitra - Complete App Restructuring & Conformance Plan
**Date:** December 1, 2024  
**Branch:** feature/v3  
**Objective:** Achieve 100% conformance with discovery documents through systematic restructuring

---

## Executive Summary

This plan provides step-by-step instructions for restructuring the Agent Mitra Flutter mobile app and React config portal to achieve **100% conformance** with the following discovery documents:

- `discovery/content/content-structure.md` - Content organization and hierarchy
- `discovery/content/information-architecture.md` - Information architecture and user types
- `discovery/content/navigation-hierarchy.md` - Navigation patterns and user flows
- `discovery/content/user-journey.md` - Complete user journey flows
- `discovery/content/wireframes.md` - UI/UX wireframes and design specifications

### Key Principles
1. **No Mock Data** - All screens must integrate with real backend APIs
2. **Real Database Queries** - Use existing backend services and repositories
3. **Flyway Migrations Only** - All database changes via existing migration files
4. **100% Conformance** - Every screen must match discovery document specifications
5. **Role-Based Navigation** - Implement proper navigation hierarchy per user type

---

## Current State Analysis

### Flutter App Issues Identified

#### 1. Navigation Architecture Problems
- **Current:** 51+ individual screens with flat routing
- **Issue:** No hierarchical navigation structure
- **Required:** Role-based bottom tab navigation (4-5 tabs) + drawer/hamburger menus

#### 2. Screen Duplication
- **Current:** Multiple dashboards (`SuperAdminDashboard`, `ProviderAdminDashboard`, `RegionalManagerDashboard`, `SeniorAgentDashboard`)
- **Issue:** Duplicate functionality, inconsistent UX
- **Required:** Single unified dashboard per user type with role-based content filtering

#### 3. Missing Navigation Patterns
- **Current:** Flat route structure, no tab containers
- **Issue:** Doesn't match IA navigation hierarchy
- **Required:** Bottom tabs + drawer menus as per navigation-hierarchy.md

#### 4. Mock Data Usage
- **Current:** Some screens use placeholder/mock data
- **Issue:** Not integrated with real backend
- **Required:** All screens must call real API endpoints

#### 5. Content Structure Mismatch
- **Current:** Content organization doesn't match content-structure.md
- **Issue:** Missing content hierarchy, wrong information architecture
- **Required:** Exact content structure per discovery documents

### React Config Portal Issues

#### 1. Missing Data Import Flow
- **Current:** Basic import screens exist
- **Issue:** Doesn't match complete user journey from user-journey.md
- **Required:** Full Excel import workflow with validation, progress tracking, error handling

#### 2. Incomplete Integration
- **Current:** Some screens may use mock data
- **Issue:** Not fully integrated with backend APIs
- **Required:** Real API integration for all operations

---

## Target State Definition

### Flutter App Target Structure

#### Customer Portal (Policyholder)
```
📱 Customer Portal Navigation
├── 🏠 Home Tab (Dashboard)
│   ├── Quick Actions (Pay Premium, Contact Agent, Get Quote)
│   ├── Policy Overview (Active policies, next payment, coverage)
│   ├── Critical Notifications (Priority-based alerts)
│   └── Quick Insights (Visual cards)
├── 📄 Policies Tab
│   ├── All Policies (Searchable, filterable list)
│   ├── Policy Details (Comprehensive view)
│   ├── Premium Payments (Payment history, upcoming)
│   └── Policy Documents (Download center)
├── 💬 Chat Tab
│   ├── Messages (Agent communication)
│   ├── Smart Assistant (AI chatbot)
│   └── Quick Contact (WhatsApp, Call, Email)
├── 📚 Learning Tab
│   ├── Featured Content (Popular videos)
│   ├── Categories (Organized learning)
│   └── Recent Additions (New content)
└── 👤 Profile Tab
    ├── Personal Information
    ├── App Settings
    ├── Security & Privacy
    └── Help & Support
```

#### Agent Portal (Junior/Senior Agents)
```
📱 Agent Portal Navigation
├── 📊 Dashboard Tab
│   ├── Key Metrics (Revenue, Customers, Renewal Rate)
│   ├── Trend Charts (6-month overview)
│   ├── Action Items (Priority queue)
│   └── Alerts & Notifications
├── 👥 Customers Tab
│   ├── Customer Overview (Summary cards)
│   ├── Customer List (Advanced CRM)
│   ├── Communication Tools (Bulk actions)
│   └── Customer Segmentation
├── 📈 Analytics Tab
│   ├── Revenue Analytics
│   ├── Performance Metrics
│   ├── ROI Calculations
│   └── Predictive Analytics
├── 📢 Campaigns Tab
│   ├── Campaign Overview
│   ├── Campaign Builder
│   ├── Campaign Performance
│   └── Template Library
└── 👤 Profile Tab
    ├── Agent Information
    ├── Business Settings
    ├── Content Management
    └── System Administration
```

#### Admin Portal (Super Admin, Provider Admin, Regional Manager)
```
📱 Admin Portal Navigation
├── 📊 Overview Tab
│   ├── Platform Metrics
│   ├── User Statistics
│   ├── System Health
│   └── Recent Activity
├── 👥 Management Tab
│   ├── User Management (RBAC)
│   ├── Agent Management
│   ├── Customer Management
│   └── Role Assignment
├── ⚙️ Configuration Tab
│   ├── Feature Flags
│   ├── System Settings
│   ├── Localization
│   └── Security Settings
└── 📊 Analytics Tab
    ├── Platform Analytics
    ├── Usage Metrics
    ├── Performance Monitoring
    └── Audit Logs
```

### React Config Portal Target Structure

```
🏗️ Agent Configuration Portal
├── 📊 Import Dashboard
│   ├── Import Statistics
│   ├── Recent Activity
│   └── Quick Actions
├── 📤 Data Upload
│   ├── File Selection (Drag & Drop)
│   ├── File Validation
│   └── Column Mapping
├── 🔄 Import Processing
│   ├── Real-time Progress
│   ├── Live Statistics
│   └── Error Handling
├── ✅ Import Results
│   ├── Success Summary
│   ├── Data Quality Metrics
│   └── Mobile Sync Status
└── 📋 Template Management
    ├── Download Templates
    ├── Import Guidelines
    └── FAQ & Troubleshooting
```

---

## Phase-by-Phase Implementation Plan

### Phase 1: Navigation Architecture Foundation (Week 1, Days 1-2)

#### Step 1.1: Create Navigation Container Components

**Location:** `lib/navigation/`

**Tasks:**
1. Create `lib/navigation/customer_navigation.dart`
   - Bottom tab bar with 5 tabs (Home, Policies, Chat, Learning, Profile)
   - Drawer menu for secondary navigation
   - Tab state management
   - Navigation between tabs

2. Create `lib/navigation/agent_navigation.dart`
   - Bottom tab bar with 5 tabs (Dashboard, Customers, Analytics, Campaigns, Profile)
   - Hamburger menu for advanced tools
   - Tab state management

3. Create `lib/navigation/admin_navigation.dart`
   - Contextual navigation based on admin role
   - Tab-based or drawer-based navigation
   - Role-based content filtering

4. Create `lib/navigation/navigation_router.dart`
   - Role-based route generation
   - Protected route wrapper
   - Deep linking support

**Reference:** `discovery/content/navigation-hierarchy.md` sections 2.1, 2.2, 3.1, 3.2

**Acceptance Criteria:**
- [ ] Customer navigation has 5 bottom tabs as specified
- [ ] Agent navigation has 5 bottom tabs as specified
- [ ] Admin navigation adapts to role
- [ ] Navigation containers handle tab switching correctly
- [ ] Drawer/hamburger menus work properly

---

#### Step 1.2: Update Main App Routing

**Location:** `lib/main.dart`

**Tasks:**
1. Replace flat routing with navigation container routing
2. Implement role-based initial route selection
3. Update `_getInitialRoute()` to use navigation containers
4. Remove individual screen routes, replace with tab-based navigation

**Code Pattern:**
```dart
// Instead of:
'/customer-dashboard': (context) => CustomerDashboard(),

// Use:
'/customer-portal': (context) => CustomerNavigationContainer(),
```

**Reference:** `discovery/content/navigation-hierarchy.md` section 4

**Acceptance Criteria:**
- [ ] Main routing uses navigation containers
- [ ] Role-based routing works correctly
- [ ] Deep links navigate to correct tab
- [ ] Back navigation works properly

---

### Phase 2: Customer Portal Restructuring (Week 1, Days 3-5)

#### Step 2.1: Create Unified Customer Dashboard

**Location:** `lib/features/customer_dashboard/presentation/pages/customer_dashboard_page.dart`

**Tasks:**
1. Restructure `customer_dashboard.dart` to match wireframes exactly
2. Implement content structure from `content-structure.md` section 2.1
3. Integrate with real API: `GET /api/v1/dashboard/analytics`
4. Remove all mock data, use `CustomerDashboardViewModel` with real API calls
5. Implement Quick Actions section (Pay Premium, Contact Agent, Get Quote)
6. Implement Policy Overview section (Active policies, next payment, coverage)
7. Implement Critical Notifications (Priority-based, color-coded)
8. Implement Quick Insights cards

**API Integration:**
- Use `DashboardViewModel` from `lib/features/dashboard/presentation/viewmodels/dashboard_viewmodel.dart`
- Call `GET /api/v1/dashboard/analytics` endpoint
- Use `GET /api/v1/policies` for policy data
- Use `GET /api/v1/notifications` for notifications

**Reference:** 
- `discovery/content/wireframes.md` section 4.1
- `discovery/content/content-structure.md` section 2.1
- `discovery/content/information-architecture.md` section 2.1

**Acceptance Criteria:**
- [ ] Dashboard matches wireframe exactly
- [ ] All data comes from real API endpoints
- [ ] Quick Actions navigate correctly
- [ ] Policy Overview shows real data
- [ ] Notifications are priority-based
- [ ] No mock/placeholder data

---

#### Step 2.2: Create Policies Tab Content

**Location:** `lib/features/policies/presentation/pages/` (create if needed)

**Tasks:**
1. Consolidate `my_policies_screen.dart`, `policy_details_screen.dart`, `premium_calendar_screen.dart` into single Policies tab
2. Implement policy card structure from `content-structure.md` section 2.2
3. Integrate with real APIs:
   - `GET /api/v1/policies` - List all policies
   - `GET /api/v1/policies/{policy_id}` - Policy details
   - `GET /api/v1/policies/{policy_id}/payments` - Payment history
   - `GET /api/v1/policies/{policy_id}/documents` - Policy documents
4. Implement search and filter functionality
5. Implement policy detail page with tabs (Overview, Coverage, Premium, Documents, Claims)
6. Remove mock data, use real API responses

**Reference:**
- `discovery/content/wireframes.md` section 4.2
- `discovery/content/content-structure.md` section 2.2
- `discovery/content/navigation-hierarchy.md` section 2.2

**Acceptance Criteria:**
- [ ] Policies tab shows all policies from API
- [ ] Policy cards match content structure specification
- [ ] Policy details page has all required tabs
- [ ] Search and filter work correctly
- [ ] Payment history shows real data
- [ ] Documents download from real API

---

#### Step 2.3: Create Chat Tab Content

**Location:** `lib/features/chat/presentation/pages/` (consolidate existing)

**Tasks:**
1. Consolidate `whatsapp_integration_screen.dart`, `smart_chatbot_screen.dart`, `agent_chat_screen.dart` into Chat tab
2. Implement message thread design from `content-structure.md` section 2.3
3. Integrate with real APIs:
   - `GET /api/v1/chat/messages` - Get messages
   - `POST /api/v1/chat/messages` - Send message
   - `GET /api/v1/chatbot/query` - Chatbot queries
   - `POST /api/v1/chatbot/query` - Submit chatbot query
4. Implement WhatsApp integration using real WhatsApp Business API
5. Implement Smart Assistant with real chatbot backend
6. Remove mock data

**Reference:**
- `discovery/content/wireframes.md` sections 4.4, 4.5
- `discovery/content/content-structure.md` section 2.3, 2.4
- `discovery/content/user-journey.md` section 2.4

**Acceptance Criteria:**
- [ ] Chat tab shows real messages from API
- [ ] WhatsApp integration works with real API
- [ ] Smart Assistant connects to real chatbot backend
- [ ] Message threads display correctly
- [ ] Quick templates work
- [ ] No mock data

---

#### Step 2.4: Create Learning Tab Content

**Location:** `lib/features/learning/presentation/pages/` (restructure existing)

**Tasks:**
1. Restructure `learning_center_screen.dart` to match wireframes
2. Implement video tutorial structure from `content-structure.md` section 2.5
3. Integrate with real APIs:
   - `GET /api/v1/content/videos` - Get video library
   - `GET /api/v1/content/categories` - Get content categories
   - `GET /api/v1/content/featured` - Get featured content
4. Implement YouTube integration if specified
5. Implement learning analytics (views, watch time, progress)
6. Remove mock data

**Reference:**
- `discovery/content/wireframes.md` section 4.6
- `discovery/content/content-structure.md` section 2.5
- `discovery/content/information-architecture.md` section 2.1

**Acceptance Criteria:**
- [ ] Learning tab shows real videos from API
- [ ] Categories match content structure
- [ ] Featured content displays correctly
- [ ] Video playback works (YouTube or direct)
- [ ] Learning analytics show real data
- [ ] No mock data

---

#### Step 2.5: Create Profile Tab Content

**Location:** `lib/features/profile/presentation/pages/` (create if needed)

**Tasks:**
1. Create comprehensive profile page matching wireframes
2. Implement profile sections:
   - Personal Information (editable)
   - App Settings (Theme, Language, Notifications)
   - Security & Privacy (Password, Biometric, Data Export)
   - Help & Support (FAQ, Contact, User Guide)
3. Integrate with real APIs:
   - `GET /api/v1/users/me` - Get user profile
   - `PUT /api/v1/users/me` - Update profile
   - `POST /api/v1/auth/change-password` - Change password
4. Implement settings persistence
5. Remove mock data

**Reference:**
- `discovery/content/navigation-hierarchy.md` section 2.2 (Tab 5)
- `discovery/content/wireframes.md` (Profile sections)

**Acceptance Criteria:**
- [ ] Profile tab shows real user data
- [ ] All settings save to backend
- [ ] Theme switching works
- [ ] Language switching works
- [ ] Security settings functional
- [ ] No mock data

---

### Phase 3: Agent Portal Restructuring (Week 2, Days 1-4)

#### Step 3.1: Create Unified Agent Dashboard

**Location:** `lib/features/agent_dashboard/presentation/pages/agent_dashboard_page.dart` (create new)

**Tasks:**
1. **Remove duplicate dashboards:**
   - Delete `lib/screens/senior_agent_dashboard.dart`
   - Delete `lib/screens/regional_manager_dashboard.dart`
   - Keep only unified agent dashboard

2. **Create unified dashboard** that adapts to agent role (junior/senior/regional manager)
3. Implement KPIs from `content-structure.md` section 3.1:
   - Monthly Revenue
   - Active Customers
   - Renewal Rate
   - New Policies Sold
   - Customer Satisfaction
4. Integrate with real APIs:
   - `GET /api/v1/analytics/agent/{agent_id}` - Agent analytics
   - `GET /api/v1/dashboard/analytics` - Dashboard KPIs
   - `GET /api/v1/analytics/roi/agent/{agent_id}` - ROI data
5. Implement trend charts (6-month overview)
6. Implement action items (priority queue)
7. Remove all mock data

**Reference:**
- `discovery/content/wireframes.md` section 3.0
- `discovery/content/content-structure.md` section 3.1
- `discovery/content/information-architecture.md` section 3.2

**Acceptance Criteria:**
- [ ] Single unified dashboard for all agent types
- [ ] Role-based content filtering works
- [ ] All KPIs come from real API
- [ ] Trend charts show real data
- [ ] Action items are real and actionable
- [ ] No duplicate dashboards exist
- [ ] No mock data

---

#### Step 3.2: Create Customers Tab Content

**Location:** `lib/features/customers/presentation/pages/customers_tab_page.dart` (restructure existing)

**Tasks:**
1. Restructure `customers_screen.dart` to match wireframes
2. Implement customer profile structure from `content-structure.md` section 3.2
3. Integrate with real APIs:
   - `GET /api/v1/customers` - List customers
   - `GET /api/v1/customers/{customer_id}` - Customer details
   - `GET /api/v1/customers/{customer_id}/analytics` - Customer analytics
   - `GET /api/v1/customers/{customer_id}/communication` - Communication history
4. Implement advanced CRM features:
   - Customer segmentation
   - Bulk messaging
   - Communication tools
   - Customer analytics
5. Remove mock data

**Reference:**
- `discovery/content/wireframes.md` section 5.2
- `discovery/content/content-structure.md` section 3.2
- `discovery/content/information-architecture.md` section 3.2

**Acceptance Criteria:**
- [ ] Customers tab shows real customer data
- [ ] Customer profiles match content structure
- [ ] Segmentation works correctly
- [ ] Bulk messaging functional
- [ ] Analytics show real data
- [ ] No mock data

---

#### Step 3.3: Create Analytics Tab Content

**Location:** `lib/features/analytics/presentation/pages/analytics_tab_page.dart` (restructure existing)

**Tasks:**
1. Consolidate `roi_analytics_dashboard.dart` into Analytics tab
2. Implement ROI dashboard structure from `content-structure.md` section 3.3
3. Integrate with real APIs:
   - `GET /api/v1/analytics/roi/agent/{agent_id}` - ROI analytics
   - `GET /api/v1/analytics/revenue` - Revenue analytics
   - `GET /api/v1/analytics/performance` - Performance metrics
   - `GET /api/v1/analytics/predictive` - Predictive analytics
4. Implement revenue analytics section
5. Implement performance metrics section
6. Implement ROI calculations section
7. Implement predictive analytics section
8. Remove mock data

**Reference:**
- `discovery/content/wireframes.md` section 5.3
- `discovery/content/content-structure.md` section 3.3
- `discovery/content/information-architecture.md` section 3.2

**Acceptance Criteria:**
- [ ] Analytics tab shows real ROI data
- [ ] Revenue analytics functional
- [ ] Performance metrics accurate
- [ ] ROI calculations correct
- [ ] Predictive analytics working
- [ ] No mock data

---

#### Step 3.4: Create Campaigns Tab Content

**Location:** `lib/features/campaigns/presentation/pages/campaigns_tab_page.dart` (restructure existing)

**Tasks:**
1. Consolidate `marketing_campaign_builder.dart`, `campaign_performance_screen.dart` into Campaigns tab
2. Implement campaign builder interface from `content-structure.md` section 3.4
3. Integrate with real APIs:
   - `GET /api/v1/campaigns` - List campaigns
   - `POST /api/v1/campaigns` - Create campaign
   - `GET /api/v1/campaigns/{campaign_id}` - Campaign details
   - `GET /api/v1/campaigns/{campaign_id}/performance` - Campaign performance
   - `POST /api/v1/campaigns/{campaign_id}/launch` - Launch campaign
4. Implement campaign builder with:
   - Campaign setup
   - Message builder
   - Audience segmentation
   - Campaign scheduling
   - Performance tracking
5. Remove mock data

**Reference:**
- `discovery/content/wireframes.md` section 5.4, 5.7
- `discovery/content/content-structure.md` section 3.4
- `discovery/content/user-journey.md` section 2.5

**Acceptance Criteria:**
- [ ] Campaigns tab shows real campaigns
- [ ] Campaign builder functional
- [ ] Audience segmentation works
- [ ] Campaign performance tracking accurate
- [ ] Campaign launch works
- [ ] No mock data

---

#### Step 3.5: Create Agent Profile Tab Content

**Location:** `lib/features/agent/presentation/pages/agent_profile_tab_page.dart` (restructure existing)

**Tasks:**
1. Restructure `agent_profile_page.dart` to match wireframes
2. Implement agent profile structure from `content-structure.md` section 3.5
3. Integrate with real APIs:
   - `GET /api/v1/agents/{agent_id}` - Agent profile
   - `PUT /api/v1/agents/{agent_id}` - Update profile
   - `POST /api/v1/agents/{agent_id}/photo` - Upload photo
   - `GET /api/v1/content/videos` - Video library
   - `POST /api/v1/content/videos` - Upload video
   - `GET /api/v1/chatbot/training` - Chatbot Q&A
   - `POST /api/v1/chatbot/training` - Add Q&A
4. Implement content management:
   - Video library management
   - Document management
   - Content performance analytics
   - Chatbot training interface
5. Remove mock data

**Reference:**
- `discovery/content/wireframes.md` section 3.0.4, 5.5
- `discovery/content/content-structure.md` section 3.5
- `discovery/content/information-architecture.md` section 3.2

**Acceptance Criteria:**
- [ ] Agent profile shows real data
- [ ] Photo upload works
- [ ] Video library functional
- [ ] Content management works
- [ ] Chatbot training interface functional
- [ ] No mock data

---

### Phase 4: Admin Portal Restructuring (Week 2, Days 5-7)

#### Step 4.1: Create Unified Admin Dashboard

**Location:** `lib/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart` (create new)

**Tasks:**
1. **Remove duplicate admin dashboards:**
   - Delete `lib/screens/super_admin_dashboard.dart`
   - Delete `lib/screens/provider_admin_dashboard.dart`
   - Keep only unified admin dashboard

2. **Create unified admin dashboard** that adapts to admin role
3. Implement admin sections based on role:
   - Super Admin: Full system access
   - Provider Admin: Provider management
   - Regional Manager: Regional management
4. Integrate with real APIs:
   - `GET /api/v1/rbac/users` - User management
   - `GET /api/v1/rbac/roles` - Role management
   - `GET /api/v1/feature-flags` - Feature flags
   - `GET /api/v1/analytics/platform` - Platform analytics
5. Implement role-based content filtering
6. Remove all mock data

**Reference:**
- `discovery/content/information-architecture.md` section 1.4, 2.4
- `discovery/content/navigation-hierarchy.md` section 3 (Admin navigation)

**Acceptance Criteria:**
- [ ] Single unified admin dashboard
- [ ] Role-based content filtering works
- [ ] User management functional
- [ ] Feature flag management works
- [ ] Platform analytics show real data
- [ ] No duplicate dashboards
- [ ] No mock data

---

#### Step 4.2: Implement Admin Management Features

**Location:** `lib/features/admin/presentation/pages/` (create if needed)

**Tasks:**
1. Implement user management with RBAC
2. Implement system configuration
3. Implement feature flag management
4. Implement platform analytics
5. Integrate with real APIs:
   - `GET /api/v1/rbac/users` - List users
   - `POST /api/v1/rbac/users` - Create user
   - `PUT /api/v1/rbac/users/{user_id}` - Update user
   - `POST /api/v1/rbac/users/{user_id}/roles` - Assign roles
   - `GET /api/v1/feature-flags` - List flags
   - `PUT /api/v1/feature-flags/{flag_id}` - Update flag
6. Remove mock data

**Reference:**
- `discovery/content/information-architecture.md` section 2.4
- `discovery/content/user-journey.md` section 3.1

**Acceptance Criteria:**
- [ ] User management works with real API
- [ ] RBAC assignment functional
- [ ] Feature flag management works
- [ ] System configuration saves to backend
- [ ] Platform analytics accurate
- [ ] No mock data

---

### Phase 5: Onboarding Flow Restructuring (Week 3, Days 1-2)

#### Step 5.1: Implement Complete Onboarding Flow

**Location:** `lib/features/onboarding/presentation/pages/` (restructure existing)

**Tasks:**
1. Implement complete onboarding flow from `user-journey.md` section 2.1
2. Steps to implement:
   - Welcome & Language Selection
   - Phone Verification
   - OTP Verification
   - Basic Profile Setup
   - Agent Discovery & Connection
   - Document Upload & Verification
   - KYC Verification
   - Emergency Contact Setup
3. Integrate with real APIs:
   - `POST /api/v1/auth/phone-verification` - Send OTP
   - `POST /api/v1/auth/verify-otp` - Verify OTP
   - `POST /api/v1/users/me` - Update profile
   - `POST /api/v1/agents/discover` - Agent discovery
   - `POST /api/v1/users/kyc/documents` - Upload documents
   - `POST /api/v1/users/kyc/verify` - KYC verification
   - `POST /api/v1/users/emergency-contact` - Add emergency contact
4. Implement data pending state handling
5. Remove mock data

**Reference:**
- `discovery/content/user-journey.md` section 2.1
- `discovery/content/navigation-hierarchy.md` section 2.1
- `discovery/content/wireframes.md` sections 2.1-2.4, 4.7-4.12

**Acceptance Criteria:**
- [ ] Complete onboarding flow matches user journey
- [ ] All steps integrate with real APIs
- [ ] Agent discovery works correctly
- [ ] Document upload functional
- [ ] KYC verification works
- [ ] Data pending state handled properly
- [ ] No mock data

---

### Phase 6: React Config Portal Restructuring (Week 3, Days 3-5)

#### Step 6.1: Implement Complete Data Import Flow

**Location:** `config-portal/src/pages/`

**Tasks:**
1. Implement complete import workflow from `user-journey.md` section 2.1 (Sub-Journey 1-5)
2. Create/update screens:
   - `DataImportDashboard.tsx` - Import dashboard with statistics
   - `ExcelUpload.tsx` - File upload with validation
   - `ImportProgress.tsx` - Real-time progress tracking
   - `ImportErrors.tsx` - Error review and resolution
   - `ImportSuccess.tsx` - Success confirmation
3. Integrate with real APIs:
   - `GET /api/v1/data-import/status` - Import status
   - `POST /api/v1/data-import/upload` - Upload Excel file
   - `GET /api/v1/data-import/{import_id}/progress` - Progress tracking
   - `GET /api/v1/data-import/{import_id}/errors` - Import errors
   - `POST /api/v1/data-import/{import_id}/retry` - Retry import
4. Implement Excel template download
5. Implement column mapping
6. Implement real-time progress updates
7. Remove mock data

**Reference:**
- `discovery/content/user-journey.md` section 2.1 (Sub-Journeys 1-5)
- `discovery/content/wireframes.md` sections 4.13.1-4.13.5
- `discovery/content/information-architecture.md` section 2.3

**Acceptance Criteria:**
- [ ] Complete import flow matches user journey
- [ ] File upload works with real backend
- [ ] Progress tracking shows real-time updates
- [ ] Error handling functional
- [ ] Template download works
- [ ] Column mapping functional
- [ ] No mock data

---

#### Step 6.2: Implement Config Portal Dashboard

**Location:** `config-portal/src/pages/Dashboard.tsx`

**Tasks:**
1. Implement import dashboard from wireframes
2. Integrate with real APIs:
   - `GET /api/v1/data-import/statistics` - Import statistics
   - `GET /api/v1/data-import/history` - Import history
   - `GET /api/v1/data-import/quality-metrics` - Data quality metrics
3. Display real import statistics
4. Show recent import activity
5. Implement quick actions
6. Remove mock data

**Reference:**
- `discovery/content/wireframes.md` section 4.13.1
- `discovery/content/information-architecture.md` section 2.3

**Acceptance Criteria:**
- [ ] Dashboard shows real statistics
- [ ] Recent activity displays correctly
- [ ] Quick actions work
- [ ] No mock data

---

### Phase 7: Content Structure Conformance (Week 3, Days 6-7)

#### Step 7.1: Verify Content Structure Compliance

**Tasks:**
1. Review all screens against `content-structure.md`
2. Ensure content hierarchy matches exactly
3. Verify content types (Static, Dynamic, Interactive, Media, Social)
4. Check content organization per user type
5. Verify content templates match specifications
6. Ensure visual content standards (icons, typography) match

**Reference:** `discovery/content/content-structure.md`

**Acceptance Criteria:**
- [ ] All content matches content structure document
- [ ] Content hierarchy correct
- [ ] Content types properly categorized
- [ ] Visual standards match specifications

---

#### Step 7.2: Verify Information Architecture Compliance

**Tasks:**
1. Review all screens against `information-architecture.md`
2. Verify user types and access levels match
3. Check core information architecture
4. Verify detailed content structure per portal
5. Ensure navigation hierarchy matches
6. Verify content organization principles

**Reference:** `discovery/content/information-architecture.md`

**Acceptance Criteria:**
- [ ] User types and access levels correct
- [ ] Information architecture matches document
- [ ] Content structure per portal matches
- [ ] Navigation hierarchy correct

---

#### Step 7.3: Verify Navigation Hierarchy Compliance

**Tasks:**
1. Review navigation against `navigation-hierarchy.md`
2. Verify customer navigation (5 tabs)
3. Verify agent navigation (5 tabs)
4. Verify admin navigation
5. Check secondary navigation patterns
6. Verify user flows match specifications

**Reference:** `discovery/content/navigation-hierarchy.md`

**Acceptance Criteria:**
- [ ] Navigation matches hierarchy document
- [ ] Tab counts correct
- [ ] Secondary navigation functional
- [ ] User flows match specifications

---

#### Step 7.4: Verify Wireframe Compliance

**Tasks:**
1. Review all screens against `wireframes.md`
2. Verify UI matches wireframes exactly
3. Check component layouts
4. Verify feature flag integration
5. Check responsive design
6. Verify accessibility features

**Reference:** `discovery/content/wireframes.md`

**Acceptance Criteria:**
- [ ] All screens match wireframes
- [ ] Component layouts correct
- [ ] Feature flags integrated
- [ ] Responsive design works
- [ ] Accessibility features functional

---

### Phase 8: API Integration Verification (Week 4, Days 1-2)

#### Step 8.1: Remove All Mock Data

**Tasks:**
1. Search codebase for mock data patterns:
   - `mockData`, `MockData`, `MOCK_DATA`
   - `fakeData`, `FakeData`, `FAKE_DATA`
   - `sampleData`, `SampleData`, `SAMPLE_DATA`
   - `placeholder`, `Placeholder`
   - `TODO.*mock`, `TODO.*fake`
2. Replace all mock data with real API calls
3. Update ViewModels to use real repositories
4. Update DataSources to call real APIs
5. Remove any hardcoded test data

**Search Commands:**
```bash
# Search for mock data patterns
grep -r "mockData\|MockData\|MOCK_DATA" lib/
grep -r "fakeData\|FakeData\|FAKE_DATA" lib/
grep -r "sampleData\|SampleData\|SAMPLE_DATA" lib/
grep -r "placeholder.*data\|Placeholder.*Data" lib/
```

**Acceptance Criteria:**
- [ ] No mock data found in codebase
- [ ] All ViewModels use real APIs
- [ ] All DataSources call real endpoints
- [ ] No hardcoded test data

---

#### Step 8.2: Verify API Integration

**Tasks:**
1. Create API integration test checklist
2. Test each screen's API calls
3. Verify error handling
4. Verify loading states
5. Verify data refresh
6. Document any missing APIs

**API Endpoints to Verify:**
- Authentication: `/api/v1/auth/*`
- Users: `/api/v1/users/*`
- Policies: `/api/v1/policies/*`
- Agents: `/api/v1/agents/*`
- Analytics: `/api/v1/analytics/*`
- Campaigns: `/api/v1/campaigns/*`
- Content: `/api/v1/content/*`
- Chat: `/api/v1/chat/*`
- Chatbot: `/api/v1/chatbot/*`
- Notifications: `/api/v1/notifications/*`
- Data Import: `/api/v1/data-import/*`
- RBAC: `/api/v1/rbac/*`
- Feature Flags: `/api/v1/feature-flags/*`

**Acceptance Criteria:**
- [ ] All API calls work correctly
- [ ] Error handling implemented
- [ ] Loading states show properly
- [ ] Data refresh works
- [ ] Missing APIs documented

---

### Phase 9: Database Migration Verification (Week 4, Days 3-4)

#### Step 9.1: Review Database Schema

**Tasks:**
1. Review existing Flyway migrations in `db/migration/`
2. Verify database schema matches API requirements
3. Document any missing tables/columns
4. Create new Flyway migrations if needed (only if absolutely necessary)
5. Test migrations on clean database

**Location:** `db/migration/`

**Acceptance Criteria:**
- [ ] Database schema supports all API endpoints
- [ ] All migrations tested
- [ ] No manual database changes needed
- [ ] Schema matches API models

---

#### Step 9.2: Verify Data Access Patterns

**Tasks:**
1. Review repository implementations
2. Verify all queries use proper SQLAlchemy models
3. Check for any raw SQL that bypasses models
4. Verify transaction handling
5. Check for N+1 query problems

**Location:** `backend/app/repositories/`

**Acceptance Criteria:**
- [ ] All repositories use SQLAlchemy models
- [ ] No raw SQL bypassing models
- [ ] Transaction handling correct
- [ ] No N+1 query problems

---

### Phase 10: Testing & Validation (Week 4, Days 5-7)

#### Step 10.1: User Flow Testing

**Tasks:**
1. Test complete customer onboarding flow
2. Test customer portal navigation
3. Test agent portal navigation
4. Test admin portal navigation
5. Test config portal import flow
6. Document any issues found

**Test Scenarios:**
- Customer: Onboarding → Dashboard → Policies → Chat → Learning → Profile
- Agent: Login → Dashboard → Customers → Analytics → Campaigns → Profile
- Admin: Login → Overview → Management → Configuration → Analytics
- Config Portal: Login → Dashboard → Upload → Progress → Results

**Acceptance Criteria:**
- [ ] All user flows work end-to-end
- [ ] Navigation works correctly
- [ ] Data displays correctly
- [ ] No broken links or routes

---

#### Step 10.2: Content Conformance Testing

**Tasks:**
1. Verify content structure matches documents
2. Verify information architecture matches
3. Verify navigation hierarchy matches
4. Verify wireframes match implementation
5. Document any deviations

**Checklist:**
- [ ] Content structure 100% compliant
- [ ] Information architecture 100% compliant
- [ ] Navigation hierarchy 100% compliant
- [ ] Wireframes 100% compliant
- [ ] User journeys 100% compliant

**Acceptance Criteria:**
- [ ] 100% conformance with all discovery documents
- [ ] All deviations documented and justified
- [ ] Content matches specifications exactly

---

#### Step 10.3: API Integration Testing

**Tasks:**
1. Test all API endpoints used by Flutter app
2. Test all API endpoints used by React portal
3. Verify error handling
4. Verify loading states
5. Verify data refresh
6. Document any API issues

**Acceptance Criteria:**
- [ ] All APIs work correctly
- [ ] Error handling proper
- [ ] Loading states functional
- [ ] Data refresh works
- [ ] No API errors in production

---

#### Step 10.4: Performance Testing

**Tasks:**
1. Test app performance with real data
2. Check loading times
3. Verify smooth navigation
4. Check memory usage
5. Verify offline handling

**Acceptance Criteria:**
- [ ] App performs well with real data
- [ ] Loading times acceptable
- [ ] Navigation smooth
- [ ] Memory usage reasonable
- [ ] Offline handling works

---

## Implementation Guidelines

### Code Quality Standards

1. **No Mock Data**
   - All screens must use real API endpoints
   - Remove all `mockData`, `fakeData`, `sampleData` patterns
   - Use real ViewModels and Repositories

2. **Real API Integration**
   - All API calls must go through proper service layers
   - Use existing API client implementations
   - Handle errors properly
   - Show loading states

3. **Database Changes**
   - Use Flyway migrations only
   - No manual database changes
   - Test migrations on clean database
   - Document schema changes

4. **Navigation Structure**
   - Use navigation containers, not individual screens
   - Implement proper tab-based navigation
   - Use drawer/hamburger menus for secondary navigation
   - Follow navigation hierarchy exactly

5. **Content Structure**
   - Match content structure document exactly
   - Use proper content hierarchy
   - Follow content organization principles
   - Match wireframes precisely

### File Organization

#### Flutter App Structure
```
lib/
├── navigation/              # Navigation containers (NEW)
│   ├── customer_navigation.dart
│   ├── agent_navigation.dart
│   ├── admin_navigation.dart
│   └── navigation_router.dart
├── features/
│   ├── customer_dashboard/  # Customer portal features
│   ├── policies/            # Policies management
│   ├── chat/                # Chat and communication
│   ├── learning/            # Learning center
│   ├── profile/             # User profile
│   ├── agent_dashboard/     # Agent portal features (NEW)
│   ├── customers/           # Customer management
│   ├── analytics/           # Analytics and ROI
│   ├── campaigns/           # Marketing campaigns
│   ├── admin_dashboard/     # Admin portal features (NEW)
│   └── onboarding/          # Onboarding flow
└── screens/                  # Individual screens (CONSOLIDATE)
    └── [Keep only screens that don't fit in features/]
```

#### React Config Portal Structure
```
config-portal/src/
├── pages/
│   ├── Dashboard.tsx         # Import dashboard
│   ├── DataImport.tsx        # Excel upload
│   ├── ImportProgress.tsx    # Progress tracking
│   ├── ImportErrors.tsx      # Error handling
│   ├── ImportSuccess.tsx     # Success confirmation
│   └── ExcelTemplate.tsx     # Template management
└── services/
    └── dataImportApi.ts      # API integration
```

### API Integration Patterns

#### Flutter API Call Pattern
```dart
// ViewModel
class CustomerDashboardViewModel extends StateNotifier<CustomerDashboardState> {
  final CustomerDashboardRepository _repository;
  
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repository.getDashboardData();
      state = state.copyWith(
        isLoading: false,
        dashboardData: data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Repository
class CustomerDashboardRepository {
  final ApiClient _apiClient;
  
  Future<CustomerDashboardData> getDashboardData() async {
    final response = await _apiClient.get('/api/v1/dashboard/analytics');
    return CustomerDashboardData.fromJson(response.data);
  }
}
```

#### React API Call Pattern
```typescript
// Service
export const dataImportApi = {
  async uploadFile(file: File): Promise<ImportResponse> {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await apiClient.post('/api/v1/data-import/upload', formData, {
      headers: { 'Content-Type': 'multipart/form-data' },
    });
    
    return response.data;
  },
  
  async getProgress(importId: string): Promise<ImportProgress> {
    const response = await apiClient.get(`/api/v1/data-import/${importId}/progress`);
    return response.data;
  },
};
```

### Error Handling Patterns

#### Flutter Error Handling
```dart
try {
  final data = await _repository.getData();
  // Handle success
} on ApiException catch (e) {
  // Handle API errors
  showError(e.message);
} on NetworkException catch (e) {
  // Handle network errors
  showError('Network error. Please check your connection.');
} catch (e) {
  // Handle unexpected errors
  showError('An unexpected error occurred.');
}
```

#### React Error Handling
```typescript
try {
  const data = await api.getData();
  // Handle success
} catch (error) {
  if (error.response) {
    // API error
    showError(error.response.data.message);
  } else if (error.request) {
    // Network error
    showError('Network error. Please check your connection.');
  } else {
    // Unexpected error
    showError('An unexpected error occurred.');
  }
}
```

---

## Success Criteria

### Functional Requirements
- [ ] **100% Navigation Conformance** - All navigation matches navigation-hierarchy.md
- [ ] **100% Content Conformance** - All content matches content-structure.md
- [ ] **100% IA Conformance** - All screens match information-architecture.md
- [ ] **100% Wireframe Conformance** - All UI matches wireframes.md
- [ ] **100% User Journey Conformance** - All flows match user-journey.md
- [ ] **Zero Mock Data** - No mock/fake/sample data in codebase
- [ ] **Real API Integration** - All screens use real backend APIs
- [ ] **Proper Navigation** - Tab-based navigation with drawer menus
- [ ] **Unified Dashboards** - Single dashboard per user type
- [ ] **Complete Import Flow** - Full Excel import workflow in config portal

### Technical Requirements
- [ ] **Clean Codebase** - No duplicate screens, proper organization
- [ ] **API Integration** - All API calls work correctly
- [ ] **Error Handling** - Proper error handling throughout
- [ ] **Loading States** - Loading indicators where needed
- [ ] **Database Migrations** - All DB changes via Flyway
- [ ] **Performance** - App performs well with real data
- [ ] **Accessibility** - Accessibility features work
- [ ] **Responsive Design** - Works on all screen sizes

### Quality Requirements
- [ ] **No Broken Links** - All navigation works
- [ ] **No Console Errors** - Clean console output
- [ ] **Proper State Management** - State handled correctly
- [ ] **Code Documentation** - Code is well documented
- [ ] **Test Coverage** - Critical paths tested

---

## Risk Mitigation

### Potential Risks

1. **Missing API Endpoints**
   - **Risk:** Some features may require new API endpoints
   - **Mitigation:** Document missing APIs, create tickets for backend team
   - **Fallback:** Implement UI with proper error handling, add API later

2. **Database Schema Gaps**
   - **Risk:** Database may not support all required features
   - **Mitigation:** Review schema early, create Flyway migrations if needed
   - **Fallback:** Use existing schema, document limitations

3. **Performance Issues**
   - **Risk:** Real API calls may be slower than mocks
   - **Mitigation:** Implement proper loading states, optimize API calls
   - **Fallback:** Add caching where appropriate

4. **Breaking Changes**
   - **Risk:** Restructuring may break existing functionality
   - **Mitigation:** Test thoroughly, maintain backward compatibility where possible
   - **Fallback:** Keep old screens temporarily, migrate gradually

---

## Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|------------------|
| Phase 1: Navigation Architecture | 2 days | Navigation containers, routing |
| Phase 2: Customer Portal | 3 days | Customer dashboard, tabs, content |
| Phase 3: Agent Portal | 4 days | Agent dashboard, tabs, content |
| Phase 4: Admin Portal | 3 days | Admin dashboard, management features |
| Phase 5: Onboarding Flow | 2 days | Complete onboarding implementation |
| Phase 6: Config Portal | 3 days | Data import flow, dashboard |
| Phase 7: Content Conformance | 2 days | Content structure verification |
| Phase 8: API Integration | 2 days | Mock data removal, API verification |
| Phase 9: Database Verification | 2 days | Schema review, migrations |
| Phase 10: Testing & Validation | 3 days | End-to-end testing, conformance verification |
| **Total** | **26 days** | **Complete app restructuring** |

---

## Next Steps

1. **Review this plan** with the team
2. **Set up development environment** if needed
3. **Start with Phase 1** - Navigation Architecture Foundation
4. **Follow steps sequentially** - Each phase builds on previous
5. **Test as you go** - Don't wait until the end
6. **Document issues** - Keep track of any problems
7. **Update plan** - Adjust as needed based on findings

---

## Notes for Cursor AI Coding Agent

When implementing this plan:

1. **Read discovery documents first** - Understand the target state
2. **Check existing code** - See what's already implemented
3. **Use real APIs** - Never create mock data
4. **Follow patterns** - Use existing code patterns
5. **Test incrementally** - Test each step before moving on
6. **Document changes** - Comment on why changes were made
7. **Ask for clarification** - If something is unclear, ask

**Remember:** The goal is 100% conformance with discovery documents. Every screen, every navigation pattern, every content structure must match the specifications exactly.

---

**End of Project Plan**

