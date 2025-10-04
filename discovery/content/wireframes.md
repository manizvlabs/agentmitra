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

> **🚫 DEFERRED IMPLEMENTATION**: This feature is currently deferred as LIC (Life Insurance Corporation) does not allow third-party applications to accept premium payments on behalf of policyholder customers. Agent Mitra App cannot implement direct premium payment collection functionality at this time. Instead, users will be guided to make payments through official LIC channels.

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

### 3.7 Data Pending Screen (Agent Upload Required)
```
┌─────────────────────────────────────────────────────────┐
│  📊 DATA PENDING - AGENT UPLOAD REQUIRED               │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Home                                  │   │
│  │ 📊 Your Policy Data is Being Prepared            │   │
│  │ 👤 Agent Upload Required                          │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📋 Current Status                                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ⏳ Your agent needs to upload your policy data   │   │
│  │ 📊 Data includes: Policies, Premiums, Documents │   │
│  │ 📞 Once uploaded, you'll see full policy details │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📞 Agent Contact Options                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📞 Call      │ │ 💬 WhatsApp │ │ 📧 Email     │      │
│  │  Agent       │ │  Message    │ │  Agent       │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  ℹ️ What to Expect                                       │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📄 You'll see all your LIC policies            │   │
│  │ 💳 Premium payment options                      │   │
│  │ 📊 Policy performance analytics                 │   │
│  │ 📋 Document access and downloads               │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔔 Notification Settings                               │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔔 Notify me when data is available            │   │
│  │ 📱 Push notification enabled                    │   │
│  │ 📧 Email notification enabled                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Limited Features Available                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Agent Communication                            │   │
│  │ ✅ Educational Content                            │   │
│  │ ✅ Smart Assistant Chatbot                        │   │
│  │ 🚫 Policy Details (Until data uploaded)          │   │
│  │ 🚫 Premium Payments (Until data uploaded)        │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- data_pending_enabled (Pending state display)
- agent_contact_enabled (Contact options)
- limited_features_enabled (Partial app access)
- notification_settings_enabled (Status updates)
```

### 3.8 Agent Discovery Screen (Find Your Agent)
```
┌─────────────────────────────────────────────────────────┐
│  🔍 FIND YOUR INSURANCE AGENT                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Profile Setup                        │   │
│  │ 👤 Help Us Find Your LIC Agent                   │   │
│  │ 📞 Connect with the Right Agent                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔍 Search Methods                                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 1️⃣ Policy Document Search                       │   │
│  │ 📄 Look for agent name/code on your policy      │   │
│  │ 📝 Enter agent details below                     │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 2️⃣ LIC Customer Care                             │   │
│  │ 📞 Call LIC helpline: 1800-XXX-XXXX             │   │
│  │ 🆔 Provide your policy number                    │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 3️⃣ Online Directory Search                      │   │
│  │ 🌐 Search LIC agent directory online            │   │
│  │ 📍 Find agents in your area                     │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  👤 Agent Information Form                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👤 Agent Name: [Input Field]                   │   │
│  │ 🆔 Agent Code: [Input Field]                   │   │
│  │ 📞 Agent Phone: [Input Field]                  │   │
│  │ 📧 Agent Email: [Input Field] (Optional)       │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔍 Alternative Search                                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👥 Ask Other Policyholders                        │   │
│  │ 📱 Contact fellow customers in your area         │   │
│  │ 💬 Local insurance community groups              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Action Buttons                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ ✅ Verify    │ │ 🔄 Search   │ │ 📞 Call     │      │
│  │  Agent       │ │  Online     │ │  Support    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- agent_discovery_enabled (Agent finding tools)
- policy_document_search_enabled (Document-based search)
- lic_helpline_enabled (Support contact)
- online_directory_enabled (Web search)
- agent_verification_enabled (Agent validation)
```

### 3.9 Agent Verification Screen
```
┌─────────────────────────────────────────────────────────┐
│  ✅ AGENT VERIFICATION                                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Agent Discovery                      │   │
│  │ ✅ Verifying Agent Identity                     │   │
│  │ 🔒 Secure Agent Authentication                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  👤 Agent Details to Verify                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👤 Name: Rajesh Kumar                            │   │
│  │ 🆔 Agent Code: LIC-ABC123                        │   │
│  │ 📞 Phone: +91-9876543210                         │   │
│  │ 📧 Email: rajesh.kumar@lic.com                   │   │
│  │ 🏢 Branch: LIC Mumbai Central                    │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔍 Verification Methods                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📞 Direct Call to Agent                          │   │
│  │ 🔗 Agent will confirm your identity              │   │
│  │ 📋 You'll receive verification code              │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📧 Email Verification                            │   │
│  │ 📬 Agent receives verification request           │   │
│  │ ✅ Agent approves connection                     │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔄 Verification Status                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ⏳ Sending verification request...              │   │
│  │ 📞 Calling agent for confirmation...            │   │
│  │ ✅ Agent confirmed! Connection established       │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Next Steps                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📤 Agent will upload your policy data           │   │
│  │ 📱 You'll receive data available notification   │   │
│  │ 🚀 Full app features will be unlocked           │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Action Buttons                                     │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │ 📞 Call      │ │ 🔄 Try       │                     │
│  │  Agent       │ │  Again       │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- agent_verification_enabled (Verification process)
- direct_call_enabled (Phone verification)
- email_verification_enabled (Email-based auth)
- agent_data_upload_enabled (Data import trigger)
```

### 3.10 Document Upload & Verification
```
┌─────────────────────────────────────────────────────────┐
│  📄 DOCUMENT VERIFICATION                              │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Profile Setup                        │   │
│  │ 📄 Upload Identity Documents                     │   │
│  │ 🔒 KYC Verification Required                     │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📋 Required Documents                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🆔 Government ID (Choose One)                   │   │
│  │ • Aadhaar Card • Voter ID • Driving License      │   │
│  │ • Passport                                       │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📸 Recent Photo (Selfie)                        │   │
│  │ • Clear face photo • Well-lit environment       │   │
│  │ • No sunglasses or hats                          │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📤 Upload Process                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 1️⃣ Select Document Type                        │   │
│  │ 2️⃣ Take Photo or Choose from Gallery           │   │
│  │ 3️⃣ OCR Processing (Automatic)                  │   │
│  │ 4️⃣ Manual Verification if needed               │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Upload Status                                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📄 Aadhaar   │ │ 📸 Selfie    │ │ 🔍 Address   │      │
│  │ ✅ Uploaded  │ │ ✅ Uploaded  │ │ 🔄 Processing│      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  🔍 OCR Results & Validation                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Name: Amit Sharma (Matched)                  │   │
│  │ ✅ DOB: 15/03/1985 (Matched)                    │   │
│  │ ✅ Address: Auto-filled from document           │   │
│  │ ⚠️ Manual review may be required               │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Action Buttons                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📷 Take      │ │ 📁 Choose   │ │ ✅ Submit   │      │
│  │  Photo       │ │  File       │ │  for        │      │
│  │              │ │             │ │  Review      │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- document_upload_enabled (Upload functionality)
- ocr_processing_enabled (Automatic text recognition)
- document_validation_enabled (Verification checks)
- selfie_verification_enabled (Photo verification)
- manual_review_enabled (Human verification)
```

### 3.11 KYC Verification Status
```
┌─────────────────────────────────────────────────────────┐
│  🔍 KYC VERIFICATION STATUS                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Document Upload                       │   │
│  │ 🔍 Know Your Customer Verification               │   │
│  │ 📊 Verification Progress                          │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📋 Verification Checklist                              │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Identity Document: Aadhaar Card              │   │
│  │ ✅ Selfie Verification: Completed               │   │
│  │ ✅ Address Verification: Completed              │   │
│  │ 🔄 Database Verification: In Progress           │   │
│  │ ⏳ Manual Review: Pending                        │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Current Status                                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔄 Processing your documents...                 │   │
│  │ ⏱️ Estimated completion: 2-3 business days      │   │
│  │ 📧 You'll receive email notification            │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  ℹ️ What Happens Next?                                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Approved: Full app access unlocked           │   │
│  │ ⚠️ Additional Info Needed: We'll contact you    │   │
│  │ ❌ Rejected: Reason provided with appeal option │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔔 Notification Preferences                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📱 Push notifications for status updates        │   │
│  │ 📧 Email notifications enabled                   │   │
│  │ 📞 SMS alerts for important updates              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Action Buttons                                     │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │ 📊 Check     │ │ 🏠 Go to     │                     │
│  │  Status      │ │  Home        │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- kyc_verification_enabled (KYC process)
- verification_status_enabled (Status tracking)
- notification_preferences_enabled (Alert settings)
- manual_review_enabled (Human verification)
```

### 3.12 Emergency Contact Setup
```
┌─────────────────────────────────────────────────────────┐
│  🚨 EMERGENCY CONTACT SETUP                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Profile Setup                        │   │
│  │ 🚨 Add Emergency Contact                          │   │
│  │ 👥 Someone to Contact in Case of Emergency        │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  👤 Emergency Contact Details                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👤 Full Name: [Input Field]                     │   │
│  │ 📞 Phone Number: [Input Field]                  │   │
│  │ 👨‍👩‍👧 Relationship: [Dropdown]                 │   │
│  │   • Spouse • Parent • Sibling • Child • Friend   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📍 Address Information (Optional)                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🏠 Same as my address                            │   │
│  │ 📝 Or enter different address:                   │   │
│  │ [Address Input Fields]                           │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  ℹ️ Why Emergency Contact?                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🚨 Claim Processing: Contact for verification    │   │
│  │ 💸 Premium Issues: Payment confirmations         │   │
│  │ 📞 Policy Changes: Authorization required        │   │
│  │ 🏥 Critical Illness: Immediate notification      │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔒 Privacy & Security                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔐 Information is encrypted and secure          │   │
│  │ 📞 Only contacted for policy-related emergencies │   │
│  │ ❌ Never shared with third parties               │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Action Buttons                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ ➕ Add       │ │ ⏭️ Skip      │ │ ✅ Save     │      │
│  │  Another     │ │  for Now    │ │  Contact    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- emergency_contact_enabled (Contact setup)
- relationship_types_enabled (Relationship options)
- address_sharing_enabled (Address options)
- privacy_protection_enabled (Security features)
```

## 3.13 Agent Mitra Config Portal/Website Wireframes

> **Note**: The Agent Mitra Config Portal/Website is a separate web-based configuration system for agents to manage customer data imports from LIC systems. This is distinct from the Agent Mitra mobile app screens and serves as an administrative tool for data management.

### 3.13.1 Agent Configuration Portal Dashboard
```
┌─────────────────────────────────────────────────────────┐
│  🏗️ AGENT CONFIGURATION PORTAL - DATA MANAGEMENT       │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Agent Mitra Config Portal/Website   │   │
│  │ 👥 Customer Data Management                    │   │
│  │ 📊 Import Status Overview                      │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Import Statistics (Top Metrics)                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ Total       │ │ Successful  │ │ Failed      │      │
│  │ Imports     │ │ Imports     │ │ Imports     │      │
│  │   1,247     │ │   1,189     │ │   58        │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  🔄 Recent Import Activity                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📅 March 15, 2024 - Customer Batch Import      │   │
│  │ ✅ 150 records • 2 errors • 5 min ago         │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📅 March 14, 2024 - Policy Update Import       │   │
│  │ ⚠️ 89 records • 12 errors • Processing...      │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Quick Actions                                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📤 Upload   │ │ 📊 View     │ │ 📋 Download │      │
│  │  New Data   │ │  Reports    │ │  Template   │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  📋 Data Management Actions                            │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │ 🔍 Search   │ │ 📈 Analytics │                     │
│  │  Records    │ │             │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- agent_configuration_portal_enabled (Main feature)
- data_import_enabled (Import functionality)
- import_analytics_enabled (Statistics display)
- bulk_operations_enabled (Batch operations)
```

### 3.13.3 Excel File Upload & Validation
```
┌─────────────────────────────────────────────────────────┐
│  📤 EXCEL DATA UPLOAD - AGENT MITRA                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Portal Dashboard                      │   │
│  │ 📤 Upload Customer Excel Data                   │   │
│  │ 📋 File Validation & Processing                 │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📁 File Selection                                     │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📎 Drag & drop Excel file here                 │   │
│  │    or click to browse                          │   │
│  │ 📄 Supported: .xlsx, .xls (Max 50MB)          │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔍 File Validation Results                            │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ File Format: Valid Excel (.xlsx)            │   │
│  │ ✅ File Size: 2.3MB (Within limit)             │   │
│  │ ⚠️  Column Headers: 3 missing, 2 incorrect     │   │
│  │ 📊 Total Records: 1,250 customers              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📋 Column Mapping (Expandable)                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Customer_ID → ✓ Matched                         │   │
│  │ Full_Name → ✓ Matched                           │   │
│  │ Policy_Number → ❌ Missing                      │   │
│  │ Premium_Amount → ❌ Incorrect name              │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Upload Actions                                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📤 Upload   │ │ 📋 Download │ │ 🔄 Retry    │      │
│  │  File       │ │  Template   │ │  Upload     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- file_upload_enabled (Upload functionality)
- file_validation_enabled (Validation features)
- column_mapping_enabled (Mapping tools)
- template_download_enabled (Template access)
```

### 3.13.4 Data Import Progress & Results
```
┌─────────────────────────────────────────────────────────┐
│  🔄 DATA IMPORT PROGRESS - AGENT MITRA                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Upload Screen                         │   │
│  │ 🔄 Importing Customer Data                       │   │
│  │ 📊 Real-time Progress Tracking                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📈 Import Progress                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ⏳ Processing Records...                          │   │
│  │ ████████░░░░░░░░░░░░ 320/1250 (25%)             │   │
│  │ ⏱️  Estimated time: 8 minutes remaining         │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Live Statistics                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ ✅ Success  │ │ ⚠️  Errors   │ │ 🔄 Pending  │      │
│  │   285       │ │   15        │ │   965       │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  📋 Current Activity                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔄 Creating customer records...                 │   │
│  │ ✅ Policy data validation complete              │   │
│  │ ⚠️  Duplicate customer found - merging...       │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Import Controls                                    │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │ ⏸️  Pause    │ │ 🛑 Cancel   │                     │
│  │  Import     │ │  Import     │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- import_progress_enabled (Progress tracking)
- real_time_updates_enabled (Live statistics)
- import_controls_enabled (Pause/cancel options)
```

### 3.13.5 Import Error Review & Resolution
```
┌─────────────────────────────────────────────────────────┐
│  ⚠️ IMPORT ERRORS - REVIEW & RESOLVE                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Progress Screen                        │   │
│  │ ⚠️ Data Import Issues Found                       │   │
│  │ 🔧 Error Resolution Required                      │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Error Summary                                       │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ❌ Total Errors: 35 (2.8% of records)           │   │
│  │ 📋 Most Common: Missing phone numbers           │   │
│  │ ⚠️  Critical: 5 invalid policy numbers          │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📋 Error Details (Filterable List)                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔴 Row 125: Invalid phone number format        │   │
│  │ 🔴 Row 234: Policy number already exists        │   │
│  │ 🟡 Row 345: Missing email address (optional)    │   │
│  │ 🔴 Row 456: Invalid date format                 │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🔧 Resolution Options                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🛠️ Fix Errors in Excel & Re-upload             │   │
│  │ 📤 Skip Errors & Continue Import                │   │
│  │ 📋 Download Error Report                        │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Impact Assessment                                  │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📈 If skipped: 1,215 records will import        │   │
│  │ ⚠️  Data quality may be affected                │   │
│  │ 💡 Recommendation: Fix critical errors first    │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Resolution Actions                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📤 Re-upload │ │ ⏭️ Skip     │ │ 📊 Report   │      │
│  │  Fixed File  │ │  Errors     │ │  Details    │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- error_handling_enabled (Error processing)
- error_reporting_enabled (Error details)
- import_recovery_enabled (Resolution options)
```

### 3.13.6 Import Success Confirmation
```
┌─────────────────────────────────────────────────────────┐
│  ✅ IMPORT COMPLETED - SUCCESS                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ← Back to Portal Dashboard                      │   │
│  │ ✅ Data Import Successful                        │   │
│  │ 📊 Customer Data Now Available                   │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎉 Success Summary                                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Total Records Imported: 1,215                │   │
│  │ 👥 New Customers: 234                           │   │
│  │ 📄 Updated Policies: 981                        │   │
│  │ ⏱️  Processing Time: 12 minutes                 │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  📊 Data Quality Metrics                               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 📈 Accuracy │ │ 🔄 Updates  │ │ ⚠️  Issues   │      │
│  │   97.2%     │ │   85%       │ │   2.8%      │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  📱 Mobile App Sync Status                             │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔄 Syncing data to customer mobile apps...      │   │
│  │ 👥 1,215 customers will receive notifications   │   │
│  │ 📱 Data available in apps within 5 minutes      │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Next Steps                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📊 View import analytics                         │   │
│  │ 📋 Download success report                       │   │
│  │ 📞 Contact customers about new data              │   │
│  │ 📤 Upload more customer data                     │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  🎯 Success Actions                                    │
│  ┌─────────────┐ ┌─────────────┐                     │
│  │ 📊 View      │ │ 📤 Upload    │                     │
│  │  Analytics   │ │  More Data  │                     │
│  └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- import_success_enabled (Success confirmation)
- mobile_sync_enabled (App synchronization)
- import_analytics_enabled (Success metrics)
- success_reporting_enabled (Reports and next steps)
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
│  🎛️ Super Admin Control Panel                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎛️ Feature Flag Dashboard                      │   │
│  │ 📊 Real-time Usage Analytics                    │   │
│  │ 👥 Role-Based Flag Assignment                   │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

These wireframes provide a comprehensive blueprint for the Flutter-based LIC agent mobile app, incorporating all the specified requirements including feature flag integration, multi-language support, WhatsApp Business API integration, YouTube video hosting, comprehensive payment gateway support, and advanced AI/ML capabilities. Each screen is designed with non-tech-savvy users in mind while providing powerful tools for insurance agents.

**Ready for your review! Please let me know if you'd like me to proceed with the next deliverables or make any adjustments to these wireframe designs.**
