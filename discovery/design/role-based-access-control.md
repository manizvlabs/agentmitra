# Agent Mitra - Role-Based Access Control (RBAC) Design

> **Note:** This document applies [Separation of Concerns](./glossary.md#separation-of-concerns) by implementing distinct access control mechanisms for mobile app users, configuration portal agents, and LIC system administrators.

## 1. RBAC Philosophy & Architecture

### 1.1 Core Principles
- **Feature Flag Integration**: Every role's permissions are controlled by feature flags that can be toggled by super admins without code deployment
- **Hierarchical Permissions**: Roles inherit permissions from lower-level roles while adding specific capabilities
- **Tenant-Based Isolation**: Permissions respect tenant boundaries in the multitenant architecture
- **Dynamic Permission Checking**: App checks permissions on every action and screen load
- **Audit Trail**: All permission-related actions are logged for compliance and security

### 1.2 RBAC Architecture Components

```
┌─────────────────────────────────────────────────────────┐
│                    RBAC System Architecture              │
├─────────────────────────────────────────────────────────┤
│  🎛️ Feature Flags (Super Admin Controlled)            │
│  ├── Customer Portal Features                          │
│  ├── Agent Portal Features                             │
│  ├── Provider Portal Features                          │
│  └── Admin Panel Features                              │
├─────────────────────────────────────────────────────────┤
│  👥 User Roles (Hierarchical)                           │
│  ├── Super Admin (Full Access)                         │
│  ├── Insurance Provider Admin (Tenant Admin)           │
│  ├── Regional Manager (Multi-Agent Oversight)          │
│  ├── Senior Agent (Advanced Features)                  │
│  ├── Junior Agent (Basic Features)                    │
│  ├── Policyholder (Customer Portal)                   │
│  ├── Support Staff (Limited Admin)                     │
│  └── Guest User (Trial/Limited Access)                │
├─────────────────────────────────────────────────────────┤
│  🔐 Permissions (Granular Access Control)              │
│  ├── Read Access (View Data)                           │
│  ├── Write Access (Create/Edit Data)                   │
│  ├── Delete Access (Remove Data)                      │
│  ├── Admin Access (System Configuration)               │
│  ├── Export Access (Data Export)                       │
│  └── API Access (Integration Permissions)              │
└─────────────────────────────────────────────────────────┘
```

## 2. Proposed Role Hierarchy & Permissions

### 2.1 Super Admin (Platform Owner)
**Description**: Full system access with complete control over all tenants and features
**Key Responsibilities**: Platform management, feature flag control, system configuration, user management across all tenants

**Core Permissions**:
- ✅ **Full System Access**: Complete read/write/delete access to all data across all tenants
- ✅ **Feature Flag Management**: Enable/disable any feature for any tenant or globally
- ✅ **User Management**: Create, modify, suspend any user account across all roles
- ✅ **Tenant Management**: Create new tenants, assign providers, configure tenant settings
- ✅ **System Configuration**: Modify system settings, integrations, security policies
- ✅ **Audit & Compliance**: Access all audit logs, compliance reports, security monitoring
- ✅ **Financial Control**: Access all financial data, subscription management, billing
- ✅ **Analytics**: View platform-wide analytics, performance metrics, business intelligence

**Feature Flag Control**:
- Can toggle ALL feature flags for any tenant or globally
- Can create new feature flags and assign them to specific roles
- Can set feature flag values that override default permissions

### 2.2 Insurance Provider Admin (Tenant Administrator)
**Description**: Administrative control within their specific insurance provider tenant
**Key Responsibilities**: Manage agents, products, and operations within their provider

**Core Permissions**:
- ✅ **Tenant Management**: Full control within their tenant (agents, customers, products)
- ✅ **Agent Management**: Onboard, manage, and supervise all agents in their network
- ✅ **Product Management**: Configure insurance products, pricing, and features
- ✅ **Customer Data Access**: View all customer data within their tenant
- ✅ **Analytics Dashboard**: Provider-level analytics and reporting
- ✅ **Financial Reporting**: Revenue, commissions, and financial performance within tenant
- ✅ **Support Management**: Handle escalations within their tenant
- ✅ **Compliance Monitoring**: Ensure IRDAI compliance within their operations

**Feature Flag Control**:
- Can control feature flags specific to their tenant
- Can enable/disable features for their agents and customers
- Cannot modify global platform features

### 2.3 Regional Manager (Multi-Agent Supervisor)
**Description**: Oversees multiple agents within a geographic region or business unit
**Key Responsibilities**: Team management, performance monitoring, regional strategy

**Core Permissions**:
- ✅ **Team Management**: Supervise and manage multiple agents under their oversight
- ✅ **Performance Analytics**: View performance metrics for their team of agents
- ✅ **Customer Oversight**: Access customer data for agents under their supervision
- ✅ **Training Management**: Assign training content and track completion
- ✅ **Lead Distribution**: Distribute leads among team members
- ✅ **Regional Reporting**: Generate reports for their specific region/unit
- ✅ **Escalation Handling**: Handle customer escalations from their team

**Feature Flag Control**:
- Can control feature flags for their team of agents
- Can enable/disable features for customers of their agents
- Limited to their geographic/organizational scope

### 2.4 Senior Agent (Experienced Insurance Professional)
**Description**: Established agents with advanced features and larger customer base
**Key Responsibilities**: Customer management, business development, team leadership

**Core Permissions**:
- ✅ **Advanced Customer Management**: Full CRM capabilities with segmentation and analytics
- ✅ **Marketing Campaigns**: Create and manage sophisticated marketing campaigns
- ✅ **Content Management**: Upload and manage training videos and marketing materials
- ✅ **ROI Analytics**: Detailed revenue tracking, commission analysis, performance metrics
- ✅ **Lead Management**: Advanced lead scoring, nurturing, and conversion tracking
- ✅ **Team Coordination**: If leading junior agents, basic team management features
- ✅ **Premium Support**: Access to priority support and advanced features

**Feature Flag Control**:
- Can control feature flags for their own customers
- Can enable/disable basic features for their customer base
- Access to advanced agent features

### 2.5 Junior Agent (New/Developing Insurance Agent)
**Description**: Entry-level agents building their customer base and experience
**Key Responsibilities**: Customer acquisition, basic customer service, learning and development

**Core Permissions**:
- ✅ **Basic Customer Management**: Essential CRM features for customer relationship management
- ✅ **Standard Communication**: Email, SMS, and WhatsApp integration for customer communication
- ✅ **Policy Management**: View and manage customer policies, process basic transactions
- ✅ **Learning Center Access**: Full access to training materials and educational content
- ✅ **Basic Analytics**: Essential performance metrics and customer insights
- ✅ **Lead Management**: Basic lead tracking and follow-up capabilities
- ✅ **Support Access**: Standard customer support features and help resources

**Feature Flag Control**:
- Limited feature flag control (primarily for their own customers)
- Basic feature toggles for essential functionality
- Cannot access advanced agent features

### 2.6 Policyholder (End Customer)
**Description**: Insurance policy owners using the customer portal
**Key Responsibilities**: Policy management, premium payments, communication with agent

**Core Permissions**:
- ✅ **Policy Dashboard**: View all personal policies, coverage details, and status
- ✅ **Premium Payments**: Make payments, view payment history, set up auto-payments
- ✅ **Document Access**: Download policy documents, receipts, and certificates
- ✅ **Communication**: Message agent, use chatbot, access WhatsApp integration
- ✅ **Learning Center**: Access educational content and video tutorials
- ✅ **Profile Management**: Update personal information and preferences
- ✅ **Claim Filing**: Basic claim initiation and status tracking
- ✅ **Notification Management**: Control app notifications and preferences

**Feature Flag Control**:
- No feature flag control (consumer role)
- Features enabled/disabled by their agent's configuration
- Limited to customer portal features only

### 2.7 Support Staff (Customer Service & Technical Support)
**Description**: Customer service representatives and technical support personnel
**Key Responsibilities**: Customer assistance, issue resolution, basic troubleshooting

**Core Permissions**:
- ✅ **Customer Inquiry Handling**: Access customer data for support purposes
- ✅ **Basic Troubleshooting**: Limited administrative access for issue resolution
- ✅ **Communication Tools**: Access to customer communication history
- ✅ **Knowledge Base Management**: Update FAQ and help content
- ✅ **Ticket Management**: Create and manage support tickets
- ✅ **Escalation Protocols**: Escalate complex issues to appropriate teams
- ✅ **Reporting Access**: Basic support metrics and performance reports

**Feature Flag Control**:
- Limited feature flag control for support-specific features
- Can enable/disable help and support features
- No access to core business features

### 2.8 Guest User (Trial/Prospective User)
**Description**: Users in trial period or exploring the platform
**Key Responsibilities**: Platform evaluation, basic feature exploration

**Core Permissions**:
- ✅ **Trial Feature Access**: Limited access to core features during trial period
- ✅ **Demo Content**: Access to sample policies and demo functionality
- ✅ **Basic Communication**: Limited chatbot and help features
- ✅ **Registration Process**: Account creation and verification
- ✅ **Feature Preview**: View available features and pricing information

**Feature Flag Control**:
- Minimal feature flag access (trial features only)
- Automatically disabled after trial period unless subscribed
- Very limited permissions

## 3. Permission Matrix by Feature Category

### 3.1 Customer Portal Features

| Feature | Policyholder | Guest User | Junior Agent | Senior Agent | Regional Manager | Provider Admin | Super Admin |
|---------|-------------|------------|-------------|-------------|----------------|----------------|-------------|
| Dashboard View | ✅ Full | ✅ Limited | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Policy Management | ✅ Full | ❌ | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Premium Payments | ✅ Full | ❌ | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Document Access | ✅ Full | ✅ Demo | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Communication Tools | ✅ Full | ✅ Basic | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Learning Center | ✅ Full | ✅ Limited | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |
| Profile Management | ✅ Full | ✅ Basic | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full |

### 3.2 Agent Portal Features

| Feature | Policyholder | Guest User | Junior Agent | Senior Agent | Regional Manager | Provider Admin | Super Admin |
|---------|-------------|------------|-------------|-------------|----------------|----------------|-------------|
| Customer Management | ❌ | ❌ | ✅ Basic | ✅ Advanced | ✅ Team | ✅ Full | ✅ Full |
| Marketing Campaigns | ❌ | ❌ | ✅ Basic | ✅ Advanced | ✅ Team | ✅ Full | ✅ Full |
| Content Management | ❌ | ❌ | ✅ Basic | ✅ Full | ✅ Team | ✅ Full | ✅ Full |
| ROI Analytics | ❌ | ❌ | ✅ Basic | ✅ Advanced | ✅ Team | ✅ Full | ✅ Full |
| Commission Tracking | ❌ | ❌ | ✅ Basic | ✅ Advanced | ✅ Team | ✅ Full | ✅ Full |
| Lead Management | ❌ | ❌ | ✅ Basic | ✅ Advanced | ✅ Team | ✅ Full | ✅ Full |

### 3.3 Administrative Features

| Feature | Policyholder | Guest User | Junior Agent | Senior Agent | Regional Manager | Provider Admin | Super Admin |
|---------|-------------|------------|-------------|-------------|----------------|----------------|-------------|
| User Management | ❌ | ❌ | ❌ | ❌ | ✅ Team | ✅ Tenant | ✅ Full |
| Feature Flag Control | ❌ | ❌ | ❌ | ❌ | ✅ Limited | ✅ Tenant | ✅ Full |
| System Configuration | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ Tenant | ✅ Full |
| Audit & Compliance | ❌ | ❌ | ❌ | ❌ | ✅ Team | ✅ Tenant | ✅ Full |
| Financial Management | ❌ | ❌ | ❌ | ✅ Basic | ✅ Team | ✅ Full | ✅ Full |
| Analytics Platform | ❌ | ❌ | ✅ Basic | ✅ Advanced | ✅ Team | ✅ Full | ✅ Full |

## 4. Feature Flag Integration

### 4.1 Feature Flag Categories

#### Customer Portal Feature Flags
- `customer_dashboard_enabled`
- `policy_management_enabled`
- `premium_payments_enabled`
- `document_access_enabled`
- `communication_tools_enabled`
- `learning_center_enabled`
- `profile_management_enabled`
- `whatsapp_integration_enabled`
- `chatbot_assistance_enabled`
- `video_tutorials_enabled`

#### Agent Portal Feature Flags
- `agent_dashboard_enabled`
- `customer_management_enabled`
- `marketing_campaigns_enabled`
- `content_management_enabled`
- `roi_analytics_enabled`
- `commission_tracking_enabled`
- `lead_management_enabled`
- `advanced_analytics_enabled`
- `team_management_enabled`
- `regional_oversight_enabled`

#### Administrative Feature Flags
- `user_management_enabled`
- `feature_flag_control_enabled`
- `system_configuration_enabled`
- `audit_compliance_enabled`
- `financial_management_enabled`
- `tenant_management_enabled`
- `provider_administration_enabled`

### 4.2 Feature Flag Implementation

#### Real-time Flag Checking
```javascript
// Example implementation in Flutter
class FeatureFlagService {
  static Future<bool> isFeatureEnabled(String flagName) async {
    // Check cache first
    if (_flagCache.containsKey(flagName)) {
      return _flagCache[flagName];
    }

    // Fetch from API
    final response = await api.getFeatureFlags();
    _flagCache = response.flags;

    return _flagCache[flagName] ?? false;
  }

  static void clearCache() {
    _flagCache.clear();
  }
}
```

#### UI Conditional Rendering
```dart
// Example in Flutter widget
class CustomerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: FeatureFlagService.isFeatureEnabled('customer_dashboard_enabled'),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return TrialExpiredScreen();
        }

        return Scaffold(
          // Dashboard content
        );
      },
    );
  }
}
```

## 5. Role Assignment & Management

### 5.1 Role Assignment Workflow

```
┌─────────────────────────────────────────────────────────┐
│                 Role Assignment Process                 │
├─────────────────────────────────────────────────────────┤
│  1. User Registration/Onboarding                        │
│  2. Initial Role Assignment (Basic → Trial User)        │
│  3. Email Verification & Profile Completion             │
│  4. Agent Application (if applicable)                   │
│  5. Background Verification & Approval                  │
│  6. Role Upgrade (Trial → Junior Agent/Senior Agent)    │
│  7. Feature Flag Configuration                          │
│  8. Access Provisioning & Welcome Email                 │
└─────────────────────────────────────────────────────────┘
```

### 5.2 Role Transition Rules

#### Policyholder Journey
```
Trial User (14 days) → Policyholder (Subscription Paid)
                        ↓
                    Premium Policyholder (Advanced Features)
```

#### Agent Journey
```
Trial User (14 days) → Junior Agent (New Agent Subscription)
                        ↓
                    Senior Agent (Performance-Based Upgrade)
                        ↓
                    Regional Manager (Team Leadership Role)
```

#### Provider Journey
```
Insurance Provider Application → Provider Admin (Approved)
                                   ↓
                               Super Provider (Multiple Regions)
```

## 6. Security & Compliance Considerations

### 6.1 Data Access Controls

#### Row-Level Security
- Users can only access data related to their customers/tenants
- Agents cannot access customers of other agents (unless supervisors)
- Providers cannot access data from competing providers

#### API-Level Security
- All API endpoints check role permissions before processing
- JWT tokens include role and tenant information
- API rate limiting based on role (higher limits for admins)

### 6.2 Audit & Compliance

#### Comprehensive Logging
- All role-based access actions logged with timestamps
- Feature flag changes tracked with before/after values
- Failed permission checks logged for security monitoring

#### Compliance Reporting
- IRDAI compliance reports showing data access patterns
- DPDP compliance tracking for data privacy
- Regular access reviews and certification processes

## 7. Implementation Recommendations

### 7.1 Development Approach

#### Phase 1: Basic RBAC (MVP)
- Implement core roles: Policyholder, Junior Agent, Super Admin
- Basic feature flags for essential features
- Simple permission checking system

#### Phase 2: Advanced RBAC (Growth)
- Add remaining roles: Senior Agent, Regional Manager, Provider Admin
- Implement hierarchical permissions
- Advanced feature flag management

#### Phase 3: Enterprise RBAC (Scale)
- Multi-tenant isolation
- Advanced audit and compliance features
- Performance optimization for large-scale deployments

### 7.2 Technology Stack Considerations

#### Backend (Python)
- **Django**: Built-in authentication and permission system
- **Django REST Framework**: API-level permission classes
- **Django Guardian**: Object-level permissions for fine-grained access

#### Frontend (Flutter)
- **Provider Pattern**: State management for user permissions
- **Dio/Http Client**: API calls with JWT token management
- **Shared Preferences**: Local caching of permissions

#### Database Design
- **User Table**: Basic user information and role assignment
- **Role Table**: Role definitions and hierarchies
- **Permission Table**: Granular permissions linked to roles
- **Feature Flag Table**: Dynamic feature configuration
- **Audit Log Table**: Complete audit trail for compliance

This RBAC design provides a comprehensive, scalable, and secure foundation for your multitenant Agent Mitra platform while ensuring compliance with Indian regulatory requirements and supporting your feature flag-driven architecture.

**Ready for your review! Please let me know if you'd like me to modify any roles, add additional roles, or adjust the permission structure before I proceed with the wireframes and other deliverables.**
