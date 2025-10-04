# Agent Mitra - Smart Dashboards & Deep Insights Design

> **Note:** This document embodies [Separation of Concerns](./glossary.md#separation-of-concerns) by providing agent analytics through the configuration portal while ensuring customer data privacy in the mobile application.

## 1. Dashboard Philosophy & Architecture

### 1.1 Design Principles for Smart Dashboards
- **Data-Driven Insights**: Actionable intelligence from customer behavior and business metrics
- **Personalized Experience**: Dashboards adapt based on user role, preferences, and context
- **Progressive Disclosure**: Essential metrics first, detailed analytics on demand
- **Real-Time Updates**: Live data with intelligent refresh intervals
- **Mobile-First Design**: Optimized for small screens with touch-friendly interactions
- **Feature Flag Control**: All dashboard features controlled by configurable flags

### 1.2 Dashboard Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│              Smart Dashboard Architecture                │
├─────────────────────────────────────────────────────────┤
│  📊 Data Collection & Processing                       │
│  ├── Real-time Data Ingestion                         │
│  ├── ML-Powered Analytics Engine                      │
│  ├── Predictive Modeling & Forecasting               │
│  └── Multi-source Data Integration                    │
├─────────────────────────────────────────────────────────┤
│  🎯 Personalized Dashboard Engine                      │
│  ├── Role-Based Dashboard Configuration              │
│  ├── User Behavior Analysis                           │
│  ├── Contextual Content Delivery                     │
│  └── Adaptive Layout System                          │
├─────────────────────────────────────────────────────────┤
│  📈 Visual Analytics Framework                         │
│  ├── Interactive Charts & Graphs                      │
│  ├── Real-time KPI Tracking                          │
│  ├── Comparative Analysis Tools                      │
│  └── Export & Reporting Capabilities                 │
├─────────────────────────────────────────────────────────┤
│  🤖 AI-Powered Insights                               │
│  ├── Automated Anomaly Detection                      │
│  ├── Trend Analysis & Forecasting                    │
│  ├── Personalized Recommendations                    │
│  └── Actionable Alert Generation                     │
├─────────────────────────────────────────────────────────┤
│  🔒 Security & Privacy                                 │
│  ├── Role-Based Data Access                           │
│  ├── Data Encryption & Masking                        │
│  ├── Audit Logging & Compliance                      │
│  └── GDPR/DPDP Privacy Controls                      │
└─────────────────────────────────────────────────────────┘
```

## 2. Customer Dashboard (Policyholder Portal)

### 2.1 Customer Dashboard - Clutter-Free Design

#### Essential Metrics Overview
```
🏠 CUSTOMER DASHBOARD - AGENT MITRA

┌─────────────────────────────────────────────────────────┐
│ 👋 Welcome back, Amit! • 📅 Today: 15 Mar 2024        │
│ 🌙 Dark Theme • 🔍 Smart Search                        │
├─────────────────────────────────────────────────────────┤
│ 🎯 Priority Actions (Essential Only)                   │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│ │ 💳 Pay       │ │ 📞 Contact  │ │ ❓ Get       │      │
│ │  Premium     │ │   Agent     │ │   Quote      │      │
│ └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│ 📊 Policy Overview (Key Metrics)                      │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 📄 Active Policies: 3                           │   │
│ │ 💰 Next Payment: ₹25,000 (Due: 18/03/2024)       │   │
│ │ 📈 Total Coverage: ₹15,00,000                   │   │
│ └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│ 🔔 Critical Notifications (Priority-Based)            │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 🔴 Premium due in 3 days                        │   │
│ │ 🟡 Policy renewal reminder                      │   │
│ └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│ 📈 Quick Insights (Visual Cards)                     │
│ ┌─────────────┐ ┌─────────────┐                     │
│ │ 📊 Premium   │ │ 🎯 Investment │                     │
│ │  History     │ │  Performance  │                     │
│ └─────────────┘ └─────────────┘                     │
└─────────────────────────────────────────────────────────┘

🎨 Theme Switcher • 🔍 Global Search • 📚 Learning Progress
```

#### Customer Insights Engine
```dart
// Personalized customer dashboard logic
class CustomerDashboardService {
  Future<CustomerDashboard> buildDashboard(User user) async {
    // 1. Get user's policy portfolio
    final policies = await PolicyService.getUserPolicies(user.id);

    // 2. Analyze payment patterns
    final paymentInsights = await PaymentAnalytics.analyzePatterns(policies);

    // 3. Generate personalized recommendations
    final recommendations = await RecommendationEngine.generateForCustomer(
      user,
      policies,
      paymentInsights
    );

    // 4. Calculate engagement metrics
    final engagementScore = await EngagementCalculator.calculateScore(user);

    return CustomerDashboard(
      essentialMetrics: _buildEssentialMetrics(policies),
      priorityActions: _getPriorityActions(user, policies),
      notifications: await _getCriticalNotifications(user),
      insights: recommendations,
      engagementScore: engagementScore
    );
  }
}
```

### 2.2 Customer Policy Analytics

#### Policy Performance Dashboard
```
📊 POLICY PERFORMANCE INSIGHTS - AMIT SHARMA

📈 Policy Portfolio Overview:
├── Total Policies: 3
├── Active Policies: 3 (100%)
├── Total Premium: ₹75,000/year
├── Total Coverage: ₹15,00,000

💰 Premium Payment Analytics:
├── Payment Regularity: 100% (Excellent)
├── Average Payment Amount: ₹25,000
├── Preferred Payment Method: UPI (65%)
├── Payment Streak: 36 months

📊 Investment Performance:
├── LIC Jeevan Anand: +₹1,25,000 bonus accumulated
├── LIC Money Back: Maturity in 2 years (₹8,50,000 expected)
├── Overall Portfolio Growth: +18% annually

🎯 Personalized Recommendations:
├── "Consider ULIP for higher returns" (Based on risk profile)
├── "Increase coverage by ₹5,00,000" (Life stage analysis)
├── "Set up auto-payment for convenience" (Payment pattern)
└── "Explore term insurance for family protection" (Gap analysis)
```

#### Customer Engagement Metrics
```
📊 CUSTOMER ENGAGEMENT DASHBOARD

👤 User Profile Insights:
├── App Sessions: 45 this month (+15% vs last month)
├── Average Session Duration: 8.2 minutes
├── Feature Usage: Dashboard (80%), Policies (65%), Chat (45%)
├── Learning Progress: 15 videos watched (78% completion rate)

📱 App Interaction Patterns:
├── Most Used Features: Premium Payment, Policy Status, Agent Chat
├── Peak Usage Time: 7-9 PM weekdays
├── Device Preference: Mobile (95%), Tablet (5%)
├── Language Usage: English (70%), Hindi (30%)

💡 Engagement Optimization:
├── "Watch 3 more videos to unlock advanced features"
├── "Complete profile for personalized recommendations"
├── "Enable notifications for timely reminders"
└── "Connect WhatsApp for seamless agent communication"
```

## 3. Agent Dashboard (Business Intelligence)

### 3.1 Agent Business Dashboard

#### Key Performance Indicators (KPIs)
```
📊 AGENT DASHBOARD - RAJESH KUMAR

┌─────────────────────────────────────────────────────────┐
│ 🎯 Primary KPIs (Real-time Updates)                    │
│ ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│ │ 💰 Monthly   │ │ 👥 Active    │ │ 📈 Renewal  │      │
│ │  Revenue     │ │  Customers   │ │  Rate       │      │
│ │ ₹2,45,000    │ │   342        │ │   94.2%     │      │
│ └─────────────┘ └─────────────┘ └─────────────┘      │
├─────────────────────────────────────────────────────────┤
│ 📈 Trend Analysis (6-Month Overview)                   │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 📈 Revenue Trend • 👥 Customer Growth           │   │
│ │ 📊 Policy Sales • 💹 ROI Performance            │   │
│ └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│ 🎯 Priority Action Items                               │
│ ┌─────────────────────────────────────────────────┐   │
│ │ 🔴 5 premium payments overdue                   │   │
│ │ 🟡 12 customers need renewal reminder           │   │
│ │ 🟢 8 customers eligible for new products        │   │
│ └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│ 🚨 Smart Alerts & Notifications                        │
│ ┌─────────────────────────────────────────────────┐   │
│ │ ⚠️ Policy lapse warning: Customer ABC           │   │
│ │ 📢 New product launch: LIC Tech Term            │   │
│ │ 💼 Commission update: ₹15,000 credited          │   │
│ └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

🎯 Quick Actions • 📊 View Details • 📈 Export Report
```

#### Agent Performance Analytics
```dart
// Agent performance calculation engine
class AgentPerformanceService {
  Future<AgentPerformance> calculatePerformance(Agent agent) async {
    // 1. Revenue Analysis
    final revenueMetrics = await RevenueAnalytics.calculateMetrics(agent);

    // 2. Customer Engagement Analysis
    final engagementMetrics = await EngagementAnalytics.analyzeCustomers(agent);

    // 3. Content Performance Analysis
    final contentMetrics = await ContentAnalytics.analyzeVideos(agent);

    // 4. Predictive Forecasting
    final forecast = await PredictiveAnalytics.generateForecast(agent);

    return AgentPerformance(
      revenue: revenueMetrics,
      engagement: engagementMetrics,
      content: contentMetrics,
      forecast: forecast,
      recommendations: await _generateRecommendations(agent)
    );
  }
}
```

### 3.2 Customer Segmentation & Insights

#### Customer Analytics Dashboard
```
👥 CUSTOMER ANALYTICS DASHBOARD - RAJESH KUMAR

📊 Customer Portfolio Overview:
├── Total Customers: 342
├── High-Value Customers: 45 (AOV > ₹5,000)
├── At-Risk Customers: 12 (Irregular payments)
├── New Customers: 28 (Joined < 6 months)

💰 Customer Value Segmentation:
┌─────────────────────────────────────────────────┐
│ 💎 VIP Customers (AOV > ₹10,000)                   │
│ • Count: 15 • Total Premium: ₹4,50,000           │
│ • Engagement: 9.2/10 • Retention: 98%            │
├─────────────────────────────────────────────────┤
│ 💰 High-Value (₹5,000 - ₹10,000)                   │
│ • Count: 30 • Total Premium: ₹2,25,000           │
│ • Engagement: 8.7/10 • Retention: 94%            │
├─────────────────────────────────────────────────┤
│ 📈 Medium-Value (₹2,000 - ₹5,000)                 │
│ • Count: 180 • Total Premium: ₹6,75,000          │
│ • Engagement: 7.8/10 • Retention: 89%            │
├─────────────────────────────────────────────────┤
│ 🎯 Growth Opportunity (< ₹2,000)                   │
│ • Count: 117 • Total Premium: ₹1,95,000          │
│ • Engagement: 6.5/10 • Retention: 82%            │
└─────────────────────────────────────────────────┘

🎯 Customer Insights:
├── "15 customers eligible for premium increase" (Upsell opportunity)
├── "8 customers show declining engagement" (Retention risk)
├── "23 customers ready for new product recommendations" (Cross-sell)
└── "12 customers need educational content" (Support improvement)
```

#### Customer Behavior Analytics
```
📊 CUSTOMER BEHAVIOR INSIGHTS

👤 Individual Customer Analysis:
├── Amit Sharma (High-Value Customer)
│   • Policy Portfolio: 3 policies, ₹75,000 premium
│   • Engagement Score: 8.5/10 (Above average)
│   • Last Interaction: 2 days ago (WhatsApp)
│   • Learning Progress: 15 videos watched (78% completion)
│   • Payment Regularity: 100% (Excellent)
│   • Recommended Actions: "Offer ULIP upgrade" (High potential)

💡 Behavioral Patterns:
├── Peak Activity Times: 7-9 PM weekdays, 10 AM-12 PM weekends
├── Preferred Communication: WhatsApp (65%), In-app chat (35%)
├── Content Engagement: Policy tutorials (45%), Investment guides (30%)
├── Payment Patterns: End-of-month payments (60%), Mid-month (40%)

📈 Predictive Insights:
├── "Amit likely to renew all policies" (95% confidence)
├── "High probability of ULIP upgrade" (78% likelihood)
├── "Engagement trending upward" (12% improvement expected)
└── "Premium increase potential: +15%" (Based on life stage analysis)
```

## 4. Advanced Analytics & AI-Powered Insights

### 4.1 Predictive Analytics Engine

#### Customer Churn Prediction
```
🔮 CUSTOMER CHURN PREDICTION DASHBOARD

⚠️ High-Risk Customers (Churn Probability > 70%):
┌─────────────────────────────────────────────────┐
│ 👤 Customer ABC (Churn Risk: 85%)                  │
│ • Last Payment: 45 days overdue                   │
│ • Engagement Score: 3.2/10 (Declining)           │
│ • Policy Lapse Warning: 2 policies at risk      │
│ • Recommended Actions: "Immediate follow-up call" │
├─────────────────────────────────────────────────┤
│ 👤 Customer DEF (Churn Risk: 72%)                  │
│ • Engagement Drop: -35% in last 30 days          │
│ • Support Queries: 8 in last month (High)        │
│ • Payment Issues: 3 failed attempts             │
│ • Recommended Actions: "Personal consultation"    │
└─────────────────────────────────────────────────┘

📊 Churn Prevention Strategies:
├── Automated Reminders: "Payment due" notifications (Sent: 142)
├── Personalized Outreach: "Special discount offer" (Conversion: 23%)
├── Educational Content: "Policy value explanation" (Engagement: +45%)
└── Agent Intervention: "Priority customer calls" (Retention: 78%)

💡 Predictive Accuracy:
├── Model Accuracy: 87% (Validated against historical data)
├── False Positive Rate: 13% (Conservative predictions)
├── Lead Time: 30-60 days advance warning
└── Success Rate: 78% churn prevention with early intervention
```

#### Revenue Forecasting
```
📈 REVENUE FORECASTING DASHBOARD

💰 Monthly Revenue Projection:
├── Current Month: ₹2,45,000 (Actual: ₹2,10,000)
├── Next Month: ₹2,80,000 (Predicted: 95% confidence)
├── Q4 Projection: ₹8,50,000 (Based on seasonal trends)
└── Annual Target: ₹3,200,000 (Progress: 68%)

📊 Revenue Drivers Analysis:
├── New Policy Sales: ₹1,25,000 (51% of revenue)
├── Policy Renewals: ₹85,000 (35% of revenue)
├── Premium Increases: ₹25,000 (10% of revenue)
├── Commission Bonuses: ₹10,000 (4% of revenue)

🔮 Predictive Factors:
├── Customer Acquisition: +8 customers/month (Growing trend)
├── Renewal Rate: 94.2% (Stable, above industry average)
├── Premium Increase Rate: 15% (Based on life stage analysis)
├── Market Conditions: +5% growth (Economic indicators)

💡 Actionable Recommendations:
├── "Focus on 8 high-potential customers for upsell" (₹45,000 potential)
├── "Contact 12 renewal-due customers this week" (₹85,000 opportunity)
├── "Promote term insurance to 23 eligible customers" (₹67,000 potential)
└── "Create educational content for 15 engagement-drop customers" (Retention focus)
```

### 4.2 Real-Time Analytics & Alerting

#### Smart Alert System
```
🚨 REAL-TIME ALERTS & NOTIFICATIONS

🔴 Critical Alerts (Immediate Action Required):
├── "Payment Failed: Customer ABC - ₹25,000" (Action: Call immediately)
├── "Policy Lapse Warning: Customer DEF - 3 days remaining" (Action: Send reminder)
├── "High-Value Customer Churn Risk: Customer GHI - 85%" (Action: Personal visit)

🟡 Warning Alerts (Plan Action):
├── "Engagement Drop: 12 customers -35% decrease" (Action: Send educational content)
├── "Support Query Spike: +40% increase" (Action: Review common issues)
├── "Video Performance Drop: 15% completion rate decrease" (Action: Content optimization)

🟢 Opportunity Alerts (Growth Potential):
├── "Upsell Opportunity: 8 customers eligible for premium increase" (₹45,000 potential)
├── "New Product Interest: 15 customers viewing ULIP content" (₹67,000 potential)
├── "Educational Content Success: 89% completion rate for payment tutorials" (Scale successful content)

📊 Alert Configuration:
├── Alert Frequency: Real-time for critical, Daily digest for others
├── Notification Channels: In-app, Email, WhatsApp (Based on urgency)
├── Escalation Rules: Auto-escalate unacknowledged critical alerts
└── Performance Tracking: Alert response time and effectiveness metrics
```

#### Performance Monitoring
```
📊 DASHBOARD PERFORMANCE MONITORING

⚡ Real-Time Metrics:
├── Active Users: 1,240 (Peak: 1,850 at 8 PM)
├── API Response Time: 145ms (Target: <200ms)
├── Error Rate: 0.02% (Target: <0.1%)
├── Data Freshness: 2 minutes (Target: <5 minutes)

📈 System Health Indicators:
├── Database Performance: 98.7% uptime
├── Cache Hit Rate: 94.2% (Redis performance)
├── CDN Performance: 99.1% availability
├── Mobile App Crash Rate: 0.03% (Flutter stability)

💡 Performance Optimization:
├── "Cache optimization improved response time by 23%"
├── "Database query optimization reduced load by 15%"
├── "CDN edge locations increased global performance by 31%"
└── "Mobile app optimization reduced crash rate by 67%"
```

## 5. Interactive Dashboard Components

### 5.1 Customizable Dashboard Widgets

#### Widget Library
```
🎛️ DASHBOARD WIDGET LIBRARY

📊 KPI Widgets:
├── Revenue Tracker (Real-time monthly revenue)
├── Customer Counter (Active vs total customers)
├── Renewal Rate Monitor (Policy renewal percentage)
├── Engagement Score (Customer interaction metrics)
└── Conversion Funnel (Lead to customer conversion)

📈 Chart Widgets:
├── Line Charts (Trend analysis over time)
├── Bar Charts (Comparative performance metrics)
├── Pie Charts (Revenue breakdown by source)
├── Area Charts (Customer growth patterns)
└── Heat Maps (Geographic performance distribution)

🎯 Action Widgets:
├── Priority Tasks (AI-suggested action items)
├── Quick Actions (Frequently used features)
├── Alert Center (Critical notifications)
├── Recommendation Engine (Personalized suggestions)
└── Performance Goals (Progress tracking)

📱 Mobile-Optimized Widgets:
├── Compact KPI Cards (48pt touch targets)
├── Swipeable Charts (Touch-friendly navigation)
├── Collapsible Sections (Progressive disclosure)
├── Voice-Activated Controls (Accessibility support)
└── Dark/Light Theme Variants (CSS-based theming)
```

#### Widget Configuration Interface
```
⚙️ DASHBOARD CUSTOMIZATION

🎛️ Widget Management:
├── Available Widgets: 24 options across 4 categories
├── Current Layout: 3x2 grid (6 active widgets)
├── Widget Positioning: Drag & drop rearrangement
├── Widget Sizing: Compact, Standard, Expanded options

📊 Data Source Configuration:
├── Real-time Data: Auto-refresh every 30 seconds
├── Historical Data: Custom date range selection
├── Data Aggregation: Daily, Weekly, Monthly views
├── Comparison Periods: Previous period, Same period last year

🎨 Visual Customization:
├── Color Themes: Dark, Light, Auto (System preference)
├── Chart Styles: Modern, Classic, Minimalist options
├── Animation Settings: Smooth, Fast, Disabled
├── Accessibility: High contrast, Large text, Screen reader support

💾 Layout Presets:
├── "Executive Overview" (KPIs + Trends)
├── "Customer Focus" (Engagement + Segmentation)
├── "Revenue Analysis" (Financial metrics + Forecasting)
├── "Content Performance" (Video analytics + Learning insights)
└── "Custom Layout" (User-defined configuration)
```

### 5.2 Interactive Chart Components

#### Advanced Chart Interactions
```
📈 INTERACTIVE CHART FRAMEWORK

🎯 Touch Interactions:
├── Tap to Focus (Highlight specific data points)
├── Pinch to Zoom (Detailed view of time periods)
├── Swipe to Navigate (Browse through time series)
├── Long Press for Details (Contextual information popup)
└── Double Tap to Reset (Return to default view)

📊 Chart Types & Features:
├── Line Charts (Trend analysis with smoothing options)
├── Bar Charts (Comparative data with grouping)
├── Pie Charts (Percentage breakdown with drill-down)
├── Area Charts (Volume visualization with stacking)
├── Scatter Plots (Correlation analysis)
├── Heat Maps (Geographic data visualization)
└── Gauge Charts (KPI progress indicators)

🔧 Chart Customization:
├── Time Period Selection (1D, 7D, 30D, 90D, 1Y, Custom)
├── Metric Selection (Revenue, Customers, Engagement, etc.)
├── Comparison Mode (Current vs Previous, Target vs Actual)
├── Filter Options (Customer segments, Policy types, etc.)
└── Export Options (PNG, PDF, CSV data)

📱 Mobile Chart Optimizations:
├── Responsive Design (Adapts to screen size)
├── Touch-Friendly Controls (Large buttons and targets)
├── Progressive Loading (Charts load as needed)
├── Offline Caching (View cached data without internet)
└── Voice Navigation (Screen reader accessibility)
```

## 6. Environment Variables & Feature Flags

### 6.1 Dashboard Configuration

#### Analytics Environment Variables
```bash
# Dashboard Performance Configuration
DASHBOARD_REFRESH_INTERVAL=30  # Seconds
DASHBOARD_CACHE_TTL=300       # 5 minutes
DASHBOARD_MAX_WIDGETS=12      # Per dashboard
DASHBOARD_EXPORT_FORMATS=png,pdf,csv,xlsx

# Real-time Analytics Configuration
REALTIME_ANALYTICS_ENABLED=true
REALTIME_UPDATE_INTERVAL=30    # Seconds
REALTIME_EVENT_BUFFER_SIZE=1000
REALTIME_CONNECTION_POOL_SIZE=50

# Predictive Analytics Configuration
PREDICTIVE_MODEL_VERSION=v2.1
PREDICTIVE_UPDATE_FREQUENCY=daily
PREDICTIVE_CONFIDENCE_THRESHOLD=0.75
PREDICTIVE_HORIZON_DAYS=90

# Dashboard Security
DASHBOARD_ROLE_BASED_ACCESS=true
DASHBOARD_DATA_MASKING=true
DASHBOARD_AUDIT_LOGGING=true
DASHBOARD_EXPORT_LOGGING=true
```

#### Feature Flag Configuration
```bash
# Dashboard Feature Flags
FEATURE_CUSTOMER_DASHBOARD_ENABLED=true
FEATURE_AGENT_DASHBOARD_ENABLED=true
FEATURE_PREDICTIVE_ANALYTICS_ENABLED=true
FEATURE_REALTIME_UPDATES_ENABLED=true
FEATURE_CUSTOM_DASHBOARD_LAYOUTS=true
FEATURE_ADVANCED_CHART_INTERACTIONS=true

# Analytics Feature Flags
FEATURE_CUSTOMER_SEGMENTATION_ENABLED=true
FEATURE_CHURN_PREDICTION_ENABLED=true
FEATURE_REVENUE_FORECASTING_ENABLED=true
FEATURE_CONTENT_PERFORMANCE_ANALYTICS=true
FEATURE_BEHAVIOR_ANALYTICS_ENABLED=true

# Mobile Dashboard Features
FEATURE_MOBILE_DASHBOARD_OPTIMIZATION=true
FEATURE_TOUCH_CHART_INTERACTIONS=true
FEATURE_VOICE_DASHBOARD_CONTROLS=true
FEATURE_OFFLINE_DASHBOARD_MODE=true
```

## 6. Campaign Performance Analytics

### 6.1 Campaign Analytics Dashboard Architecture

The Campaign Performance Analytics dashboard provides comprehensive insights into marketing campaign effectiveness, ROI tracking, and customer engagement metrics through the Agent Mitra Config Portal/Website.

#### Campaign Performance Dashboard Implementation
```dart
class CampaignPerformanceDashboard extends StatefulWidget {
  @override
  _CampaignPerformanceDashboardState createState() => _CampaignPerformanceDashboardState();
}

class _CampaignPerformanceDashboardState extends State<CampaignPerformanceDashboard> {
  late Map<String, dynamic> _campaignData;
  String _selectedTimeframe = '30d';
  String _selectedCampaignType = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCampaignData();
  }

  Future<void> _loadCampaignData() async {
    try {
      _campaignData = await CampaignAnalyticsService.getCampaignPerformanceData(
        timeframe: _selectedTimeframe,
        campaignType: _selectedCampaignType,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Performance Analytics'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (timeframe) {
              setState(() => _selectedTimeframe = timeframe);
              _loadCampaignData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7d', child: Text('Last 7 days')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 days')),
              const PopupMenuItem(value: '90d', child: Text('Last 90 days')),
              const PopupMenuItem(value: '1y', child: Text('Last year')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Performance Metrics
                  _buildKPIMetrics(),
                  const SizedBox(height: 24),

                  // Campaign Performance Chart
                  _buildCampaignPerformanceChart(),
                  const SizedBox(height: 24),

                  // Campaign Type Breakdown
                  _buildCampaignTypeBreakdown(),
                  const SizedBox(height: 24),

                  // Top Performing Campaigns
                  _buildTopPerformingCampaigns(),
                  const SizedBox(height: 24),

                  // ROI Analysis
                  _buildROIAnalysis(),
                ],
              ),
            ),
    );
  }

  Widget _buildKPIMetrics() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Key Performance Indicators',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildKPICard(
                    'Total Campaigns',
                    _campaignData['totalCampaigns'].toString(),
                    Icons.campaign,
                    Colors.blue,
                    '+${_campaignData['campaignGrowth']}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKPICard(
                    'Total Reach',
                    _formatNumber(_campaignData['totalReach']),
                    Icons.people,
                    Colors.green,
                    '+${_campaignData['reachGrowth']}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKPICard(
                    'Conversion Rate',
                    '${_campaignData['conversionRate']}%',
                    Icons.trending_up,
                    Colors.orange,
                    '+${_campaignData['conversionGrowth']}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignPerformanceChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Campaign Performance Trend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _selectedCampaignType,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Campaigns')),
                    DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                    DropdownMenuItem(value: 'email', child: Text('Email')),
                    DropdownMenuItem(value: 'sms', child: Text('SMS')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCampaignType = value!);
                    _loadCampaignData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Interactive Line Chart\n(Reach, Engagement, Conversions over time)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampaignTypeBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campaign Type Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Pie Chart & Bar Chart\n(Breakdown by campaign type)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformingCampaigns() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performing Campaigns',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._campaignData['topCampaigns'].map<Widget>((campaign) =>
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.green.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          Text(
                            '${campaign['reach']} reach • ${campaign['conversionRate']}% conversion',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ROI: ${campaign['roi']}x',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildROIAnalysis() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ROI Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('ROI Scatter Plot\n(Campaign cost vs. revenue generated)'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildROIInsight('Average ROI', '${_campaignData['averageROI']}x', Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildROIInsight('Best Performer', _campaignData['bestCampaign'], Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildROIInsight('Total Investment', '₹${_formatNumber(_campaignData['totalInvestment'])}', Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildROIInsight(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
```

### 6.2 Campaign Effectiveness Metrics

#### Key Performance Indicators (KPIs)
```typescript
interface CampaignKPIs {
  // Reach & Engagement
  totalReach: number;
  uniqueImpressions: number;
  engagementRate: number;
  clickThroughRate: number;

  // Conversion Metrics
  conversionRate: number;
  costPerAcquisition: number;
  customerLifetimeValue: number;

  // Financial Metrics
  totalInvestment: number;
  revenueGenerated: number;
  returnOnInvestment: number;
  profitMargin: number;

  // Time-based Metrics
  campaignDuration: number;
  timeToFirstConversion: number;
  peakPerformanceTime: string;

  // Quality Metrics
  customerSatisfaction: number;
  repeatPurchaseRate: number;
  churnRate: number;
}
```

#### Campaign Analytics Service Implementation
```python
# portal_service/app/analytics/campaign_analytics.py
"""
Campaign Performance Analytics Service
Provides comprehensive analytics for marketing campaign effectiveness
"""

from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
import logging

from ..models import Campaign, CampaignMetric, CustomerInteraction
from ...database import get_db

logger = logging.getLogger(__name__)

class CampaignAnalyticsService:
    """Service for campaign performance analytics"""

    @staticmethod
    async def get_campaign_performance_data(
        db: AsyncSession,
        timeframe: str = '30d',
        campaign_type: Optional[str] = None,
        agent_id: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Get comprehensive campaign performance data
        """
        try:
            # Parse timeframe
            days = CampaignAnalyticsService._parse_timeframe(timeframe)
            start_date = datetime.utcnow() - timedelta(days=days)

            # Build filters
            filters = [Campaign.created_at >= start_date]
            if campaign_type and campaign_type != 'all':
                filters.append(Campaign.campaign_type == campaign_type)
            if agent_id:
                filters.append(Campaign.agent_id == agent_id)

            # Get campaign data
            campaigns_query = db.query(Campaign).filter(*filters)
            campaigns = await db.execute(campaigns_query)
            campaigns = campaigns.scalars().all()

            # Calculate metrics
            total_campaigns = len(campaigns)
            total_reach = sum(c.reach for c in campaigns)
            total_investment = sum(c.budget for c in campaigns)
            total_revenue = sum(c.revenue_generated for c in campaigns)

            # Calculate conversion rate
            total_conversions = sum(c.conversions for c in campaigns)
            conversion_rate = (total_conversions / total_reach * 100) if total_reach > 0 else 0

            # Calculate ROI
            roi = (total_revenue / total_investment) if total_investment > 0 else 0

            # Get top performing campaigns
            top_campaigns = sorted(
                campaigns,
                key=lambda c: c.roi if c.roi else 0,
                reverse=True
            )[:5]

            return {
                'totalCampaigns': total_campaigns,
                'totalReach': total_reach,
                'totalInvestment': total_investment,
                'totalRevenue': total_revenue,
                'conversionRate': round(conversion_rate, 2),
                'roi': round(roi, 2),
                'campaignGrowth': CampaignAnalyticsService._calculate_growth(db, 'campaigns', days),
                'reachGrowth': CampaignAnalyticsService._calculate_growth(db, 'reach', days),
                'conversionGrowth': CampaignAnalyticsService._calculate_growth(db, 'conversions', days),
                'topCampaigns': [
                    {
                        'name': c.name,
                        'reach': c.reach,
                        'conversionRate': round((c.conversions / c.reach * 100) if c.reach > 0 else 0, 1),
                        'roi': round(c.roi, 1) if c.roi else 0
                    }
                    for c in top_campaigns
                ],
                'averageROI': round(roi, 1),
                'bestCampaign': top_campaigns[0].name if top_campaigns else 'N/A'
            }

        except Exception as e:
            logger.error(f"Campaign analytics error: {str(e)}")
            return CampaignAnalyticsService._get_empty_analytics()

    @staticmethod
    async def get_campaign_type_breakdown(
        db: AsyncSession,
        timeframe: str = '30d'
    ) -> Dict[str, Any]:
        """
        Get campaign performance breakdown by type
        """
        try:
            days = CampaignAnalyticsService._parse_timeframe(timeframe)
            start_date = datetime.utcnow() - timedelta(days=days)

            # Group campaigns by type
            type_breakdown = await db.execute("""
                SELECT
                    campaign_type,
                    COUNT(*) as count,
                    SUM(reach) as total_reach,
                    SUM(conversions) as total_conversions,
                    SUM(budget) as total_budget,
                    SUM(revenue_generated) as total_revenue
                FROM campaigns
                WHERE created_at >= :start_date
                GROUP BY campaign_type
            """, {'start_date': start_date})

            breakdown = {}
            for row in type_breakdown:
                campaign_type = row[0] or 'other'
                breakdown[campaign_type] = {
                    'count': row[1],
                    'reach': row[2] or 0,
                    'conversions': row[3] or 0,
                    'budget': row[4] or 0,
                    'revenue': row[5] or 0,
                    'conversionRate': round((row[3] / row[2] * 100) if row[2] and row[2] > 0 else 0, 2),
                    'roi': round((row[5] / row[4]) if row[4] and row[4] > 0 else 0, 2)
                }

            return breakdown

        except Exception as e:
            logger.error(f"Campaign type breakdown error: {str(e)}")
            return {}

    @staticmethod
    async def get_campaign_trends(
        db: AsyncSession,
        timeframe: str = '30d'
    ) -> List[Dict[str, Any]]:
        """
        Get campaign performance trends over time
        """
        try:
            days = CampaignAnalyticsService._parse_timeframe(timeframe)
            start_date = datetime.utcnow() - timedelta(days=days)

            # Get daily metrics
            trends_query = await db.execute("""
                SELECT
                    DATE(created_at) as date,
                    COUNT(*) as campaigns_created,
                    SUM(reach) as daily_reach,
                    SUM(conversions) as daily_conversions,
                    SUM(budget) as daily_budget,
                    SUM(revenue_generated) as daily_revenue
                FROM campaigns
                WHERE created_at >= :start_date
                GROUP BY DATE(created_at)
                ORDER BY date
            """, {'start_date': start_date})

            trends = []
            for row in trends_query:
                date, campaigns, reach, conversions, budget, revenue = row
                trends.append({
                    'date': date.isoformat(),
                    'campaignsCreated': campaigns,
                    'reach': reach or 0,
                    'conversions': conversions or 0,
                    'budget': budget or 0,
                    'revenue': revenue or 0,
                    'conversionRate': round((conversions / reach * 100) if reach and reach > 0 else 0, 2),
                    'roi': round((revenue / budget) if budget and budget > 0 else 0, 2)
                })

            return trends

        except Exception as e:
            logger.error(f"Campaign trends error: {str(e)}")
            return []

    @staticmethod
    def _parse_timeframe(timeframe: str) -> int:
        """Parse timeframe string to days"""
        timeframe_map = {
            '7d': 7,
            '30d': 30,
            '90d': 90,
            '1y': 365
        }
        return timeframe_map.get(timeframe, 30)

    @staticmethod
    async def _calculate_growth(db: AsyncSession, metric: str, days: int) -> float:
        """Calculate growth percentage for a metric"""
        try:
            current_period_start = datetime.utcnow() - timedelta(days=days)
            previous_period_start = datetime.utcnow() - timedelta(days=days * 2)

            # This is a simplified implementation
            # In practice, you'd query actual metrics for both periods
            return 12.5  # Placeholder growth percentage

        except Exception:
            return 0.0

    @staticmethod
    def _get_empty_analytics() -> Dict[str, Any]:
        """Return empty analytics structure"""
        return {
            'totalCampaigns': 0,
            'totalReach': 0,
            'totalInvestment': 0,
            'totalRevenue': 0,
            'conversionRate': 0,
            'roi': 0,
            'campaignGrowth': 0,
            'reachGrowth': 0,
            'conversionGrowth': 0,
            'topCampaigns': [],
            'averageROI': 0,
            'bestCampaign': 'N/A'
        }
```

## 7. Content Performance Analytics

### 7.1 Content Analytics Dashboard Architecture

The Content Performance Analytics dashboard provides detailed insights into educational content effectiveness, user engagement patterns, and learning outcomes through the Agent Mitra Config Portal/Website.

#### Content Performance Dashboard Implementation
```dart
class ContentPerformanceDashboard extends StatefulWidget {
  @override
  _ContentPerformanceDashboardState createState() => _ContentPerformanceDashboardState();
}

class _ContentPerformanceDashboardState extends State<ContentPerformanceDashboard> {
  late Map<String, dynamic> _contentData;
  String _selectedTimeframe = '30d';
  String _selectedContentType = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContentData();
  }

  Future<void> _loadContentData() async {
    try {
      _contentData = await ContentAnalyticsService.getContentPerformanceData(
        timeframe: _selectedTimeframe,
        contentType: _selectedContentType,
      );
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content Performance Analytics'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (timeframe) {
              setState(() => _selectedTimeframe = timeframe);
              _loadContentData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '7d', child: Text('Last 7 days')),
              const PopupMenuItem(value: '30d', child: Text('Last 30 days')),
              const PopupMenuItem(value: '90d', child: Text('Last 90 days')),
              const PopupMenuItem(value: '1y', child: Text('Last year')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Key Content Metrics
                  _buildContentKPIMetrics(),
                  const SizedBox(height: 24),

                  // Content Engagement Chart
                  _buildContentEngagementChart(),
                  const SizedBox(height: 24),

                  // Content Type Performance
                  _buildContentTypeBreakdown(),
                  const SizedBox(height: 24),

                  // Top Performing Content
                  _buildTopPerformingContent(),
                  const SizedBox(height: 24),

                  // User Engagement Analysis
                  _buildUserEngagementAnalysis(),
                ],
              ),
            ),
    );
  }

  Widget _buildContentKPIMetrics() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Performance Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildContentKPICard(
                    'Total Views',
                    _formatNumber(_contentData['totalViews']),
                    Icons.visibility,
                    Colors.blue,
                    '+${_contentData['viewsGrowth']}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContentKPICard(
                    'Avg. Watch Time',
                    '${_contentData['avgWatchTime']}min',
                    Icons.access_time,
                    Colors.green,
                    '+${_contentData['watchTimeGrowth']}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildContentKPICard(
                    'Completion Rate',
                    '${_contentData['completionRate']}%',
                    Icons.check_circle,
                    Colors.orange,
                    '+${_contentData['completionGrowth']}%',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentKPICard(String title, String value, IconData icon, Color color, String change) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            change,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentEngagementChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Content Engagement Trends',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _selectedContentType,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All Content')),
                    DropdownMenuItem(value: 'video', child: Text('Videos')),
                    DropdownMenuItem(value: 'article', child: Text('Articles')),
                    DropdownMenuItem(value: 'quiz', child: Text('Quizzes')),
                    DropdownMenuItem(value: 'tutorial', child: Text('Tutorials')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedContentType = value!);
                    _loadContentData();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Interactive Multi-line Chart\n(Views, Watch Time, Completion Rate over time)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentTypeBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Content Type Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Stacked Bar Chart\n(Performance by content type)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformingContent() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performing Content',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._contentData['topContent'].map<Widget>((content) =>
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getContentTypeIcon(content['type']),
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            content['title'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                          ),
                          Text(
                            '${_formatNumber(content['views'])} views • ${content['completionRate']}% completion',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.purple.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${content['engagementScore']}/10',
                        style: TextStyle(
                          color: Colors.purple.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserEngagementAnalysis() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Engagement Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Heat Map\n(User engagement by time of day and content type)'),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildEngagementInsight('Peak Engagement Time', _contentData['peakTime'], Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEngagementInsight('Most Popular Type', _contentData['popularType'], Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEngagementInsight('Avg. Session Time', '${_contentData['avgSessionTime']}min', Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementInsight(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getContentTypeIcon(String contentType) {
    switch (contentType.toLowerCase()) {
      case 'video':
        return Icons.video_library;
      case 'article':
        return Icons.article;
      case 'quiz':
        return Icons.quiz;
      case 'tutorial':
        return Icons.school;
      default:
        return Icons.content_copy;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
```

### 7.2 Content Effectiveness Metrics

#### Content Performance Indicators
```typescript
interface ContentPerformanceMetrics {
  // Consumption Metrics
  totalViews: number;
  uniqueViewers: number;
  averageWatchTime: number;
  completionRate: number;
  dropOffRate: number;

  // Engagement Metrics
  likesCount: number;
  sharesCount: number;
  commentsCount: number;
  bookmarksCount: number;
  engagementRate: number;

  // Learning Outcomes
  quizScores: number[];
  averageQuizScore: number;
  certificationRate: number;
  knowledgeRetentionRate: number;

  // User Behavior
  returnVisitorRate: number;
  contentDiscoveryRate: number;
  sessionDuration: number;
  pagesPerSession: number;

  // Technical Metrics
  loadTime: number;
  bufferingRate: number;
  errorRate: number;
  deviceBreakdown: Record<string, number>;
}
```

#### Content Analytics Service Implementation
```python
# portal_service/app/analytics/content_analytics.py
"""
Content Performance Analytics Service
Provides detailed analytics for educational content effectiveness
"""

from typing import Dict, List, Optional, Any
from datetime import datetime, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
import logging

from ..models import Content, ContentView, ContentEngagement, UserLearningProgress
from ...database import get_db

logger = logging.getLogger(__name__)

class ContentAnalyticsService:
    """Service for content performance analytics"""

    @staticmethod
    async def get_content_performance_data(
        db: AsyncSession,
        timeframe: str = '30d',
        content_type: Optional[str] = None,
        agent_id: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        Get comprehensive content performance data
        """
        try:
            # Parse timeframe
            days = ContentAnalyticsService._parse_timeframe(timeframe)
            start_date = datetime.utcnow() - timedelta(days=days)

            # Build filters
            filters = [Content.created_at >= start_date]
            if content_type and content_type != 'all':
                filters.append(Content.content_type == content_type)
            if agent_id:
                filters.append(Content.agent_id == agent_id)

            # Get content data
            content_query = db.query(Content).filter(*filters)
            content_items = await db.execute(content_query)
            content_items = content_items.scalars().all()

            # Calculate aggregate metrics
            total_views = sum(c.views_count for c in content_items)
            total_watch_time = sum(c.total_watch_time for c in content_items)
            total_completions = sum(c.completions_count for c in content_items)

            # Calculate averages
            avg_watch_time = (total_watch_time / total_views / 60) if total_views > 0 else 0  # in minutes
            completion_rate = (total_completions / total_views * 100) if total_views > 0 else 0

            # Get top performing content
            top_content = sorted(
                content_items,
                key=lambda c: c.engagement_score if c.engagement_score else 0,
                reverse=True
            )[:5]

            return {
                'totalViews': total_views,
                'avgWatchTime': round(avg_watch_time, 1),
                'completionRate': round(completion_rate, 1),
                'viewsGrowth': ContentAnalyticsService._calculate_growth(db, 'content_views', days),
                'watchTimeGrowth': ContentAnalyticsService._calculate_growth(db, 'watch_time', days),
                'completionGrowth': ContentAnalyticsService._calculate_growth(db, 'completions', days),
                'topContent': [
                    {
                        'title': c.title,
                        'type': c.content_type,
                        'views': c.views_count,
                        'completionRate': round((c.completions_count / c.views_count * 100) if c.views_count > 0 else 0, 1),
                        'engagementScore': round(c.engagement_score, 1) if c.engagement_score else 0
                    }
                    for c in top_content
                ],
                'peakTime': ContentAnalyticsService._get_peak_engagement_time(db, days),
                'popularType': ContentAnalyticsService._get_most_popular_type(content_items),
                'avgSessionTime': round(ContentAnalyticsService._calculate_avg_session_time(db, days), 1)
            }

        except Exception as e:
            logger.error(f"Content analytics error: {str(e)}")
            return ContentAnalyticsService._get_empty_analytics()

    @staticmethod
    async def get_content_type_breakdown(
        db: AsyncSession,
        timeframe: str = '30d'
    ) -> Dict[str, Any]:
        """
        Get content performance breakdown by type
        """
        try:
            days = ContentAnalyticsService._parse_timeframe(timeframe)
            start_date = datetime.utcnow() - timedelta(days=days)

            # Group content by type
            type_breakdown = await db.execute("""
                SELECT
                    content_type,
                    COUNT(*) as count,
                    SUM(views_count) as total_views,
                    SUM(completions_count) as total_completions,
                    AVG(engagement_score) as avg_engagement
                FROM content
                WHERE created_at >= :start_date
                GROUP BY content_type
            """, {'start_date': start_date})

            breakdown = {}
            for row in type_breakdown:
                content_type = row[0] or 'other'
                breakdown[content_type] = {
                    'count': row[1],
                    'views': row[2] or 0,
                    'completions': row[3] or 0,
                    'avgEngagement': round(row[4], 1) if row[4] else 0,
                    'completionRate': round((row[3] / row[2] * 100) if row[2] and row[2] > 0 else 0, 1)
                }

            return breakdown

        except Exception as e:
            logger.error(f"Content type breakdown error: {str(e)}")
            return {}

    @staticmethod
    async def get_content_engagement_trends(
        db: AsyncSession,
        timeframe: str = '30d'
    ) -> List[Dict[str, Any]]:
        """
        Get content engagement trends over time
        """
        try:
            days = ContentAnalyticsService._parse_timeframe(timeframe)
            start_date = datetime.utcnow() - timedelta(days=days)

            # Get daily engagement metrics
            trends_query = await db.execute("""
                SELECT
                    DATE(cv.created_at) as date,
                    COUNT(cv.id) as daily_views,
                    AVG(cv.watch_time_seconds) as avg_watch_time,
                    COUNT(CASE WHEN cv.completed THEN 1 END) as daily_completions
                FROM content_views cv
                WHERE cv.created_at >= :start_date
                GROUP BY DATE(cv.created_at)
                ORDER BY date
            """, {'start_date': start_date})

            trends = []
            for row in trends_query:
                date, views, avg_watch_time, completions = row
                trends.append({
                    'date': date.isoformat(),
                    'views': views,
                    'avgWatchTime': round((avg_watch_time or 0) / 60, 1),  # Convert to minutes
                    'completions': completions or 0,
                    'completionRate': round((completions / views * 100) if views and views > 0 else 0, 1)
                })

            return trends

        except Exception as e:
            logger.error(f"Content engagement trends error: {str(e)}")
            return []

    @staticmethod
    def _parse_timeframe(timeframe: str) -> int:
        """Parse timeframe string to days"""
        timeframe_map = {
            '7d': 7,
            '30d': 30,
            '90d': 90,
            '1y': 365
        }
        return timeframe_map.get(timeframe, 30)

    @staticmethod
    async def _calculate_growth(db: AsyncSession, metric: str, days: int) -> float:
        """Calculate growth percentage for a metric"""
        try:
            # Simplified growth calculation
            return 15.3  # Placeholder growth percentage
        except Exception:
            return 0.0

    @staticmethod
    async def _get_peak_engagement_time(db: AsyncSession, days: int) -> str:
        """Get peak engagement time"""
        try:
            # Simplified implementation
            return "2:00 PM - 4:00 PM"
        except Exception:
            return "N/A"

    @staticmethod
    def _get_most_popular_type(content_items: List[Any]) -> str:
        """Get most popular content type"""
        try:
            type_counts = {}
            for item in content_items:
                content_type = item.content_type or 'other'
                type_counts[content_type] = type_counts.get(content_type, 0) + item.views_count

            if not type_counts:
                return 'N/A'

            return max(type_counts.items(), key=lambda x: x[1])[0].title()
        except Exception:
            return 'N/A'

    @staticmethod
    async def _calculate_avg_session_time(db: AsyncSession, days: int) -> float:
        """Calculate average session time"""
        try:
            # Simplified implementation
            return 8.5  # minutes
        except Exception:
            return 0.0

    @staticmethod
    def _get_empty_analytics() -> Dict[str, Any]:
        """Return empty analytics structure"""
        return {
            'totalViews': 0,
            'avgWatchTime': 0,
            'completionRate': 0,
            'viewsGrowth': 0,
            'watchTimeGrowth': 0,
            'completionGrowth': 0,
            'topContent': [],
            'peakTime': 'N/A',
            'popularType': 'N/A',
            'avgSessionTime': 0
        }
```

## 7. Implementation Recommendations

### 7.1 Development Phases

#### Phase 1: Essential Dashboards (MVP)
- Customer dashboard with basic KPIs
- Agent dashboard with revenue metrics
- Simple chart visualizations
- Basic real-time updates

#### Phase 2: Advanced Analytics (Growth)
- Predictive analytics integration
- Customer segmentation features
- Interactive chart components
- Mobile-optimized dashboards

#### Phase 3: AI-Powered Intelligence (Scale)
- Machine learning model integration
- Automated insight generation
- Advanced personalization
- Real-time collaboration features

### 7.2 Technology Stack Integration

#### Backend (Python)
- **FastAPI**: Real-time API endpoints for dashboard data
- **Apache Kafka**: Event streaming for real-time analytics
- **Redis**: High-performance caching for dashboard data
- **PostgreSQL**: Time-series data storage for analytics
- **Scikit-learn**: Machine learning models for predictions

#### Frontend (Flutter)
- **Charts Flutter**: Interactive chart components
- **WebSocket**: Real-time data updates
- **Provider**: State management for dashboard data
- **Shared Preferences**: Local dashboard preferences
- **Flutter Animate**: Smooth animations and transitions

#### AI/ML Services
- **TensorFlow/PyTorch**: Predictive modeling
- **Apache Spark**: Big data analytics processing
- **Elasticsearch**: Advanced search and filtering
- **Grafana**: Dashboard visualization (Optional)

#### Infrastructure
- **Apache Kafka**: Real-time event streaming
- **Redis Cluster**: High-performance caching
- **InfluxDB**: Time-series database for metrics
- **Prometheus**: Monitoring and alerting

This smart dashboard design provides comprehensive, intelligent, and user-friendly business intelligence capabilities for Agent Mitra, enabling data-driven decision making for both customers and agents while maintaining the highest standards of security and performance.

**Ready for your review! Please let me know if you'd like me to proceed with the remaining deliverables or make any adjustments to this smart dashboard design.**
