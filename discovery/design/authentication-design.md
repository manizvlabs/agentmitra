# Agent Mitra - Authentication & Security Architecture Design

## 1. Authentication Philosophy & Architecture

### 1.1 Core Security Principles
- **Multi-Factor Authentication (MFA)**: Support for SMS OTP, Email OTP, Biometric, and Hardware tokens
- **Session Management**: Secure token-based authentication with automatic refresh
- **Feature Flag Integration**: Authentication flows controlled by feature flags
- **IRDAI Compliance**: Regulatory compliance for financial/insurance data
- **DPDP Compliance**: Data privacy and protection standards
- **Zero-Trust Architecture**: Continuous verification of user identity and permissions

### 1.2 Authentication Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                Authentication Architecture               │
├─────────────────────────────────────────────────────────┤
│  🎭 Multi-Factor Authentication                        │
│  ├── SMS OTP (Primary)                                 │
│  ├── Email OTP (Secondary)                             │
│  ├── Biometric Authentication (Fingerprint/Face)       │
│  ├── Hardware Token (Future)                           │
│  └── mPIN Authentication (Offline)                     │
├─────────────────────────────────────────────────────────┤
│  🔐 Session Management                                 │
│  ├── JWT Access Tokens (15min expiry)                  │
│  ├── Refresh Tokens (7 days expiry)                    │
│  ├── Secure Token Storage (Encrypted)                  │
│  └── Automatic Token Refresh                           │
├─────────────────────────────────────────────────────────┤
│  🎛️ Feature Flag Integration                          │
│  ├── Conditional Auth Flows                            │
│  ├── Dynamic Security Levels                           │
│  └── Runtime Permission Updates                       │
├─────────────────────────────────────────────────────────┤
│  🔒 Security Features                                  │
│  ├── End-to-End Encryption                             │
│  ├── Rate Limiting & DDoS Protection                   │
│  ├── Audit Logging & Monitoring                       │
│  └── IRDAI/DPDP Compliance                            │
└─────────────────────────────────────────────────────────┘
```

## 2. Authentication Methods & Flows

### 2.1 Primary Authentication: Mobile Number + OTP

#### Registration Flow
```
┌─────────────────────────────────────────────────────────┐
│  📱 MOBILE NUMBER REGISTRATION                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎯 "Join Agent Mitra"                           │   │
│  │ 📝 "Connect with your insurance agent"          │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📱 Enter Mobile Number                          │   │
│  │ +91 └─────────────────────────────────────────┘   │
│  │     9876543210 (10-digit number)                │   │
│  │ 📝 We'll send OTP to verify your number         │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔄 SEND OTP (Primary CTA)                       │   │
│  │ ❓ Need Help? (Support Link)                     │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- phone_auth_enabled (Controls phone registration)
- otp_verification_enabled (Controls OTP flow)
- trial_mode_enabled (Controls trial registration)
```

#### OTP Verification Flow
```
┌─────────────────────────────────────────────────────────┐
│  🔢 OTP VERIFICATION                                   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ OTP Sent Successfully                         │   │
│  │ 📱 Enter 6-digit code sent to +91-9876543210    │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ [ ] [ ] [ ] [ ] [ ] [ ] (Input Fields)          │   │
│  │ ⏱️ Resend OTP in 00:30                          │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ VERIFY OTP (Primary CTA)                      │   │
│  │ 📞 Call Support (Alternative)                    │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Security Features:
- OTP valid for 5 minutes only
- Maximum 3 attempts before cooldown
- Rate limiting: 5 OTP requests per hour per number
- OTP logged in audit trail (encrypted)
```

### 2.2 Secondary Authentication: Email + OTP

#### Email Registration Flow
```
┌─────────────────────────────────────────────────────────┐
│  📧 EMAIL REGISTRATION                                 │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📧 Enter Email Address                          │   │
│  │ └───────────────────────────────────────────────┘   │
│  │ 📧 amit.sharma@email.com (Valid email format)   │   │
│  │ 📝 We'll send verification code to your email   │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔄 SEND CODE (Primary CTA)                      │   │
│  │ 📱 Use Phone Instead (Alternative)               │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- email_auth_enabled (Controls email registration)
- otp_verification_enabled (Controls OTP flow)
```

### 2.3 Biometric Authentication

#### Fingerprint/Face ID Setup
```
┌─────────────────────────────────────────────────────────┐
│  🔐 BIOMETRIC AUTHENTICATION                           │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔒 Enable Biometric Login                       │   │
│  │ 📱 Faster & Secure Access                       │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 👤 Use Fingerprint                              │   │
│  │ 😊 Use Face ID                                  │   │
│  │ 🔒 Use mPIN (Offline)                           │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ ENABLE BIOMETRIC (Primary CTA)                │   │
│  │ ⏭️ SKIP FOR NOW (Secondary)                     │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- biometric_auth_enabled (Controls biometric features)
- fingerprint_enabled (Fingerprint support)
- face_id_enabled (Face ID support)
- mpin_auth_enabled (Offline PIN support)
```

### 2.4 mPIN Authentication (Offline Mode)

#### mPIN Setup Flow
```
┌─────────────────────────────────────────────────────────┐
│  🔢 mPIN SETUP                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔒 Create 4-digit mPIN                          │   │
│  │ 📱 For offline access & quick login             │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ [ ] [ ] [ ] [ ] (mPIN Input)                    │   │
│  │ 👁️ Show mPIN                                   │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔒 CONFIRM mPIN                                 │   │
│  │ [ ] [ ] [ ] [ ] (Re-enter mPIN)                 │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ SET mPIN (Primary CTA)                        │   │
│  │ 🔄 CHANGE mPIN (Alternative)                     │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Security Features:
- mPIN stored encrypted locally
- Maximum 5 failed attempts before biometric fallback
- mPIN never transmitted to server
- Automatic logout after 30 days of inactivity
```

### 2.5 Login Flow with Multiple Methods

#### Unified Login Interface
```
┌─────────────────────────────────────────────────────────┐
│  👤 LOGIN - AGENT MITRA                                │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🎯 Welcome back! Sign in to continue            │   │
│  │ 🌐 Language: English • हिन्दी • తెలుగు           │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 📱 Mobile Number                                │   │
│  │ └───────────────────────────────────────────────┘   │
│  │ +91 9876543210 (Auto-filled if remembered)      │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🔐 Authentication Method                         │   │
│  │ 👤 Biometric (Fingerprint/Face)                 │   │
│  │ 🔢 mPIN (4-digit code)                          │   │
│  │ 📱 OTP (One-time password)                      │   │
│  └─────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────┐   │
│  │ 🚀 SIGN IN (Primary CTA)                        │   │
│  │ ❓ Forgot mPIN? (Recovery Link)                  │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘

Feature Flag Dependencies:
- multi_auth_methods_enabled (Multiple auth options)
- biometric_auth_enabled (Biometric support)
- mpin_auth_enabled (mPIN support)
- otp_verification_enabled (OTP support)
```

## 3. Session Management & Token Architecture

### 3.1 Token-Based Authentication

#### JWT Token Structure
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_in": 900,
  "token_type": "Bearer",
  "user_id": "user_123456",
  "role": "policyholder",
  "tenant_id": "provider_lic_001",
  "permissions": ["read_own_policies", "make_payments", "view_documents"],
  "feature_flags": {
    "customer_dashboard_enabled": true,
    "premium_payments_enabled": true,
    "whatsapp_integration_enabled": true
  }
}
```

#### Token Lifecycle Management
```
┌─────────────────────────────────────────────────────────┐
│                Token Lifecycle                          │
├─────────────────────────────────────────────────────────┤
│  🔑 Access Token (15 minutes)                          │
│  ├── API Authentication                              │
│  ├── Feature Flag Validation                         │
│  ├── Permission Checking                             │
│  └── Automatic Refresh (Before Expiry)               │
├─────────────────────────────────────────────────────────┤
│  🔄 Refresh Token (7 days)                             │
│  ├── Silent Token Renewal                            │
│  ├── Background Refresh                              │
│  └── Secure Storage (Encrypted)                      │
├─────────────────────────────────────────────────────────┤
│  🔒 Security Features                                  │
│  ├── Token Encryption at Rest                        │
│  ├── Secure Token Storage                            │
│  ├── Automatic Logout on Suspicious Activity         │
│  └── Audit Logging for Token Operations             │
└─────────────────────────────────────────────────────────┘
```

### 3.2 Session Security Features

#### Automatic Token Refresh
```dart
// Flutter implementation
class AuthService {
  Timer? _refreshTimer;
  String? _accessToken;
  String? _refreshToken;

  void startTokenRefresh() {
    // Refresh 2 minutes before expiry
    _refreshTimer = Timer.periodic(
      Duration(minutes: 13), // 15min - 2min buffer
      (timer) => _refreshAccessToken(),
    );
  }

  Future<void> _refreshAccessToken() async {
    try {
      final response = await api.refreshToken(_refreshToken!);
      _accessToken = response['access_token'];
      // Update feature flags and permissions
      await _updateUserPermissions(response['permissions']);
    } catch (e) {
      // Force logout on refresh failure
      await logout();
    }
  }
}
```

#### Secure Token Storage
```
┌─────────────────────────────────────────────────────────┐
│                Secure Token Storage                     │
├─────────────────────────────────────────────────────────┤
│  🔐 iOS Keychain (Encrypted)                           │
│  ├── Access Token (15min expiry)                     │
│  ├── Refresh Token (7 days expiry)                   │
│  ├── User Preferences (Encrypted)                    │
│  └── Biometric Keys (Hardware-backed)                │
├─────────────────────────────────────────────────────────┤
│  🔒 Android Keystore (Hardware-backed)                 │
│  ├── StrongBox (Pixel devices)                       │
│  ├── TEE (Trusted Execution Environment)             │
│  ├── Encrypted Shared Preferences                    │
│  └── Biometric Authentication Keys                   │
└─────────────────────────────────────────────────────────┘
```

## 4. Role-Based Access Control (RBAC) Integration

### 4.1 Permission Checking Architecture

#### Real-time Permission Validation
```dart
// Flutter permission checking
class PermissionService {
  static Future<bool> hasPermission(String permission) async {
    // Check local cache first
    if (_permissionCache.containsKey(permission)) {
      return _permissionCache[permission];
    }

    // Fetch from JWT token
    final token = await AuthService.getAccessToken();
    final permissions = JwtDecoder.decode(token)['permissions'];

    _permissionCache = Map.from(permissions);
    return permissions.contains(permission);
  }

  static Future<bool> canAccessFeature(String featureFlag) async {
    // Check feature flag from token
    final token = await AuthService.getAccessToken();
    final featureFlags = JwtDecoder.decode(token)['feature_flags'];

    return featureFlags[featureFlag] ?? false;
  }
}
```

#### UI Conditional Rendering Based on Permissions
```dart
// Example widget with permission checking
class PremiumPaymentButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: PermissionService.hasPermission('make_payments'),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!) {
          return SizedBox.shrink(); // Hide if no permission
        }

        return FutureBuilder<bool>(
          future: PermissionService.canAccessFeature('premium_payments_enabled'),
          builder: (context, featureSnapshot) {
            if (!featureSnapshot.hasData || !featureSnapshot.data!) {
              return DisabledPaymentButton(); // Show disabled state
            }

            return ElevatedButton(
              onPressed: () => navigateToPayment(),
              child: Text('Pay Premium'),
            );
          },
        );
      },
    );
  }
}
```

### 4.2 Role-Specific Authentication Flows

#### Policyholder Authentication
```
┌─────────────────────────────────────────────────────────┐
│  👥 POLICYHOLDER AUTHENTICATION                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Mobile OTP (Primary)                          │   │
│  │ 👤 Biometric (Secondary)                         │   │
│  │ 🔢 mPIN (Offline)                               │   │
│  └─────────────────────────────────────────────────┘   │
│  📋 Permissions Granted:                              │
│  • View own policies                               │
│  • Make premium payments                           │
│  • Download documents                             │
│  • Communicate with agent                         │
└─────────────────────────────────────────────────────────┘
```

#### Insurance Agent Authentication
```
┌─────────────────────────────────────────────────────────┐
│  💼 AGENT AUTHENTICATION                               │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Mobile OTP (Primary)                          │   │
│  │ 👤 Biometric (Secondary)                         │   │
│  │ 🔢 mPIN (Offline)                               │   │
│  └─────────────────────────────────────────────────┘   │
│  📋 Permissions Granted:                              │
│  • Manage assigned customers                       │
│  • View analytics and ROI                          │
│  • Create marketing campaigns                     │
│  • Upload content and training materials          │
└─────────────────────────────────────────────────────────┘
```

#### Insurance Provider Admin Authentication
```
┌─────────────────────────────────────────────────────────┐
│  🏢 PROVIDER ADMIN AUTHENTICATION                      │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Mobile OTP (Primary)                          │   │
│  │ 👤 Biometric (Secondary)                         │   │
│  │ 🔢 mPIN + Email OTP (Enhanced Security)         │   │
│  └─────────────────────────────────────────────────┘   │
│  📋 Permissions Granted:                              │
│  • Manage products and pricing                     │
│  • Oversee agent network                           │
│  • Configure provider settings                    │
│  • Access detailed analytics                      │
└─────────────────────────────────────────────────────────┘
```

#### Super Admin Authentication
```
┌─────────────────────────────────────────────────────────┐
│  🔧 SUPER ADMIN AUTHENTICATION                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Mobile OTP + Email OTP (Required)             │   │
│  │ 👤 Biometric (Secondary)                         │   │
│  │ 🔢 mPIN + Hardware Token (Maximum Security)     │   │
│  └─────────────────────────────────────────────────┘   │
│  📋 Permissions Granted:                              │
│  • Full system access                              │
│  • Feature flag management                        │
│  • User management across all roles                │
│  • System configuration and settings              │
└─────────────────────────────────────────────────────────┘
```

## 5. Security Features & Compliance

### 5.1 Advanced Security Measures

#### Rate Limiting & DDoS Protection
```
┌─────────────────────────────────────────────────────────┐
│                Rate Limiting Protection                 │
├─────────────────────────────────────────────────────────┤
│  📱 Authentication Endpoints                           │
│  ├── Login Attempts: 5 per minute per IP             │
│  ├── OTP Requests: 3 per hour per number             │
│  ├── Password Reset: 3 per day per email            │
│  └── API Calls: 1000 per hour per user               │
├─────────────────────────────────────────────────────────┤
│  🚫 DDoS Protection                                    │
│  ├── Cloudflare WAF (Web Application Firewall)       │
│  ├── AWS Shield (DDoS Mitigation)                    │
│  ├── Rate Limiting at Application Layer             │
│  └── Automatic IP Blocking for Suspicious Activity   │
└─────────────────────────────────────────────────────────┘
```

#### End-to-End Encryption
```
┌─────────────────────────────────────────────────────────┐
│                Data Encryption                          │
├─────────────────────────────────────────────────────────┤
│  🔐 At Rest Encryption                                 │
│  ├── Database: AES-256 encryption                    │
│  ├── File Storage: Encrypted file systems           │
│  ├── Backups: Encrypted and versioned               │
│  └── Logs: Encrypted audit trails                   │
├─────────────────────────────────────────────────────────┤
│  🔒 In Transit Encryption                              │
│  ├── TLS 1.3 (All API communications)                │
│  ├── Certificate Pinning (Mobile apps)               │
│  ├── Perfect Forward Secrecy                        │
│  └── HSTS (HTTP Strict Transport Security)           │
└─────────────────────────────────────────────────────────┘
```

### 5.2 Compliance & Audit Features

#### IRDAI Compliance
```
┌─────────────────────────────────────────────────────────┐
│                IRDAI Compliance                         │
├─────────────────────────────────────────────────────────┤
│  📋 Required Security Measures                         │
│  ├── Multi-factor authentication                     │
│  ├── Secure session management                       │
│  ├── Audit logging for all financial transactions    │
│  └── Data encryption standards                       │
├─────────────────────────────────────────────────────────┤
│  📊 Compliance Reporting                               │
│  ├── Monthly security audits                         │
│  ├── User access pattern analysis                   │
│  ├── Financial transaction logging                  │
│  └── Regulatory reporting dashboards                │
└─────────────────────────────────────────────────────────┘
```

#### DPDP Compliance (Data Privacy)
```
┌─────────────────────────────────────────────────────────┐
│                DPDP Compliance                          │
├─────────────────────────────────────────────────────────┤
│  🔒 Data Protection Measures                           │
│  ├── User consent management                         │
│  ├── Data minimization principles                    │
│  ├── Purpose limitation enforcement                  │
│  └── Right to erasure implementation                 │
├─────────────────────────────────────────────────────────┤
│  📋 Privacy Controls                                   │
│  ├── Granular privacy settings                       │
│  ├── Data export capabilities                        │
│  ├── Consent withdrawal mechanisms                   │
│  └── Privacy impact assessments                     │
└─────────────────────────────────────────────────────────┘
```

### 5.3 Audit Logging & Monitoring

#### Comprehensive Audit Trail
```
┌─────────────────────────────────────────────────────────┐
│                Audit Logging System                     │
├─────────────────────────────────────────────────────────┤
│  📋 Authentication Events                              │
│  ├── Login attempts (success/failure)                │
│  ├── OTP requests and verifications                 │
│  ├── Biometric authentication events                │
│  ├── Session creation and termination               │
└─────────────────────────────────────────────────────────┘
│  🔐 Security Events                                    │
│  ├── Permission access attempts                      │
│  ├── Feature flag changes                           │
│  ├── Role modifications                             │
│  └── Suspicious activity detection                  │
└─────────────────────────────────────────────────────────┘
│  💰 Financial Events                                   │
│  ├── Payment transactions                            │
│  ├── Commission calculations                        │
│  ├── Refund processing                              │
│  └── Subscription management                        │
└─────────────────────────────────────────────────────────┘
```

## 6. Environment Variables & Localization Integration

### 6.1 Environment-Based Configuration

#### Authentication Environment Variables
```bash
# Authentication Configuration
AUTH_OTP_EXPIRY_MINUTES=5
AUTH_MAX_LOGIN_ATTEMPTS=5
AUTH_SESSION_TIMEOUT_MINUTES=15
AUTH_REFRESH_TOKEN_EXPIRY_DAYS=7

# Security Configuration
SECURITY_RATE_LIMIT_REQUESTS_PER_MINUTE=60
SECURITY_MAX_OTP_REQUESTS_PER_HOUR=5
SECURITY_ENCRYPTION_ALGORITHM=AES-256-GCM

# Feature Flags
FEATURE_PHONE_AUTH_ENABLED=true
FEATURE_EMAIL_AUTH_ENABLED=true
FEATURE_BIOMETRIC_AUTH_ENABLED=true
FEATURE_MPIN_AUTH_ENABLED=true

# Compliance Settings
COMPLIANCE_IRDAI_ENABLED=true
COMPLIANCE_DPDP_ENABLED=true
COMPLIANCE_AUDIT_LOGGING_ENABLED=true
```

### 6.2 Localization Integration

#### Authentication Localization Keys (CDN-based)
```json
{
  "auth": {
    "welcome_title": "Welcome to Agent Mitra",
    "welcome_subtitle": "Connect with your insurance agent",
    "mobile_placeholder": "Enter mobile number",
    "otp_sent_message": "OTP sent to {phone}",
    "biometric_title": "Enable Biometric Login",
    "biometric_subtitle": "Faster & secure access",
    "mpin_title": "Create 4-digit mPIN",
    "mpin_subtitle": "For offline access",
    "login_button": "Sign In",
    "forgot_pin": "Forgot mPIN?",
    "trial_expired": "Trial expired",
    "subscribe_now": "Subscribe Now"
  },
  "errors": {
    "invalid_otp": "Invalid OTP. Please try again.",
    "too_many_attempts": "Too many attempts. Please try again later.",
    "session_expired": "Session expired. Please login again.",
    "biometric_not_available": "Biometric authentication not available.",
    "network_error": "Network error. Please check your connection."
  },
  "security": {
    "secure_payment": "Secure Payment",
    "irdai_compliant": "IRDAI Compliant",
    "data_encrypted": "Data Encrypted",
    "audit_logged": "Audit Logged"
  }
}
```

#### Runtime Localization Loading
```dart
// Flutter localization service
class LocalizationService {
  static Map<String, dynamic> _localizedStrings = {};

  static Future<void> loadLocalization(String languageCode) async {
    // Load from CDN based on environment
    final cdnUrl = Environment.cdnBaseUrl;
    final response = await http.get('$cdnUrl/localization/$languageCode.json');

    if (response.statusCode == 200) {
      _localizedStrings = json.decode(response.body);
    }
  }

  static String getString(String key) {
    return _localizedStrings[key] ?? key;
  }

  static String getStringWithParams(String key, Map<String, String> params) {
    String result = _localizedStrings[key] ?? key;
    params.forEach((param, value) {
      result = result.replaceAll('{$param}', value);
    });
    return result;
  }
}
```

## 7. Trial & Subscription Integration

### 7.1 Trial Period Authentication

#### Trial User Authentication Flow
```
┌─────────────────────────────────────────────────────────┐
│  🎁 TRIAL USER AUTHENTICATION                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Mobile OTP (Primary)                          │   │
│  │ 👤 Basic Profile Setup                          │   │
│  │ 📅 Trial Period: 14 days                        │   │
│  └─────────────────────────────────────────────────┘   │
│  📋 Trial Permissions:                                │
│  • Limited feature access                          │
│  • Demo content and sample policies                │
│  • Basic communication tools                       │
│  • Learning center access                          │
└─────────────────────────────────────────────────────────┘
```

#### Trial Expiration Handling
```dart
// Automatic trial expiration checking
class TrialService {
  static Future<bool> isTrialExpired() async {
    final user = await AuthService.getCurrentUser();
    if (user.role != 'guest') return false;

    final trialEndDate = user.trialEndDate;
    return DateTime.now().isAfter(trialEndDate);
  }

  static Future<void> handleTrialExpiration() async {
    if (await isTrialExpired()) {
      // Disable features based on feature flags
      await FeatureFlagService.disableTrialFeatures();

      // Show subscription screen
      navigator.push(SubscriptionScreen());
    }
  }
}
```

### 7.2 Subscription Authentication

#### Post-Subscription Authentication
```
┌─────────────────────────────────────────────────────────┐
│  💳 SUBSCRIPTION AUTHENTICATION                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │ ✅ Existing Authentication Methods               │   │
│  │ 💰 Subscription Verification                     │   │
│  │ 📅 Next Billing: DD/MM/YYYY                     │   │
│  └─────────────────────────────────────────────────┘   │
│  📋 Full Access Permissions:                          │
│  • Complete feature access                         │
│  • All customer portal features                    │
│  • Advanced agent tools (if applicable)            │
│  • Premium support access                          │
└─────────────────────────────────────────────────────────┘
```

## 8. Implementation Recommendations

### 8.1 Development Phases

#### Phase 1: Basic Authentication (MVP)
- Mobile OTP authentication
- Basic session management
- Simple role-based permissions
- Trial period support

#### Phase 2: Enhanced Security (Growth)
- Biometric authentication
- Advanced rate limiting
- Comprehensive audit logging
- Multi-factor authentication

#### Phase 3: Enterprise Security (Scale)
- Hardware token support
- Advanced compliance features
- Zero-trust architecture
- Automated security monitoring

### 8.2 Technology Stack Integration

#### Backend (Python)
- **Django REST Framework**: Authentication classes and JWT handling
- **Django Guardian**: Object-level permissions
- **PyJWT**: Token generation and validation
- **Cryptography**: Encryption and security utilities

#### Frontend (Flutter)
- **Dio**: HTTP client with JWT interceptor
- **Local Authentication**: Biometric authentication
- **Flutter Secure Storage**: Encrypted local storage
- **Provider**: State management for auth state

#### Infrastructure
- **Redis**: Session storage and rate limiting
- **PostgreSQL**: User data and audit logs
- **AWS Cognito**: Identity management (optional)
- **Cloudflare**: DDoS protection and CDN

This authentication design provides a comprehensive, secure, and user-friendly foundation for Agent Mitra while ensuring compliance with Indian regulatory requirements and supporting the feature flag-driven architecture.

**Ready for your review! Please let me know if you'd like me to proceed with the remaining deliverables or make any adjustments to this authentication design.**
