# Pages Design Implementation Plan

This document outlines the comprehensive implementation plan based on `discovery/design/pages-design.md`. It identifies all missing features and provides a structured approach to implementation.

## 📋 Overview

The design document specifies **11 major sections** with **50+ pages/screens** that need to be implemented. This plan breaks down each section into actionable tasks.

---

## ✅ Currently Implemented

### Authentication & Onboarding
- ✅ Basic Login Page (`login_page.dart`)
- ✅ OTP Verification Page (`otp_verification_page.dart`)
- ✅ Basic Onboarding Page (`onboarding_page.dart`)
- ✅ Welcome Screen (`welcome_screen.dart`)
- ✅ Trial Setup Screen (`trial_setup_screen.dart`)

### Customer Portal
- ✅ Basic Dashboard Page (`dashboard_page.dart`)
- ✅ Policies List Page (`policies_list_page.dart`)
- ✅ Claims Page (`claims_page.dart`)

### Agent Portal
- ✅ Agent Profile Page (`agent_profile_page.dart`)
- ✅ Customers Page (`customers_page.dart`)
- ✅ Reports Page (`reports_page.dart`)

### Other Features
- ✅ Chatbot Page (`chatbot_page.dart`)
- ✅ Notifications Page (`notification_page.dart`)

---

## 🚧 Missing Features by Section

### Section 1: Pages Design Philosophy & Architecture

#### 1.5 CDN-Based Multilingual Support & Localization ⚠️ **CRITICAL**

**Status:** Not Implemented

**Required Components:**
- [ ] `lib/services/localization_service.dart` - CDN localization loader
- [ ] `lib/services/cdn_service.dart` - CDN communication service
- [ ] ARB files for English, Hindi, Telugu in `assets/l10n/`
- [ ] CDN URL configuration and version checking
- [ ] Local caching with SharedPreferences
- [ ] Fallback to bundled ARB files
- [ ] Background sync for updates
- [ ] Widget-level localization usage

**Implementation Steps:**
1. Create `LocalizationService` class with CDN loading logic
2. Implement caching mechanism with version checking
3. Create fallback ARB files
4. Integrate with `main.dart` for app-level localization
5. Create `LocalizedText` widget for easy usage
6. Update all existing pages to use localization service

---

### Section 2: Authentication & Onboarding Pages

#### 2.1 Authentication Flow Pages

**2.1.1 Welcome & Trial Onboarding Page** ⚠️ **ENHANCEMENT NEEDED**

**Status:** Basic version exists, needs enhancement

**Missing Features:**
- [ ] Fade-in animations
- [ ] Trial offer banner (14-day free trial)
- [ ] Auth status checking with role-based navigation
- [ ] Gradient background
- [ ] Enhanced UI with proper spacing and styling

**2.1.2 Phone Registration Page** ⚠️ **ENHANCEMENT NEEDED**

**Status:** Basic version exists (`phone_verification_screen.dart`)

**Missing Features:**
- [ ] Country code selector
- [ ] Agent code input option
- [ ] Enhanced validation
- [ ] Better error handling
- [ ] UI improvements per design spec

#### 2.2 Trial Setup & Profile Creation Pages

**Status:** Basic version exists, needs completion

**Missing Features:**
- [ ] Complete profile form with all fields
- [ ] Role selection cards (Policyholder/Agent)
- [ ] Email validation
- [ ] Trial activation confirmation
- [ ] Profile picture upload
- [ ] Terms and conditions acceptance

---

### Section 3: Customer Portal Pages

#### 3.1 Customer Dashboard Page ⚠️ **MAJOR ENHANCEMENT NEEDED**

**Status:** Basic version exists, needs major enhancements

**Missing Components:**
- [ ] Welcome header with user name and date
- [ ] Notification bell with badge count
- [ ] Quick Actions section (Pay Premium, Contact Agent, Get Quote)
- [ ] Policy Overview cards (Active, Maturing, Lapsed)
- [ ] Critical Notifications section
- [ ] Quick Insights section
- [ ] Bottom Navigation Bar (Home, Policies, Chat, Learning, Profile)
- [ ] Pull-to-refresh functionality
- [ ] Global search button
- [ ] Theme switcher

**Implementation Steps:**
1. Create `CustomerDashboardViewModel` with all data models
2. Implement `_buildWelcomeHeader()` widget
3. Implement `_buildQuickActions()` widget
4. Implement `_buildPolicyOverview()` widget
5. Implement `_buildCriticalNotifications()` widget
6. Implement `_buildQuickInsights()` widget
7. Add bottom navigation bar
8. Integrate with backend API

#### 3.2 Policy Management Pages

**3.2.1 Policies List Page** ⚠️ **ENHANCEMENT NEEDED**

**Status:** Basic version exists

**Missing Features:**
- [ ] Filter chips (All, Active, Maturing, Lapsed)
- [ ] Search functionality
- [ ] Policy cards with status indicators
- [ ] Empty state handling
- [ ] FAB for "Get Quote"
- [ ] Pull-to-refresh

**3.2.2 Policy Details Page** ⚠️ **NEEDS COMPLETE IMPLEMENTATION**

**Status:** Basic version exists (`policy_details_screen.dart`)

**Missing Features:**
- [ ] Complete policy information display
- [ ] Premium payment section
- [ ] Payment history timeline
- [ ] Action buttons (Pay Premium, Contact Agent, File Claim)
- [ ] Document downloads
- [ ] Policy status indicators
- [ ] Maturity date countdown

**3.2.3 Premium Payment Page** ❌ **NOT IMPLEMENTED**

**Status:** Not implemented

**Required:**
- [ ] Payment form with amount input
- [ ] Payment method selection (UPI, Card, Net Banking)
- [ ] Payment history display
- [ ] Success/error handling
- [ ] Receipt generation

**3.2.4 Get Quote Page** ❌ **NOT IMPLEMENTED**

**Status:** Not implemented

**Required:**
- [ ] Quote request form
- [ ] Product selection
- [ ] Agent assignment
- [ ] Quote comparison view

---

### Section 4: Agent Portal Pages

#### 4.1 Agent Dashboard Page ⚠️ **MAJOR ENHANCEMENT NEEDED**

**Status:** Basic version exists, needs major enhancements

**Missing Components:**
- [ ] Welcome header with greeting and agent code
- [ ] KPI Cards (Monthly Revenue, Active Customers, Policies Sold, Commission)
- [ ] Trend Charts (Revenue, Customer Growth)
- [ ] Action Items section
- [ ] Smart Alerts section
- [ ] Bottom Navigation Bar (Home, Customers, Analytics, Campaigns, Content)
- [ ] FAB for adding customers
- [ ] Notification bell

**Implementation Steps:**
1. Create `AgentDashboardViewModel` with KPI data
2. Implement KPI cards widget
3. Implement trend charts (use `fl_chart` package)
4. Implement action items list
5. Implement smart alerts section
6. Add bottom navigation
7. Integrate with backend API

#### 4.2 Presentation Carousel Homepage Integration ⚠️ **NEEDS INTEGRATION**

**Status:** Presentation carousel exists, needs integration

**Missing:**
- [ ] Integration into agent home dashboard
- [ ] Edit button functionality
- [ ] Empty state handling
- [ ] Auto-play configuration
- [ ] Height configuration

#### 4.3 Presentation Editor Page ⚠️ **NEEDS COMPLETE IMPLEMENTATION**

**Status:** Partial implementation exists

**Missing Features:**
- [ ] Full slide management (add, edit, delete, reorder)
- [ ] Media upload functionality
- [ ] Drag-and-drop for slide reordering
- [ ] Preview mode
- [ ] Save and publish functionality
- [ ] Template selection
- [ ] Text editing capabilities
- [ ] Image editing capabilities

#### 4.4 Presentation List Page ❌ **NOT IMPLEMENTED**

**Status:** Not implemented

**Required:**
- [ ] List view with presentation cards
- [ ] Filters (Active, Draft, Archived)
- [ ] Search functionality
- [ ] Create new presentation button
- [ ] Edit/Delete actions
- [ ] Preview functionality

---

### Section 5: Agent Configuration Portal Wireframes

**Status:** All pages not implemented

#### 5.2 Data Import Dashboard ❌ **NOT IMPLEMENTED**

**Required:**
- [ ] Quick Actions (Excel Import, LIC API Sync, Bulk Update)
- [ ] Import Statistics cards
- [ ] Recent Imports list
- [ ] Bulk Actions section
- [ ] New Import FAB
- [ ] Import history view

#### 5.3 Excel Template Configuration Page ❌ **NOT IMPLEMENTED**

**Required:**
- [ ] Template selection
- [ ] Field mapping interface
- [ ] Validation rules configuration
- [ ] Import preview
- [ ] Save template functionality

#### 5.4 Customer Data Management Page ❌ **NOT IMPLEMENTED**

**Required:**
- [ ] Customer list with filters
- [ ] Search functionality
- [ ] Add Customer form
- [ ] Edit Customer form
- [ ] Customer details view
- [ ] Bulk operations (export, delete, update)

#### 5.5 Reporting Dashboard Page ❌ **NOT IMPLEMENTED**

**Required:**
- [ ] Report generation interface
- [ ] Filters (date range, report type)
- [ ] Export options (PDF, Excel, CSV)
- [ ] Scheduled reports
- [ ] Report history

#### 5.6 User Management Page ❌ **NOT IMPLEMENTED**

**Required:**
- [ ] User list with filters
- [ ] Add User form
- [ ] Edit User form
- [ ] Role assignment
- [ ] Permissions management
- [ ] User activity logs

---

### Section 6: Customer Onboarding Wireframes

**Status:** Basic onboarding exists, needs complete 5-step flow

#### 6.2 Agent Discovery & Selection Page ⚠️ **ENHANCEMENT NEEDED**

**Status:** Basic version exists (`agent_discovery_screen.dart`)

**Missing Features:**
- [ ] Enhanced search bar with debouncing
- [ ] Advanced filters (region, specialization)
- [ ] Agent cards with ratings and reviews
- [ ] Agent details view
- [ ] Selection confirmation

#### 6.3 Document Upload & Verification Page ⚠️ **ENHANCEMENT NEEDED**

**Status:** Basic version exists (`document_upload_screen.dart`)

**Missing Features:**
- [ ] Multi-step upload process
- [ ] Document preview
- [ ] Verification status indicators
- [ ] Retry functionality
- [ ] Document type selection

#### 6.4 KYC Verification & Biometric Setup Page ⚠️ **ENHANCEMENT NEEDED**

**Status:** Basic version exists (`kyc_verification_screen.dart`)

**Missing Features:**
- [ ] Complete KYC form
- [ ] Biometric capture (fingerprint/face)
- [ ] Verification status display
- [ ] Completion flow

#### 6.5 Emergency Contact Setup Page ⚠️ **ENHANCEMENT NEEDED**

**Status:** Basic version exists (`emergency_contact_screen.dart`)

**Missing Features:**
- [ ] Multiple contacts support
- [ ] Contact validation
- [ ] Relationship selection
- [ ] Save functionality

#### 6.6 Onboarding Completion Page ❌ **NOT IMPLEMENTED**

**Status:** Not implemented

**Required:**
- [ ] Success animation
- [ ] Summary display
- [ ] Next steps information
- [ ] Navigation to dashboard

---

### Section 7: Agent Portal Enhanced Wireframes

#### 7.1 Callback Request Management Dashboard ❌ **NOT IMPLEMENTED**

**Status:** Not implemented

**Required:**
- [ ] Priority tabs (All, High, Medium, Low)
- [ ] Requests list with filters
- [ ] Create callback FAB
- [ ] Callback details view
- [ ] Schedule callback functionality
- [ ] Callback analytics

---

### Section 8: WhatsApp Integration Pages

**Status:** Basic version exists (`whatsapp_integration_screen.dart`), needs enhancement

**Missing Features:**
- [ ] Full chat interface with message bubbles
- [ ] Typing indicators
- [ ] Media support (images, documents)
- [ ] Call and video call buttons
- [ ] Message status indicators (sent, delivered, read)
- [ ] Timestamp display
- [ ] Chat history loading

---

### Section 9: Error Handling & Edge Cases

#### 9.1 Error Pages ❌ **NOT IMPLEMENTED**

**Status:** Not implemented

**Required Pages:**
- [ ] Network Error Page
- [ ] Trial Expired Page
- [ ] Unauthorized Page (403)
- [ ] Not Found Page (404)
- [ ] Server Error Page (500)

#### 9.2 Loading & Empty States ⚠️ **PARTIAL IMPLEMENTATION**

**Status:** Basic loading exists, needs enhancement

**Missing:**
- [ ] `LoadingCard` widget
- [ ] `EmptyStateCard` widget
- [ ] Skeleton loaders
- [ ] Retry mechanisms
- [ ] Consistent loading states across all pages

---

### Section 10: Feature Flag Integration in Pages

#### 10.1 Conditional Page Rendering ❌ **NOT IMPLEMENTED**

**Status:** Not implemented

**Required:**
- [ ] `FeatureFlagPageBuilder` widget
- [ ] Conditional rendering based on flags
- [ ] Fallback UI for disabled features

#### 10.2 Real-Time Feature Flag Updates ❌ **NOT IMPLEMENTED**

**Status:** Not implemented

**Required:**
- [ ] Background sync for feature flags
- [ ] WebSocket integration (optional)
- [ ] UI refresh on flag changes

---

## 🎯 Implementation Priority

### Phase 1: Critical Foundation (Week 1-2)
1. **CDN-Based Multilingual Support** - Required for all pages
2. **Error Handling Pages** - Required for production
3. **Loading & Empty States** - Required for UX

### Phase 2: Core Customer Features (Week 3-4)
4. **Customer Dashboard Enhancement**
5. **Policy Management Pages Completion**
6. **Premium Payment Page**
7. **Get Quote Page**

### Phase 3: Core Agent Features (Week 5-6)
8. **Agent Dashboard Enhancement**
9. **Presentation Editor Completion**
10. **Presentation List Page**
11. **Callback Management Dashboard**

### Phase 4: Configuration Portal (Week 7-8)
12. **Data Import Dashboard**
13. **Excel Template Configuration**
14. **Customer Data Management**
15. **Reporting Dashboard**
16. **User Management**

### Phase 5: Onboarding & Integration (Week 9-10)
17. **Customer Onboarding Flow Completion**
18. **WhatsApp Integration Enhancement**
19. **Feature Flag Integration**

---

## 📝 Implementation Guidelines

### Code Structure
- Follow existing feature module structure: `lib/features/{feature}/`
- Use Clean Architecture: Data → Domain → Presentation
- Implement ViewModels for state management
- Use Repository pattern for data access

### Design System
- Use Material Design 3.0 components
- Follow theme from `lib/shared/theme/app_theme.dart`
- Ensure 48pt minimum touch targets
- Support dark/light themes

### Accessibility
- Add semantic labels
- Support screen readers
- Keyboard navigation support
- WCAG 2.1 AA compliance

### Testing
- Unit tests for ViewModels
- Widget tests for pages
- Integration tests for flows

### Documentation
- Add code comments
- Update API documentation
- Create user guides for complex flows

---

## 🔗 Related Documents

- [Design Document](../discovery/design/pages-design.md)
- [Project Structure](../development/PROJECT_STRUCTURE_PROGRESS.md)
- [API Documentation](../../backend/docs/API.md)
- [Feature Flags Documentation](../../lib/shared/constants/feature_flags.dart)

---

**Last Updated:** 2025-01-03  
**Status:** Planning Phase  
**Next Steps:** Begin Phase 1 implementation

