# Agent Mitra - Information Architecture (IA)

## 1. User Types & Access Levels

### 1.1 Policyholder (Customer) - Primary Users
**Characteristics:** Non-tech-savvy, elderly users, need simple, clear interface
- **Access Level:** Customer Portal Only
- **Key Needs:** Policy information, easy communication, reminders, simple transactions
- **RBAC Permissions:** View own policies, make payments, access documents, communicate with agent

### 1.2 Insurance Agent - Business Users
**Characteristics:** Business professionals, need analytics and management tools
- **Access Level:** Agent Portal + Customer Management
- **Key Needs:** Customer management, analytics, marketing tools, ROI tracking
- **RBAC Permissions:** Manage assigned customers, view analytics, create campaigns, upload content

### 1.3 Insurance Provider - Enterprise Users
**Characteristics:** Insurance companies beyond LIC
- **Access Level:** Provider Portal + Agent Management
- **Key Needs:** Product management, agent oversight, analytics
- **RBAC Permissions:** Manage products, oversee agents, view provider analytics, configure settings

### 1.4 Super Admin - Platform Managers
**Characteristics:** Platform administrators
- **Access Level:** Full System Access
- **Key Needs:** User management, system configuration, analytics
- **RBAC Permissions:** Full system access, feature flag management, user management, system configuration

## 2. Core Information Architecture

### 2.1 High-Level Site Structure

```
📱 Agent Mitra - Friend of Agents
├── 🔐 Authentication & Onboarding
├── 👥 Customer Portal (Policyholders)
│   ├── 📋 Dashboard (Clutter-free with essential info only)
│   ├── 📄 My Policies (Search-enabled, paginated)
│   ├── 💬 Communication Hub (WhatsApp + Smart Chatbot)
│   ├── 🤖 Smart Assistant (AI-powered help)
│   ├── 📚 Learning Center (Video tutorials)
│   ├── 🔍 Smart Search (Sitewide + page-specific)
│   └── ⚙️ Settings (Theme switcher, localization)
├── 🏗️ Agent Configuration Portal (Data Management)
│   ├── 📊 Import Dashboard (Status overview, statistics)
│   ├── 📤 Data Upload (Excel file upload, validation)
│   ├── 🔄 Import Processing (Progress tracking, error handling)
│   ├── ✅ Import Results (Success confirmation, mobile sync)
│   ├── 📋 Template Management (Download templates, guidelines)
│   └── 🔍 Data Analytics (Import history, quality metrics)
├── 💼 Agent Portal (Insurance Agents)
│   ├── 📊 Business Dashboard (Clean KPIs, minimal clutter)
│   ├── 👥 Customer Management (Advanced CRM, search-enabled)
│   ├── 📈 Analytics & ROI (Deep insights, actionable reports)
│   ├── 📢 Marketing Campaigns (Campaign builder, analytics)
│   ├── 📚 Content Management (Video upload, chatbot training)
│   ├── 💰 Revenue Tracking (Commission tracking, ROI)
│   ├── 🔍 Smart Search (Advanced filters, multi-criteria)
│   └── ⚙️ Agent Settings (Business profile, integrations)
├── 🏢 Provider Portal (Insurance Companies)
│   ├── 🏗️ Product Management (Product catalog, pricing)
│   ├── 👥 Agent Network (Agent management, performance)
│   ├── 📊 Provider Analytics (Business intelligence)
│   ├── 🔍 Search & Discovery (Product/agent search)
│   └── ⚙️ Provider Settings (Branding, configuration)
└── 🔧 Admin Panel (Super Admins)
    ├── 👥 User Management (RBAC, role assignment)
    ├── ⚙️ System Configuration (Feature flags, localization)
    ├── 📊 Platform Analytics (Usage, performance metrics)
    ├── 🔒 Security Management (Audit logs, compliance)
    └── 🌐 Localization Management (CDN-based content keys)
```

## 3. Detailed Content Structure

### 3.1 Customer Portal Content Hierarchy

#### Onboarding & Setup
```
👋 Customer Onboarding
├── 📱 Welcome & Language Selection
│   ├── App Introduction
│   ├── Language Choice (English/Hindi/Telugu)
│   ├── Trial Information
│   └── Getting Started Guide
├── 📞 Phone Verification
│   ├── Phone Number Input
│   ├── OTP Verification
│   └── Verification Success
├── 👤 Basic Profile Setup
│   ├── Personal Information
│   ├── User Type Selection
│   └── Preferences Setup
├── 🔍 Agent Discovery & Connection
│   ├── Agent Search Methods
│   ├── Policy Document Lookup
│   ├── LIC Helpline Integration
│   ├── Online Directory Search
│   └── Agent Verification Process
├── 📄 Document Verification
│   ├── Government ID Upload (Aadhaar/Voter ID/Passport)
│   ├── Selfie Verification
│   ├── OCR Processing & Validation
│   └── Address Verification
├── 🔍 KYC Verification
│   ├── Verification Checklist
│   ├── Processing Status
│   ├── Manual Review Queue
│   └── Approval Confirmation
├── 🚨 Emergency Contact Setup
│   ├── Contact Information
│   ├── Relationship Selection
│   └── Privacy & Security Info
└── ⏳ Data Pending State
    ├── Agent Upload Status
    ├── Contact Options
    ├── Limited Feature Access
    └── Notification Preferences
```

#### Dashboard (Main Entry Point)
```
📋 Customer Dashboard
├── 🎯 Quick Actions
│   ├── 💳 Pay Premium
│   ├── 📞 Contact Agent
│   ├── ❓ Get Quote
│   └── 📅 Schedule Meeting
├── 📊 Policy Overview
│   ├── Active Policies Count
│   ├── Upcoming Payments
│   ├── Policy Maturity Alerts
│   └── Recent Activity
├── 🔔 Notifications
│   ├── Payment Reminders
│   ├── Policy Updates
│   ├── Agent Messages
│   └── System Alerts
└── 🔗 Quick Links
    ├── Policy Documents
    ├── Premium Calculator
    ├── FAQ
    └── Support
```

#### Policy Management
```
📄 My Policies
├── 📋 All Policies
│   ├── Policy Cards (Visual)
│   ├── Search & Filter
│   ├── Sort by Status/Type
│   └── Quick Actions
├── 📄 Policy Details
│   ├── Basic Information
│   ├── Coverage Details
│   ├── Beneficiary Info
│   ├── Payment History
│   ├── Documents
│   └── Actions (Renew, Claim, etc.)
├── 💳 Premium Payments
│   ├── Payment Methods
│   ├── Payment History
│   ├── Upcoming Payments
│   └── Auto-payment Setup
└── 📋 Policy Documents
    ├── Download Center
    ├── Upload Documents
    ├── Document Categories
    └── Version History
```

#### Communication Hub
```
💬 Communication Hub
├── 💬 Messages
│   ├── Inbox
│   ├── Sent Messages
│   ├── Drafts
│   └── Message Templates
├── 📞 Agent Contact
│   ├── Direct Call
│   ├── WhatsApp Integration
│   ├── Email Agent
│   └── Schedule Call
├── 📢 Announcements
│   ├── Agent Broadcasts
│   ├── Policy Updates
│   ├── Product Launches
│   └── Important Notices
└── 👥 Community
    ├── Agent Directory
    ├── Discussion Forums
    ├── Q&A Section
    └── Help Groups
```

#### Smart Assistant (Chatbot)
```
🤖 Smart Assistant
├── 💬 Chat Interface
│   ├── Natural Language Processing
│   ├── Context Awareness
│   ├── Quick Replies
│   └── Conversation History
├── 📚 Knowledge Base
│   ├── FAQ Database
│   ├── Policy Information
│   ├── Procedure Guides
│   └── Troubleshooting
├── 🎥 Video Tutorials
│   ├── Agent-Uploaded Content
│   ├── Auto-Suggested Videos
│   ├── Video Categories
│   └── Watch History
└── 🆘 Smart Help
    ├── Contextual Help
    ├── Step-by-Step Guides
    ├── Emergency Contacts
    └── Escalation to Agent
```

#### Learning Center
```
📚 Learning Center
├── 🎓 Insurance Education
│   ├── Basic Concepts
│   ├── Product Explanations
│   ├── Claim Process
│   └── Financial Planning
├── 📋 Policy Tutorials
│   ├── Understanding Your Policy
│   ├── Maximizing Benefits
│   ├── Renewal Process
│   └── Document Requirements
├── 🆕 Product Information
│   ├── New Product Alerts
│   ├── Product Comparisons
│   ├── Feature Highlights
│   └── Enrollment Guides
└── 📊 Financial Tools
    ├── Premium Calculator
    ├── Coverage Calculator
    ├── ROI Calculator
    └── Goal Planning
```

### 3.2 Agent Portal Content Hierarchy

#### Business Dashboard
```
📊 Agent Dashboard
├── 📈 Key Metrics
│   ├── Monthly Revenue
│   ├── Active Customers
│   ├── Renewal Rate
│   ├── New Policies Sold
│   └── Customer Satisfaction
├── 🎯 Action Items
│   ├── Follow-up Tasks
│   ├── Payment Reminders
│   ├── Quote Requests
│   └── Customer Queries
├── 📊 Performance Charts
│   ├── Revenue Trends
│   ├── Customer Growth
│   ├── Policy Performance
│   └── Geographic Distribution
└── 🚨 Alerts & Notifications
    ├── Payment Failures
    ├── Policy Lapses
    ├── Customer Complaints
    └── System Updates
```

#### Customer Management
```
👥 Customer Management
├── 👥 Customer Database
│   ├── Customer Profiles
│   ├── Contact Information
│   ├── Policy Portfolio
│   └── Communication History
├── 📞 Communication Tools
│   ├── Bulk Messaging
│   ├── Personalized Templates
│   ├── Campaign Management
│   └── Response Tracking
├── 📊 Customer Analytics
│   ├── Engagement Scores
│   ├── Purchase Behavior
│   ├── Risk Profiles
│   └── Lifetime Value
└── 🎯 Customer Segmentation
    ├── High-Value Customers
    ├── At-Risk Customers
    ├── New Customers
    └── VIP Customers
```

#### Analytics & ROI Dashboard
```
📈 Analytics & ROI
├── 💰 Revenue Analytics
│   ├── Commission Tracking
│   ├── Policy Sales
│   ├── Renewal Income
│   └── Growth Trends
├── 📊 Performance Metrics
│   ├── Conversion Rates
│   ├── Customer Retention
│   ├── Average Policy Value
│   └── Market Share
├── 📋 ROI Calculations
│   ├── Marketing ROI
│   ├── Time Investment ROI
│   ├── Customer Acquisition Cost
│   └── Lifetime Value Analysis
└── 📊 Predictive Analytics
    ├── Renewal Predictions
    ├── Upsell Opportunities
    ├── Churn Risk
    └── Growth Forecasting
```

#### Marketing Campaigns
```
📢 Marketing Campaigns
├── 📧 Campaign Builder
│   ├── Template Library
│   ├── Drag & Drop Editor
│   ├── Personalization Tools
│   └── A/B Testing
├── 📊 Campaign Management
│   ├── Campaign Calendar
│   ├── Target Audiences
│   ├── Scheduling Tools
│   └── Performance Tracking
├── 📈 Campaign Analytics
│   ├── Open Rates
│   ├── Click Rates
│   ├── Conversion Tracking
│   └── Revenue Attribution
└── 📚 Content Library
    ├── Email Templates
    ├── SMS Templates
    ├── Push Notification Templates
    └── Social Media Posts
```

#### Content Management
```
📚 Content Management
├── 🎥 Video Library
│   ├── Upload Center
│   ├── Video Categories
│   ├── Thumbnail Generator
│   └── Access Analytics
├── 📄 Document Management
│   ├── Policy Documents
│   ├── Marketing Materials
│   ├── Training Content
│   └── Legal Documents
├── 📊 Content Performance
│   ├── View Analytics
│   ├── Engagement Metrics
│   ├── Popular Content
│   └── Content Effectiveness
└── 🤖 Chatbot Training
    ├── Q&A Database
    ├── Response Templates
    ├── Learning Algorithms
    └── Performance Tuning
```

#### Callback Request Management
```
📞 Callback Management
├── 📋 Request Queue
│   ├── Priority-based Sorting
│   ├── Request Status Tracking
│   ├── Customer Information
│   └── Request Context
├── 📞 Communication Actions
│   ├── Direct Calling
│   ├── Message Responses
│   ├── Status Updates
│   └── Resolution Tracking
├── 📊 Performance Metrics
│   ├── Response Time Analytics
│   ├── Resolution Rates
│   ├── Customer Satisfaction
│   └── Escalation Tracking
└── 🎯 Follow-up Actions
    ├── Task Assignment
    ├── Reminder Scheduling
    ├── Customer Outreach
    └── Performance Reporting
```

#### Advanced Analytics & Reporting
```
📊 Advanced Analytics
├── 📈 Campaign Performance Analytics
│   ├── Real-time Performance Tracking
│   ├── Audience Segmentation Analysis
│   ├── Conversion Funnel Analytics
│   └── Predictive Campaign Insights
├── 📊 Content Performance Analytics
│   ├── Engagement Metrics & KPIs
│   ├── Audience Demographics
│   ├── Content Effectiveness Scoring
│   └── Optimization Recommendations
├── 📋 Custom Reporting
│   ├── Report Builder Tools
│   ├── Scheduled Report Generation
│   ├── Export & Sharing Options
│   └── Historical Data Analysis
└── 🔮 Predictive Intelligence
    ├── Customer Behavior Prediction
    ├── Churn Risk Assessment
    ├── Upsell Opportunity Identification
    └── Market Trend Analysis
```

## 4. Navigation Hierarchy & User Flows

### 4.1 Customer Navigation (Simplified)

#### Primary Navigation (Bottom Tab Bar - 4-5 tabs max)
1. **🏠 Home** - Dashboard with quick actions
2. **📄 Policies** - Policy management
3. **💬 Chat** - Communication with agent + chatbot
4. **📚 Learn** - Educational content and tutorials
5. **👤 Profile** - Settings and personal info

#### Secondary Navigation (Within each section)
- **Breadcrumb navigation** for deep pages
- **Back buttons** with clear labels
- **Quick action buttons** prominently displayed
- **Search functionality** in every section

### 4.2 Agent Navigation (Feature-Rich but Organized)

#### Primary Navigation (Bottom Tab Bar)
1. **📊 Dashboard** - Business overview
2. **👥 Customers** - Customer management
3. **📈 Analytics** - Performance and ROI
4. **📢 Campaigns** - Marketing tools
5. **👤 Profile** - Agent settings

#### Secondary Navigation (Hamburger Menu)
- **Content Management**
- **Video Library**
- **Customer Support**
- **Settings**
- **Help & Support**

## 5. Content Organization Principles

### 5.1 Information Hierarchy
1. **Critical Information First** - Payment due dates, important alerts
2. **Frequently Used Actions** - Prominent placement
3. **Progressive Disclosure** - Show basic info first, details on demand
4. **Contextual Help** - Help available where needed

### 5.2 Visual Hierarchy
- **Large, clear typography** for elderly users
- **High contrast** for readability
- **Consistent iconography** throughout
- **Color coding** for different information types
- **Generous white space** to reduce clutter

### 5.3 Content Types
- **Static Content** - Policies, documents, educational materials
- **Dynamic Content** - Notifications, messages, alerts
- **Interactive Content** - Calculators, forms, chat
- **Media Content** - Videos, images, documents

## 6. Search & Discovery

### 6.1 Search Functionality
- **Global Search** - Search across all content
- **Filtered Search** - By content type, date, relevance
- **Smart Suggestions** - Based on user behavior
- **Voice Search** - For accessibility

### 6.2 Content Discovery
- **Personalized Recommendations** - Based on user profile and behavior
- **Popular Content** - Trending videos, frequently asked questions
- **Related Content** - Suggested based on current activity
- **Quick Access** - Recently viewed, favorites

## 7. Accessibility Considerations

### 7.1 For Non-Tech-Savvy Users
- **Large touch targets** (minimum 44pt)
- **Simple language** throughout
- **Progressive disclosure** of information
- **Contextual help** and tooltips
- **Consistent navigation patterns**
- **Error prevention** and clear error messages

### 7.2 Technical Accessibility
- **Screen reader compatibility**
- **High contrast mode**
- **Font size adjustment**
- **Voice navigation support**
- **Keyboard navigation** where applicable

## 8. Multitenant Architecture Considerations

### 8.1 Data Isolation
- **Tenant-specific databases** or database schemas
- **Secure API endpoints** with tenant identification
- **Role-based access control** at tenant level
- **Data encryption** at rest and in transit

### 8.2 Customization Options
- **Branding customization** (colors, logos, themes)
- **Feature toggles** for different service levels
- **Content customization** (templates, messaging)
- **Workflow customization** (approval processes, notifications)

This IA provides a comprehensive foundation for building a world-class, user-friendly LIC agent mobile application that serves both non-tech-savvy policyholders and business-focused agents while supporting multiple insurance providers in a scalable multitenant architecture.
