# LIC Agent Mobile App - Content Structure & Information Hierarchy

## 1. Content Strategy Overview

### 1.1 Content Philosophy
- **User-Centric Approach**: Content designed for non-tech-savvy users with clear, simple language
- **Progressive Disclosure**: Information revealed gradually based on user needs and context
- **Action-Oriented**: Every piece of content should drive toward a specific user goal
- **Multilingual Support**: Primary content in English and Hindi, expandable to other regional languages

### 1.2 Content Types Matrix

| Content Type | Customer Portal | Agent Portal | Provider Portal | Admin Panel |
|-------------|----------------|--------------|-----------------|-------------|
| **Static Content** | Policy docs, FAQs, Educational content | Business docs, Training materials | Product specs, Legal docs | System docs, Guidelines |
| **Dynamic Content** | Notifications, Messages, Alerts | Customer updates, Performance data | Agent notifications, System alerts | User notifications, System status |
| **Interactive Content** | Calculators, Forms, Chat | Dashboards, Reports, Tools | Management interfaces, Analytics | Admin tools, Configuration panels |
| **Media Content** | Videos, Images, Documents | Marketing materials, Training videos | Product images, Brand assets | System assets, Documentation |
| **Social Content** | Community posts, Reviews | Customer testimonials, Case studies | Partner communications | Platform announcements |

## 2. Customer Portal Content Structure

### 2.1 Dashboard Content

#### Primary Dashboard Widgets
```
📊 Customer Dashboard Layout

┌─────────────────────────────────────────────────────────┐
│  🎯 Quick Actions (Top Priority Section)               │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 💳 Pay Now  │ │ 📞 Call     │ │ ❓ Get      │      │
│  │             │ │   Agent     │ │   Quote     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│  📊 Policy Overview (Key Metrics)                      │
│  • Active Policies: X • Next Payment: DD/MM/YYYY       │
│  • Total Coverage: ₹X • Maturity: DD/MM/YYYY           │
├─────────────────────────────────────────────────────────┤
│  🔔 Important Notifications (Priority-Based)           │
│  🔴 Payment due in 3 days • Policy renewal pending    │
│  🟡 New product recommendation • Agent message         │
│  🟢 Policy anniversary • Claim approved                │
├─────────────────────────────────────────────────────────┤
│  📈 Quick Insights (Visual Cards)                     │
│  • Premium Payment History • Coverage Utilization     │
│  • Investment Growth • Claim Status                   │
└─────────────────────────────────────────────────────────┘
```

#### Content Hierarchy for Dashboard
1. **Critical Actions** (Payment, Contact) - Always visible
2. **Time-Sensitive Information** (Due dates, alerts) - Prominent placement
3. **Status Information** (Policy counts, coverage) - Secondary prominence
4. **Trend Information** (Growth, history) - Tertiary, collapsible

### 2.2 Policy Management Content

#### Policy Card Structure
```
┌─────────────────────────────────────────────────────────┐
│  📄 Policy Name (LIC Jeevan Anand)                     │
│  🆔 Policy No: 123456789 • Status: ✅ Active           │
│  💰 Annual Premium: ₹25,000 • Next Due: 15/03/2024     │
│  📅 Start Date: 01/01/2020 • Maturity: 01/01/2040      │
│  👥 Nominee: John Doe • Coverage: ₹10,00,000           │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │ 👁 View     │ │ ✏️ Edit     │ │ 💳 Pay      │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘
```

#### Policy Detail Page Structure
```
📋 Policy Details: LIC Jeevan Anand

📋 Basic Information
├── Policy Number: 123456789
├── Plan Name: LIC Jeevan Anand (Plan 149)
├── Issue Date: 01/01/2020
├── Status: Active
└── Agent: Rajesh Kumar (Agent Code: ABC123)

💰 Premium & Payment
├── Annual Premium: ₹25,000
├── Payment Frequency: Annual
├── Next Due Date: 15/03/2024
├── Mode of Payment: Online/Bank
├── Auto-Payment: Enabled
└── Payment History: [View All]

👥 Coverage & Benefits
├── Sum Assured: ₹10,00,000
├── Bonus Accumulated: ₹1,25,000
├── Riders: Critical Illness (₹5,00,000)
├── Maturity Benefit: ₹15,00,000 (approx)
└── Death Benefit: ₹15,00,000

👤 Personal Details
├── Policyholder: Amit Sharma
├── Nominee: Priya Sharma
├── Address: [Complete Address]
└── Contact: [Phone, Email]

📄 Documents
├── Policy Document: [Download]
├── Premium Receipts: [Download All]
├── Bonus Statements: [Download]
└── Tax Certificates: [Download]

🎯 Quick Actions
├── Pay Premium
├── Download Statement
├── Update Nominee
├── File Claim
└── Contact Agent
```

### 2.3 Communication Content Structure

#### Message Thread Design
```
💬 Messages with Agent

┌─────────────────────────────────────────────────────────┐
│  👤 Agent: Rajesh Kumar                          ▲    │
│  💬 Last message: "Your policy renewal is due..."    │
│  🕐 2 hours ago                                      │
├─────────────────────────────────────────────────────────┤
│  📨 Inbox (12 unread)                                 │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 👤 Rajesh Kumar • 2 hours ago                  │  │
│  │ "Your policy renewal is due on 15th March.     │  │
│  │ Would you like me to help with the payment?"    │  │
│  └─────────────────────────────────────────────────┘  │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 👥 System • 1 day ago                           │  │
│  │ "Policy maturity notification sent"             │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

#### WhatsApp Integration Template
```
📱 WhatsApp Integration

🌟 Direct WhatsApp Chat
• One-tap connection to agent's WhatsApp
• Pre-filled context about current policy/query
• Template messages for common scenarios

💬 Quick Templates:
• "Hi, I need help with premium payment"
• "Please send my policy document"
• "I want to know about new plans"
• "Need claim assistance"

🔄 Smart Context Sharing:
• Current policy details
• Recent transactions
• Relevant documents
• Agent's availability status
```

### 2.4 Smart Assistant Content

#### Chatbot Interface Structure
```
🤖 Smart Assistant - Policy Guide

┌─────────────────────────────────────────────────────────┐
│  🤖 Hi! I'm your Policy Assistant. How can I help?     │
│  💡 Quick Suggestions:                               │
│  • Check premium status • Pay premium • Get quote    │
│  • Policy details • File claim • Contact agent       │
├─────────────────────────────────────────────────────────┤
│  💬 Chat History                                      │
│  ┌─────────────────────────────────────────────────┐  │
│  │ 👤 You: "How do I pay my premium?"              │  │
│  │ 🤖 Bot: "Here's how you can pay your premium:"  │  │
│  │ 📋 Step 1: Go to Policies → Select Policy       │  │
│  │ 📋 Step 2: Click 'Pay Premium' button           │  │
│  │ 📋 Step 3: Choose payment method                │  │
│  │ 🎥 Watch Video Tutorial                         │  │
│  └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

#### Knowledge Base Categories
```
📚 Knowledge Base Structure

🎯 Most Asked Questions
├── Payment Related
│   ├── How to pay premium online?
│   ├── What are payment methods?
│   ├── Can I pay partial premium?
│   └── How to set up auto-payment?
├── Policy Related
│   ├── How to check policy status?
│   ├── What is policy maturity?
│   ├── How to change nominee?
│   └── How to get policy documents?
├── Claim Related
│   ├── How to file a claim?
│   ├── What documents needed?
│   ├── How long claim processing takes?
│   └── Claim status check
└── General
    ├── New insurance plans
    ├── Tax benefits
    ├── Investment options
    └── Agent contact

📖 Policy Guides
├── Understanding Your Policy
├── Premium Payment Guide
├── Claim Process Guide
├── Document Requirements
└── Tax Benefits Guide
```

### 2.5 Learning Center Content

#### Video Tutorial Structure
```
🎥 Video Learning Center

📂 Categories
├── 🎓 Insurance Basics
│   ├── What is Life Insurance?
│   ├── Types of Insurance Plans
│   ├── Understanding Premium
│   └── Investment vs Insurance
├── 💰 Money Management
│   ├── Financial Planning
│   ├── Tax Saving Tips
│   ├── Investment Options
│   └── Retirement Planning
├── 📋 Policy Management
│   ├── Understanding Your Policy
│   ├── Premium Payment Process
│   ├── Claim Filing Guide
│   └── Document Management
└── 🆕 New Products
    ├── Latest LIC Plans
    ├── Product Comparison
    ├── Feature Highlights
    └── Enrollment Process

🎬 Featured Videos
├── ⭐ Most Popular: "How to Pay Premium Online" (2.5k views)
├── ⭐ Agent Recommended: "Understanding Your LIC Policy" (1.8k views)
├── ⭐ New Release: "Tax Benefits of LIC Policies" (850 views)

📊 Video Analytics (Agent View)
├── Total Views: 15,240
├── Average Watch Time: 4:32 minutes
├── Completion Rate: 78%
├── Most Popular Category: Policy Management
└── Customer Engagement Score: 8.2/10
```

## 3. Agent Portal Content Structure

### 3.1 Dashboard Content

#### Key Performance Indicators (KPIs)
```
📊 Agent Dashboard

🎯 Primary KPIs (Large Cards)
├── 💰 Monthly Revenue: ₹2,45,000 (+15% vs last month)
├── 👥 Active Customers: 342 (+8 new this month)
├── 📈 Renewal Rate: 94.2% (+2.1% vs last month)
├── 🆕 New Policies Sold: 23 (+5 vs last month)
└── ⭐ Customer Satisfaction: 4.6/5 (+0.2 vs last month)

📈 Trend Charts (Mini Graphs)
├── Revenue Trend (6 months)
├── Customer Growth Trend
├── Renewal Rate Trend
└── Policy Sales Trend

🎯 Action Items (Priority Queue)
├── 🔴 Urgent: 5 premium payments overdue
├── 🟡 Follow-up: 12 customers need renewal reminder
├── 🟢 Opportunity: 8 customers eligible for new products
└── 🔵 Administrative: 3 documents pending approval
```

### 3.2 Customer Management Content

#### Customer Profile Structure
```
👤 Customer Profile: Amit Sharma

📋 Basic Information
├── Name: Amit Sharma • Age: 35
├── Contact: +91-9876543210 • Email: amit@email.com
├── Address: [Complete Address]
├── Customer Since: Jan 2020 • Agent: Rajesh Kumar

📊 Policy Portfolio
├── Total Policies: 3 • Total Premium: ₹75,000/year
├── Active Policies: 3 • Lapsed: 0
├── Total Coverage: ₹35,00,000
└── Lifetime Value: ₹8,50,000 (estimated)

📈 Customer Analytics
├── Engagement Score: 8.5/10
├── Payment Regularity: 100%
├── Query Frequency: 2/month
├── Last Interaction: 2 days ago
└── Risk Profile: Low

💬 Communication History
├── Last Message: "Need help with claim" (2 days ago)
├── Total Messages: 45 • Response Rate: 95%
├── Preferred Channel: WhatsApp
└── Satisfaction Rating: 4.8/5

🎯 Action Items
├── Send renewal reminder (Due: 15/03/2024)
├── Offer new ULIP plan (High potential)
├── Schedule follow-up call
└── Send policy anniversary wishes
```

### 3.3 Analytics & ROI Content

#### ROI Dashboard Structure
```
📈 ROI Analytics Dashboard

💰 Revenue Analytics
├── Commission Earned: ₹2,45,000 (This Month)
│   ├── New Policies: ₹1,25,000 (51%)
│   ├── Renewals: ₹85,000 (35%)
│   └── Other Income: ₹35,000 (14%)
├── Monthly Trend: +15% vs last month
├── Average Policy Value: ₹3,25,000
└── Commission Rate: 7.5% average

📊 Customer Metrics
├── Customer Acquisition Cost: ₹2,500 per customer
├── Customer Lifetime Value: ₹25,000 average
├── Retention Rate: 94.2%
└── Churn Rate: 5.8%

📋 ROI Calculations
├── Marketing ROI: 340% (₹3.40 return per ₹1 spent)
├── Time ROI: ₹450/hour (based on 40h/week)
├── Digital Tools ROI: 280% efficiency improvement
└── Customer Service ROI: 420% satisfaction improvement

🔮 Predictive Analytics
├── Next Month Revenue: ₹2,80,000 (predicted)
├── Renewal Opportunities: 45 customers
├── Upsell Potential: ₹3,50,000
└── Risk Alerts: 12 customers at high churn risk
```

### 3.4 Marketing Campaigns Content

#### Campaign Builder Interface
```
📢 Campaign Builder

🎯 Campaign Setup
├── Campaign Name: "March Renewal Drive"
├── Type: Email + SMS + Push Notification
├── Target Audience: 150 customers (due for renewal)
├── Schedule: 01/03/2024 - 15/03/2024
└── Budget: ₹5,000

📧 Message Content
├── Subject: "Your Policy Renewal is Due - Special Discount!"
├── Content Preview:
│   "Dear [Customer Name],
│
│   Your policy renewal is due on [Due Date].
│   Renew now and get 5% discount!
│
│   Benefits:
│   • Instant renewal confirmation
│   • Digital receipt
│   • Tax benefits
│
│   Click here to renew: [Link]
│
│   Regards,
│   Rajesh Kumar"
└── Personalization: [Customer Name], [Policy Details], [Due Date]

📊 Targeting & Segmentation
├── Customer Segments:
│   ├── High Value Customers (AOV > ₹5,000)
│   ├── Regular Payers (Payment history 100%)
│   ├── New Customers (Joined < 6 months)
│   └── At-Risk Customers (Irregular payments)
├── Geographic Targeting: Mumbai region
├── Age Group: 25-55 years
└── Policy Type: Endowment + ULIP plans

📈 Performance Tracking
├── Sent: 150 • Delivered: 142 • Opened: 89
├── Clicked: 34 • Converted: 23 • Revenue: ₹45,000
├── Open Rate: 63% • Click Rate: 24% • Conversion: 15%
└── ROI: 900% (₹45,000 revenue / ₹5,000 cost)
```

### 3.5 Content Management for Agents

#### Video Upload & Management
```
📚 Agent Content Management

🎥 Video Library Management
├── Upload New Video
│   ├── Title: "How to Pay Premium Online"
│   ├── Category: Policy Management
│   ├── Description: "Step-by-step guide for online premium payment"
│   ├── Tags: payment, online, tutorial, premium
│   ├── Thumbnail: [Auto-generated/Upload]
│   └── Visibility: Public (All customers)
├── Video Analytics
│   ├── Total Views: 2,543
│   ├── Average Watch Time: 4:32 minutes
│   ├── Completion Rate: 78%
│   ├── Most Popular: "Premium Payment Guide"
│   └── Customer Engagement: High
├── Content Categories
│   ├── Policy Management (12 videos)
│   ├── Product Information (8 videos)
│   ├── Claim Process (5 videos)
│   └── Financial Planning (7 videos)

🤖 Chatbot Training Interface
├── Q&A Database Management
│   ├── Add New Q&A Pair
│   │   Question: "How do I pay my premium?"
│   │   Answer: "You can pay through multiple channels..."
│   │   Related Videos: "Premium Payment Tutorial"
│   │   Tags: payment, premium, online
│   ├── Popular Questions
│   │   • "How to check policy status?" (245 queries)
│   │   • "Premium payment methods" (189 queries)
│   │   • "How to file claim?" (156 queries)
│   │   └── "Policy renewal process" (134 queries)
│   └── Response Effectiveness
│       ├── Accuracy Rate: 94.2%
│       ├── Customer Satisfaction: 4.6/5
│       └── Escalation Rate: 5.8%
```

## 4. Content Templates & Standards

### 4.1 Messaging Templates

#### Customer Communication Templates
```
📧 Email Templates

🎯 Renewal Reminder Template
Subject: Your Policy Renewal is Due - [Policy Name]

Dear [Customer Name],

Your [Policy Name] (Policy No: [Policy Number]) is due for renewal on [Due Date].

Benefits of timely renewal:
• Continue coverage without break
• Avail tax benefits under Section 80C
• Maintain bonus accumulation
• No medical check-up required

Renew now: [Renewal Link]

Best regards,
[Agent Name]
[Agent Contact]

📱 SMS Templates

🎯 Payment Reminder
"[Customer Name], your premium of ₹[Amount] for policy [Policy No] is due on [Date]. Pay now to avoid lapse: [Payment Link] - [Agent Name]"

🎯 Policy Anniversary
"Happy Policy Anniversary [Customer Name]! Your [Policy Name] completes [X] years today. Thank you for your trust! - [Agent Name]"

🔔 Push Notification Templates

🎯 Payment Due
"⏰ Premium payment due in 3 days for your [Policy Name] policy"

🎯 New Product
"🆕 New [Product Name] launched! Get better returns and coverage. Contact me for details."

🎯 Claim Update
"✅ Your claim for ₹[Amount] has been approved! Funds will be credited in 2-3 working days."
```

### 4.2 Visual Content Standards

#### Iconography System
```
🎨 Icon System

Navigation Icons (Bottom Tab Bar)
├── 🏠 Home: House icon in brand color
├── 📄 Policies: Document icon with checkmark
├── 💬 Chat: Message bubble with agent avatar
├── 📚 Learn: Book icon with graduation cap
└── 👤 Profile: User silhouette

Action Icons (Consistent across app)
├── ✅ Success: Green checkmark circle
├── ⚠️ Warning: Orange exclamation triangle
├── ❌ Error: Red X circle
├── ℹ️ Info: Blue information circle
├── 👁 View: Eye icon
├── ✏️ Edit: Pencil icon
├── 🗑️ Delete: Trash can icon
└── ➕ Add: Plus circle icon

Status Icons
├── 💳 Payment: Credit card icon
├── 📞 Contact: Phone icon
├── 📧 Email: Envelope icon
├── 💬 Message: Chat bubble icon
├── 📊 Analytics: Bar chart icon
├── 🎥 Video: Play button icon
├── 📄 Document: File icon
└── 🔔 Notification: Bell icon
```

#### Typography Scale
```
📝 Typography Hierarchy

Headings
├── H1 - Page Titles: 24px Bold, Brand Color
├── H2 - Section Headers: 20px Semi-bold, Dark Gray
├── H3 - Subsection Headers: 18px Medium, Medium Gray
└── H4 - Component Headers: 16px Medium, Light Gray

Body Text
├── Large Body: 16px Regular, Dark Gray (Primary content)
├── Medium Body: 14px Regular, Medium Gray (Secondary content)
├── Small Body: 12px Regular, Light Gray (Metadata, captions)
└── Caption: 11px Regular, Light Gray (Labels, hints)

Interactive Elements
├── Buttons: 14px Semi-bold, White on Brand Color
├── Links: 14px Medium, Brand Color with underline
├── Form Labels: 14px Medium, Dark Gray
└── Error Messages: 12px Regular, Error Red
```

## 5. Content Governance & Quality Standards

### 5.1 Content Review Process
- **Agent-Generated Content**: Review before publishing
- **Customer-Generated Content**: Moderation for appropriateness
- **System-Generated Content**: Automated validation
- **Regular Content Audits**: Monthly review for accuracy and relevance

### 5.2 Localization Strategy
- **Primary Languages**: English, Hindi
- **Regional Languages**: Based on agent location (Gujarati, Marathi, Tamil, etc.)
- **Cultural Adaptation**: Content adapted for local contexts and preferences
- **Date/Number Formatting**: Localized formatting standards

### 5.3 SEO & Discoverability
- **Content Tagging**: Consistent taxonomy across all content
- **Search Optimization**: Keywords for policy types, procedures, benefits
- **Related Content Linking**: Automatic suggestions based on user behavior
- **Content Performance Analytics**: Track engagement and optimize accordingly

This comprehensive content structure ensures that every piece of information in the app serves a specific purpose, is easily discoverable, and provides value to both customers and agents while maintaining the highest standards of usability and accessibility.
