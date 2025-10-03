# Agent Mitra - Wireframes & User Interface Design

## 1. Design Philosophy & Technical Specifications

### 1.1 Mobile-First Design Principles
- **Framework**: Flutter (Cross-platform iOS/Android)
- **Target Devices**: Mobile phones (375x667px minimum, optimized for 414x896px)
- **Touch Targets**: Minimum 48x48pt for all interactive elements
- **Typography**: System fonts with large, clear text for non-tech-savvy users
- **Color Scheme**: CSS-based theming with dark/light modes, accessibility-compliant colors
- **Feature Flags**: All UI elements conditionally rendered based on feature flag status
- **Clutter-Free Design**: Essential information only, secondary features in separate navigation
- **Smart Search**: Sitewide and page-specific search for large content areas

### 1.2 Technical Architecture Integration
```
┌─────────────────────────────────────────────────────────┐
│                 Wireframe Architecture                   │
├─────────────────────────────────────────────────────────┤
│  🎨 Flutter UI Framework                               │
│  ├── Material Design 3.0 (Android)                     │
│  ├── Cupertino Design (iOS)                            │
│  └── Custom Components (Insurance-Specific)             │
├─────────────────────────────────────────────────────────┤
│  🔧 Feature Flag Integration                           │
│  ├── Real-time Flag Checking                           │
│  ├── Conditional Widget Rendering                      │
│  └── Dynamic UI Updates                                │
├─────────────────────────────────────────────────────────┤
│  🌐 Multi-language Support                             │
│  ├── English (Primary)                                 │
│  ├── Hindi (Secondary)                                 │
│  ├── Telugu (Regional)                                 │
│  └── RTL Support (Future Extension)                    │
├─────────────────────────────────────────────────────────┤
│  ♿ Accessibility Features                              │
│  ├── Screen Reader Support                             │
│  ├── High Contrast Mode                                │
│  ├── Font Size Scaling                                 │
│  └── Voice Navigation                                  │
└─────────────────────────────────────────────────────────┘
```

## 2. Authentication & Onboarding Flow

### 2.1 Splash Screen & Initial Load
```
┌─────────────────────────────────────────────────────────┐
│  📱 SPLASH SCREEN                                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎯 AGENT MITRA LOGO (Centered)                  │   │
│  │ 📱 "Friend of Agents"                           │   │
│  │ ⏳ Loading Animation                            │   │
│  └─────────────────────────────────────────────────┘   │
│  🔄 Background: Feature Flag Check & User Validation   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- app_splash_enabled (Must be true to show splash)
- user_authentication_enabled (Controls auth flow)
```

### 2.2 Welcome & Trial Onboarding
```
┌─────────────────────────────────────────────────────────┐
│  🎉 WELCOME SCREEN                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎯 "Welcome to LIC Agent App"                   │   │
│  │ 📝 "Connect with your agent & manage policies"  │   │
│  │ 🎁 "14-Day Free Trial - No Credit Card Required"│   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🚀 GET STARTED (Primary CTA)                    │   │
│  │ 👤 LOGIN (Secondary Option)                      │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- trial_onboarding_enabled (Controls trial flow)
- guest_access_enabled (Allows limited access without signup)
```

### 2.3 Authentication Screens

#### Phone Number Verification
```
┌─────────────────────────────────────────────────────────┐
│  📞 PHONE VERIFICATION                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📱 Enter Your Mobile Number                     │   │
│  │ └───────────────────────────────────────────────┘   │
│  │ +91 │ 9876543210 (Input Field)                  │   │
│  │ 📝 We'll send OTP to verify your number         │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔄 SEND OTP (Button)                            │   │
│  │ ❓ Need Help? (Support Link)                     │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- phone_auth_enabled (Controls phone verification)
- otp_verification_enabled (Controls OTP flow)
```

#### OTP Verification Screen
```
┌─────────────────────────────────────────────────────────┐
│  🔢 OTP VERIFICATION                                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📱 Enter 6-digit code sent to +91-9876543210    │   │
│  │ └───────────────────────────────────────────────┘   │
│  │ [ ] [ ] [ ] [ ] [ ] [ ] (Input Fields)          │   │
│  │ ⏱️ Resend OTP in 00:30                          │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ VERIFY OTP (Button)                          │   │
│  │ 📞 Call Support (Alternative)                    │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- otp_verification_enabled (Must be true for this screen)
```

### 2.4 Trial User Setup
```
┌─────────────────────────────────────────────────────────┐
│  👤 TRIAL USER SETUP                                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎁 14-Day Free Trial Activated                  │   │
│  │ 📅 Trial Ends: DD/MM/YYYY                       │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📝 Basic Profile Setup                          │   │
│  │ 👤 Full Name: [Input]                           │   │
│  │ 📧 Email: [Input]                               │   │
│  │ 🏢 Interested In: [Life Insurance] [Health]     │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🚀 START TRIAL (Button)                         │   │
│  │ 💳 Subscribe Now (Skip Trial)                   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- trial_mode_enabled (Controls trial functionality)
- basic_profile_enabled (Controls profile setup)
```

## 3. Customer Portal Wireframes

### 3.1 Customer Dashboard (Home Screen) - Clutter-Free Design
```
┌─────────────────────────────────────────────────────────┐
│  🏠 CUSTOMER DASHBOARD - AGENT MITRA                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👋 Welcome back, Amit!                          │   │
│  │ 📅 Today: DD MMM YYYY • 🌙 Dark Theme           │   │
│  │ 🔍 Smart Search (Global)                        │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Essential Quick Actions (Priority Section)         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 💳 Pay       │ │ 📞 Contact  │ │ ❓ Get       │      │
│  │  Premium     │ │   Agent     │ │   Quote      │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  📊 Policy Overview (Key Metrics Only)                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📄 Active Policies: 3                           │   │
│  │ 💰 Next Payment: ₹25,000 (15/03/2024)           │   │
│  │ 📈 Total Coverage: ₹15,00,000                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔔 Critical Notifications (Priority-Based)            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔴 Premium due in 3 days                        │   │
│  │ 🟡 Policy renewal reminder                      │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

🎨 Theme Switcher (Top Right Corner)
┌─────────────┐ ┌─────────────┐
│ 🌙 Dark     │ │ ☀️ Light     │
│   Theme     │ │   Theme     │
└─────────────┘ └─────────────┘

🔍 Sitewide Smart Search (Collapsible)
┌─────────────────────────────────────────────────────────┐
│ 🔍 Search policies, agents, documents...               │
│ 💡 Suggestions: "LIC Jeevan Anand", "Premium Payment"   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- customer_dashboard_enabled (Main toggle)
- premium_payments_enabled (Payment actions)
- agent_communication_enabled (Contact features)
- policy_overview_enabled (Policy metrics)
- notifications_enabled (Alert system)
- smart_search_enabled (Global search)
- theme_switcher_enabled (Theme switching)
- localization_enabled (Multi-language support)
```

### 3.2 Policy Details Screen
```
┌─────────────────────────────────────────────────────────┐
│  📄 POLICY DETAILS: LIC Jeevan Anand                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Policies                              │   │
│  │ 🔍 Search • ⋯ More Options                      │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📋 Basic Information                                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🆔 Policy No: 123456789                         │   │
│  │ 📄 Plan: LIC Jeevan Anand (Plan 149)            │   │
│  │ 📅 Start Date: 01/01/2020                       │   │
│  │ ✅ Status: Active                               │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  💰 Premium & Payment                                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💰 Annual Premium: ₹25,000                      │   │
│  │ 📅 Next Due: 15/03/2024                         │   │
│  │ 💳 Payment Method: Auto Debit                   │   │
│  │ 📊 Payment History: [View All]                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  👥 Coverage & Benefits                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💰 Sum Assured: ₹10,00,000                      │   │
│  │ 🎁 Bonus: ₹1,25,000                             │   │
│  │ 📅 Maturity: 01/01/2040                         │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Quick Actions                                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 💳 Pay       │ │ 📄 Download │ │ ❓ Get       │      │
│  │  Premium     │ │  Documents  │ │   Help       │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- policy_details_enabled (Main screen)
- premium_payments_enabled (Payment actions)
- document_access_enabled (Document downloads)
- policy_help_enabled (Help features)
```

### 3.3 Premium Payment Flow
```
┌─────────────────────────────────────────────────────────┐
│  💳 PREMIUM PAYMENT                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Policy Details                        │   │
│  │ 💳 Pay Premium for LIC Jeevan Anand              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  💰 Payment Amount                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💰 Amount Due: ₹25,000                          │   │
│  │ 📅 Due Date: 15/03/2024                         │   │
│  │ 💳 Payment Method: [Saved Cards/UPI/Wallet]      │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  💳 Payment Methods (All Major Indian PSPs)            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 💳 Credit/   │ │ 📱 UPI       │ │ 🏦 Net       │      │
│  │   Debit Card │ │  Payment     │ │  Banking     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📱 PhonePe   │ │ 💳 Razorpay  │ │ 💰 Paytm     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  🔒 Security & Confirmation                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔒 Secure Payment • IRDAI Compliant             │   │
│  │ 💳 Auto-save card for future payments           │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Action Buttons                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💳 PAY NOW (₹25,000) (Primary CTA)              │   │
│  │ 📞 Contact Agent (Secondary)                     │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- premium_payments_enabled (Main feature)
- payment_gateway_integration_enabled (Payment options)
- card_auto_save_enabled (Card saving feature)
- payment_security_enabled (Security features)
```

### 3.4 WhatsApp Integration Screen
```
┌─────────────────────────────────────────────────────────┐
│  💬 WHATSAPP INTEGRATION                               │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Chat                                  │   │
│  │ 💬 Chat with Agent: Rajesh Kumar                │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  💬 Message Thread                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👤 Rajesh Kumar (Online)                        │   │
│  │ 💬 "Your renewal is due on 15th March..."      │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📝 Quick Message Templates                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💬 "Need help with premium payment"             │   │
│  │ 💬 "Please send policy document"                │   │
│  │ 💬 "Want to know about new plans"               │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📱 WhatsApp Business API Integration                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔗 Direct WhatsApp Chat                         │   │
│  │ 📋 Pre-filled Context Sharing                   │   │
│  │ 🤖 Smart Response Suggestions                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Action Buttons                                     │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │ 💬 Send      │ │ 📞 Call       │                     │
│  │  Message     │ │  Agent        │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- whatsapp_integration_enabled (Main feature)
- whatsapp_business_api_enabled (API integration)
- smart_templates_enabled (Template system)
- agent_contact_enabled (Contact features)
```

### 3.5 Smart Chatbot Interface
```
┌─────────────────────────────────────────────────────────┐
│  🤖 SMART ASSISTANT                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Chat                                  │   │
│  │ 🤖 Policy Assistant - How can I help?           │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  💬 Chat Interface                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👤 You: "How do I pay my premium?"              │   │
│  │ 🤖 Bot: "Here's how to pay your premium:"       │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📚 Knowledge Base Integration                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📋 Step 1: Go to Policies → Select Policy       │   │
│  │ 📋 Step 2: Click 'Pay Premium' button           │   │
│  │ 📋 Step 3: Choose payment method                │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎥 Video Tutorial Suggestions                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎬 "Premium Payment Tutorial" (Recommended)     │   │
│  │ ⏱️ 5:32 min • 👁️ 2,543 views                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🆘 Smart Help Options                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 💬 Continue  │ │ 📞 Call      │ │ ❓ Get       │      │
│  │   Chat       │ │   Agent      │ │   Human     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- chatbot_assistance_enabled (Main feature)
- knowledge_base_enabled (FAQ system)
- video_tutorials_enabled (Video suggestions)
- human_escalation_enabled (Agent transfer)
```

### 3.6 Video Learning Center
```
┌─────────────────────────────────────────────────────────┐
│  📚 LEARNING CENTER                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Home                                  │   │
│  │ 📚 Educational Content & Tutorials              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎓 Featured Content (YouTube Integration)             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎥 "How to Pay Premium Online" (Most Popular)   │   │
│  │ ⏱️ 5:32 min • 👁️ 2,543 views • ⭐ 4.8 rating   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📂 Categories (Organized Learning)                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 🎓 Insurance │ │ 💰 Money     │ │ 📋 Policy    │      │
│  │   Basics     │ │ Management  │ │ Management   │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  🆕 Recent Additions (Agent-Uploaded Content)          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📅 "Tax Benefits of LIC Policies" (2 days ago)  │   │
│  │ 👤 Uploaded by: Rajesh Kumar (Your Agent)       │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Learning Analytics (Progress Tracking)            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📈 Videos Watched: 15 • ⏱️ Total Time: 8.5 hours│   │
│  │ 🎯 Learning Streak: 7 days • 📚 Next: Claims    │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Quick Actions                                      │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │ ▶️ Continue   │ │ 📚 Browse     │                     │
│  │   Learning    │ │   All Videos  │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- learning_center_enabled (Main feature)
- video_tutorials_enabled (Video content)
- youtube_integration_enabled (YouTube API)
- learning_analytics_enabled (Progress tracking)
- agent_content_enabled (Agent uploads)
```

## 4. Agent Portal Wireframes

### 4.1 Agent Dashboard
```
┌─────────────────────────────────────────────────────────┐
│  📊 AGENT DASHBOARD                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👋 Good morning, Rajesh!                        │   │
│  │ 📊 Business Overview • 📅 DD MMM YYYY           │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Key Performance Indicators                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 💰 Monthly   │ │ 👥 Active    │ │ 📈 Renewal  │      │
│  │  Revenue     │ │  Customers   │ │  Rate       │      │
│  │ ₹2,45,000    │ │   342        │ │   94.2%     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  📈 Trend Charts (6-Month Overview)                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📈 Revenue Trend • 👥 Customer Growth           │   │
│  │ 📊 Policy Sales • 💹 ROI Performance            │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Priority Action Items                              │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔴 5 premium payments overdue                   │   │
│  │ 🟡 12 customers need renewal reminder           │   │
│  │ 🟢 8 customers eligible for new products        │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🚨 Alerts & Notifications                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ⚠️ Policy lapse warning: Customer ABC           │   │
│  │ 📢 New product launch: LIC Tech Term            │   │
│  │ 💼 Commission update: ₹15,000 credited          │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Quick Actions                                      │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 👥 Manage    │ │ 📊 View      │ │ 📢 Create    │      │
│  │  Customers   │ │  Analytics   │ │  Campaign    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- agent_dashboard_enabled (Main dashboard)
- kpi_metrics_enabled (Performance indicators)
- trend_analytics_enabled (Chart visualizations)
- action_items_enabled (Priority queue)
- alerts_notifications_enabled (Alert system)
- customer_management_enabled (Customer tools)
- roi_analytics_enabled (Revenue tracking)
- marketing_campaigns_enabled (Campaign tools)
```

### 4.2 Customer Management Screen
```
┌─────────────────────────────────────────────────────────┐
│  👥 CUSTOMER MANAGEMENT                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Dashboard                             │   │
│  │ 👥 Manage Your Customers • 🔍 Search & Filter   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  👥 Customer Overview Cards                            │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ Total        │ │ High Value   │ │ At Risk      │      │
│  │ Customers    │ │ Customers    │ │ Customers    │      │
│  │   342        │ │   45         │ │   12         │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  👤 Customer List (Advanced CRM View)                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👤 Amit Sharma • 📄 3 Policies • 💰 ₹75,000/yr  │   │
│  │ 📞 +91-9876543210 • ⭐ Engagement: 8.5/10       │   │
│  │ 📅 Last Contact: 2 days ago • 🎯 Next Action    │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👤 Priya Patel • 📄 2 Policies • 💰 ₹50,000/yr  │   │
│  │ 📞 +91-8765432109 • ⚠️ Payment Overdue         │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Customer Segmentation                              │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📈 High      │ │ 💰 Medium    │ │ 🎯 Low       │      │
│  │  Value       │ │  Value       │ │  Value       │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  📞 Communication Tools                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📧 Bulk      │ │ 💬 WhatsApp  │ │ 📊 Analyze   │      │
│  │  Email       │ │  Campaign    │   Segments    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  🎯 Quick Actions                                      │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │ ➕ Add        │ │ 📞 Contact    │                     │
│  │  Customer     │ │  Selected     │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- customer_management_enabled (Main feature)
- advanced_crm_enabled (CRM capabilities)
- customer_segmentation_enabled (Segmentation tools)
- bulk_communication_enabled (Mass messaging)
- customer_analytics_enabled (Customer insights)
- lead_management_enabled (Lead tracking)
```

### 4.3 ROI Analytics Dashboard
```
┌─────────────────────────────────────────────────────────┐
│  📈 ROI ANALYTICS DASHBOARD                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Dashboard                             │   │
│  │ 📊 Revenue & Performance Analytics              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  💰 Revenue Analytics (Primary Focus)                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💰 Monthly Revenue: ₹2,45,000                   │   │
│  │ 📈 Growth: +15% vs last month                  │   │
│  │ 💹 Commission Rate: 7.5% average                │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Performance Metrics (KPI Cards)                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📈 Conversion│ │ 👥 Retention │ │ 💰 Customer  │      │
│  │   Rate 23%   │ │   Rate 94%   │ │  LTV ₹25K    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  💼 ROI Calculations (Advanced Analytics)              │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📊 Marketing ROI: 340%                          │   │
│  │ ⏱️ Time ROI: ₹450/hour                         │   │
│  │ 👥 Customer Acquisition Cost: ₹2,500            │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔮 Predictive Analytics (AI-Powered Insights)         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔮 Next Month Revenue: ₹2,80,000 (Predicted)    │   │
│  │ 🎯 Upsell Opportunities: 45 customers           │   │
│  │ ⚠️ Churn Risk: 12 customers (High Priority)     │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Interactive Charts (Revenue Trends)                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📈 6-Month Revenue Trend                        │   │
│  │ 📊 Commission Breakdown                         │   │
│  │ 💹 Customer Lifetime Value Analysis             │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Actionable Insights                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💡 "Contact 8 customers for renewal this week"  │   │
│  │ 🎯 "Focus on ULIP products for better commission"│   │
│  │ 📞 "Call high-churn-risk customers immediately" │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Export & Reporting                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📊 Export    │ │ 📋 Custom    │ │ 📈 Schedule  │      │
│  │  Report      │ │  Dashboard   │ │  Reports     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- roi_analytics_enabled (Main feature)
- advanced_analytics_enabled (Advanced metrics)
- predictive_analytics_enabled (AI insights)
- custom_dashboards_enabled (Customizable views)
- automated_reporting_enabled (Scheduled reports)
- revenue_tracking_enabled (Commission tracking)
- performance_metrics_enabled (KPI calculations)
```

### 4.4 Marketing Campaign Builder
```
┌─────────────────────────────────────────────────────────┐
│  📢 MARKETING CAMPAIGN BUILDER                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Campaigns                             │   │
│  │ 📧 Create New Campaign: March Renewal Drive     │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Campaign Setup                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📧 Campaign Name: [Input Field]                 │   │
│  │ 🎯 Target Audience: 150 customers (Due renewal) │   │
│  │ 📅 Schedule: 01/03/2024 - 15/03/2024           │   │
│  │ 💰 Budget: ₹5,000                              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📧 Message Builder (Drag & Drop Editor)              │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📝 Subject: "Your Policy Renewal is Due!"       │   │
│  │ 💬 Message Content: [Rich Text Editor]          │   │
│  │ 🖼️ Add Images/Videos • 📊 Add Personalization  │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  👥 Audience Segmentation                              │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👤 Customer Segments:                           │   │
│  │   • High Value (AOV > ₹5,000)                  │   │
│  │   • Regular Payers (100% payment history)       │   │
│  │   • New Customers (< 6 months)                  │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Campaign Preview & Testing                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👁️ Preview Message • 🧪 Send Test              │   │
│  │ 📊 A/B Testing Options • 🎯 Performance Goals   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🚀 Campaign Launch                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📈 Real-time Performance Tracking              │   │
│  │   • Sent: 150 • Delivered: 142 • Opened: 89    │   │
│  │   • Clicked: 34 • Converted: 23 • ROI: 900%    │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Action Buttons                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 💾 Save      │ │ 🧪 Test      │ │ 🚀 Launch    │      │
│  │  Draft       │ │  Campaign    │ │  Campaign    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- marketing_campaigns_enabled (Main feature)
- campaign_builder_enabled (Builder interface)
- audience_segmentation_enabled (Segmentation tools)
- ab_testing_enabled (Testing capabilities)
- real_time_analytics_enabled (Live tracking)
- personalization_enabled (Dynamic content)
- template_library_enabled (Pre-built templates)
```

### 4.5 Content Management (Video Upload)
```
┌─────────────────────────────────────────────────────────┐
│  📚 CONTENT MANAGEMENT                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Dashboard                             │   │
│  │ 📚 Manage Videos & Educational Content           │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎥 Video Library Overview                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📊 Total Videos: 47 • 👁️ Total Views: 15,240   │   │
│  │ ⏱️ Avg Watch Time: 4:32 min • ⭐ Avg Rating: 4.6│   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  ➕ Upload New Video                                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📹 Select Video File (Drag & Drop)             │   │
│  │ 📝 Video Title: [Input]                         │   │
│  │ 📂 Category: [Policy Management] [Product Info] │   │
│  │ 📝 Description: [Rich Text Editor]              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎬 Video Management Grid                              │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎥 Premium Payment Guide • ⏱️ 5:32 • 👁️ 2,543  │   │
│  │ 📅 Uploaded: 15/02/2024 • ⭐ 4.8 rating         │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎥 Understanding Your Policy • ⏱️ 8:15 • 👁️ 1,890│   │
│  │ 📅 Uploaded: 10/02/2024 • ⭐ 4.7 rating         │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Content Analytics                                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📈 Top Performing Videos                        │   │
│  │ 💡 Customer Engagement Insights                 │   │
│  │ 🎯 Content Effectiveness Metrics                │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🤖 Chatbot Training Interface                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🤖 Manage Q&A Database                          │   │
│  │ 📚 Add New Questions & Answers                  │   │
│  │ 🎥 Link Related Videos                          │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Management Actions                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ ➕ Upload    │ │ 📊 Analytics │ │ 🤖 Train     │      │
│  │  Video       │ │             │ │  Chatbot     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- content_management_enabled (Main feature)
- video_upload_enabled (Video upload capability)
- content_analytics_enabled (Performance tracking)
- chatbot_training_enabled (Q&A management)
- youtube_integration_enabled (YouTube API)
- agent_content_enabled (Agent-specific content)
```

## 5. Trial Expiration & Subscription Flow

### 5.1 Trial Expiration Screen
```
┌─────────────────────────────────────────────────────────┐
│  ⏰ TRIAL EXPIRED                                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ⏱️ Your 14-day trial has ended                 │   │
│  │ 📅 Trial Ended: DD/MM/YYYY                     │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🚫 Access Restricted                                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🚫 Dashboard access disabled                    │   │
│  │ 🚫 Policy management disabled                   │   │
│  │ 🚫 Agent communication disabled                 │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  💳 Subscription Options                               │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👥 Policyholder Plan: ₹199/month               │   │
│  │   • Full policy management                      │   │
│  │   • Premium payment access                      │   │
│  │   • 24/7 chatbot support                        │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 💼 Agent Plan: ₹999/month                       │   │
│  │   • Complete CRM system                         │   │
│  │   • Advanced analytics & ROI                    │   │
│  │   • Marketing campaign tools                    │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Subscription Actions                               │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │ 💳 Subscribe │ │ 📞 Contact   │                     │
│  │   Now        │ │   Sales      │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- subscription_management_enabled (Subscription flow)
- trial_mode_enabled (Trial functionality)
- payment_gateway_integration_enabled (Payment processing)
```

## 6. Cross-Platform & Accessibility Features

### 6.1 Mobile-Specific Optimizations
- **Touch-Friendly**: 48pt minimum touch targets
- **Thumb Navigation**: Bottom tab bar for easy thumb access
- **Gesture Support**: Swipe gestures for navigation
- **Offline Mode**: Critical features work without internet

### 6.2 Multi-Language Interface
```
┌─────────────────────────────────────────────────────────┐
│  🌐 Language Selector (Settings)                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🌐 Current Language: English                    │   │
│  │ 📝 Available: English • हिन्दी • తెలుగు           │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  RTL Support (Future Extension)                       │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ↔️ RTL Layout Support for Arabic/Urdu           │   │
│  │ 📱 Right-to-Left Navigation                     │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- multi_language_enabled (Language switching)
- rtl_support_enabled (RTL layout)
```

### 6.3 Accessibility Features
```
┌─────────────────────────────────────────────────────────┐
│  ♿ Accessibility Settings                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📏 Font Size: [Small] [Medium] [Large] [XL]     │   │
│  │ 🎨 High Contrast Mode: [On] [Off]               │   │
│  │ 🔊 Screen Reader: [Enabled] [Disabled]          │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  Voice Navigation Support                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎤 Voice Commands: "Open policies"              │   │
│  │ 🎤 Voice Search: "Find LIC Jeevan Anand"        │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- accessibility_features_enabled (Accessibility options)
- voice_navigation_enabled (Voice features)
- high_contrast_mode_enabled (Visual accessibility)
- font_scaling_enabled (Text size adjustment)
```

## 7. Feature Flag Integration in Wireframes

### 7.1 Dynamic UI Rendering Example
```dart
// Flutter implementation example
class CustomerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<bool>(
        future: FeatureFlagService.isFeatureEnabled('customer_dashboard_enabled'),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!) {
            return TrialExpiredScreen(); // Feature disabled
          }

          return Column(
            children: [
              // Dashboard content - only shown if feature is enabled
              if (FeatureFlagService.isFeatureEnabledSync('premium_payments_enabled'))
                PaymentActionsWidget(),
              if (FeatureFlagService.isFeatureEnabledSync('policy_overview_enabled'))
                PolicyOverviewWidget(),
              if (FeatureFlagService.isFeatureEnabledSync('notifications_enabled'))
                NotificationsWidget(),
            ],
          );
        },
      ),
    );
  }
}
```

### 7.2 Real-Time Feature Flag Updates
```
┌─────────────────────────────────────────────────────────┐
│  🔄 Feature Flag Update System                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔄 Background Service: Checks every 5 minutes   │   │
│  │ 📡 API Polling: feature_flags/update            │   │
│  │ 💾 Local Cache: Updated flag values             │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Super Admin Control Panel                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎛️ Feature Flag Dashboard                      │   │
│  │ 📊 Real-time Usage Analytics                    │   │
│  │ 👥 Role-Based Flag Assignment                   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

These wireframes provide a comprehensive blueprint for the Flutter-based LIC agent mobile app, incorporating all the specified requirements including feature flag integration, multi-language support, WhatsApp Business API integration, YouTube video hosting, comprehensive payment gateway support, and advanced AI/ML capabilities. Each screen is designed with non-tech-savvy users in mind while providing powerful tools for insurance agents.

**Ready for your review! Please let me know if you'd like me to proceed with the next deliverables or make any adjustments to these wireframe designs.**
