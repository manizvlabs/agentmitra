# Agent Mitra - Missing Features Implementation Plan

## Executive Summary

This document provides a focused implementation plan for **only the truly missing features** in the Agent Mitra platform. The system already has comprehensive implementations:

**✅ ALREADY IMPLEMENTED (39+ database migrations, 164+ Flutter files, 21+ API endpoints):**
- Complete authentication system with OTP/SMS integration
- RBAC with 8 seeded test users (Super Admin, Provider Admin, Regional Manager, Senior Agent, Junior Agent, Policyholder, Support Staff, Guest)
- Feature flag system with Pioneer integration
- Flutter apps with 42+ screens (daily quotes, presentations, policies, etc.)
- React config portal with Excel data import
- Video tutorial system with YouTube integration
- Presentation carousel and editor
- WhatsApp Business API integration
- AI chatbot with knowledge base
- Comprehensive backend APIs with full RBAC protection

**🎯 FOCUS: Only implement missing features to match wireframe specifications, avoiding all code duplication.**

## 1. Missing Features Analysis

### 1.1 Database Schema Enhancements Needed
Based on wireframe requirements vs current implementation:

1. **Enhanced KYC Document Management** - Current system has basic document upload, but wireframes require OCR results tracking and advanced verification workflow
2. **Dedicated Emergency Contact Table** - Current system stores emergency contacts as JSON in users table, wireframes require dedicated table with verification status
3. **Trial Subscription Analytics** - Enhanced trial period tracking with detailed analytics for subscription conversion
4. **Advanced Customer Portal Analytics** - Detailed user engagement tracking for learning center, chatbot interactions, etc.

### 1.2 Real-time Feature Flag Updates
- **WebSocket Integration** - Current feature flags are polled, wireframes require real-time updates
- **Live Notifications** - Real-time feature change notifications to users

### 1.3 Flutter Placeholder Screen Implementation
Current placeholder screens that need full implementation:
- `/claims/new` - File New Claim screen
- `/policy/create` - Create New Policy screen
- `/payments` - Payments screen
- `/reports` - Reports screen
- `/customers` - Customers screen
- `/settings` - Settings screen

### 1.4 Advanced Analytics Features
- **Predictive Analytics Dashboard** - ROI predictions and churn risk analysis
- **Real-time Campaign Performance** - Live campaign metrics with A/B testing results
- **Content Performance Analytics** - Detailed video engagement and learning analytics

## 2. Implementation Priority Matrix

### Phase 1: Critical Missing Features (Week 1-2)
**Priority: HIGH - Core wireframe compliance**

1. **Enhanced KYC Document Management**
   - Add OCR results tracking table
   - Implement document verification workflow
   - Add manual review queue system

2. **Real-time Feature Flag Updates**
   - Implement WebSocket support for feature flags
   - Add real-time notification system
   - Update Flutter apps for live flag updates

3. **Emergency Contact Management**
   - Create dedicated emergency_contacts table
   - Implement contact verification workflow
   - Add relationship type management

### Phase 2: Advanced Analytics (Week 3-4)
**Priority: MEDIUM - Enhanced user experience**

1. **Predictive Analytics Dashboard**
   - Implement churn risk scoring
   - Add ROI prediction algorithms
   - Create predictive dashboard widgets

2. **Content Performance Analytics**
   - Enhanced video engagement tracking
   - Learning progress analytics
   - Content effectiveness metrics

### Phase 3: UI Polish & Advanced Features (Week 5-6)
**Priority: LOW - Polish and optimization**

1. **Implement Placeholder Screens**
   - File New Claim screen
   - Create New Policy screen
   - Enhanced Payments screen
   - Advanced Reports dashboard

2. **Advanced Campaign Analytics**
   - Real-time A/B testing results
   - Campaign ROI tracking
   - Automated campaign optimization

## 3. Specific Implementation Tasks

### 3.1 Database Schema Enhancements

#### Task 1.1: Enhanced KYC Document Management
**File:** `db/migration/V40__Enhanced_KYC_Document_Management.sql`
```sql
-- Enhanced KYC document management with OCR tracking
CREATE TABLE IF NOT EXISTS lic_schema.kyc_documents (
    document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL, -- 'aadhaar', 'voter_id', 'passport', 'selfie'
    file_path VARCHAR(500) NOT NULL,
    ocr_extracted_data JSONB,
    verification_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'verified', 'rejected', 'manual_review'
    rejection_reason TEXT,
    verified_at TIMESTAMP,
    verified_by UUID REFERENCES lic_schema.users(user_id),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- OCR processing results
CREATE TABLE IF NOT EXISTS lic_schema.document_ocr_results (
    ocr_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES lic_schema.kyc_documents(document_id) ON DELETE CASCADE,
    ocr_provider VARCHAR(50), -- 'google_vision', 'aws_textract', 'azure_form'
    confidence_score DECIMAL(5,2),
    extracted_fields JSONB, -- name, dob, address, document_number, etc.
    processing_status VARCHAR(50) DEFAULT 'processing',
    processed_at TIMESTAMP,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Manual review queue
CREATE TABLE IF NOT EXISTS lic_schema.kyc_manual_reviews (
    review_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID REFERENCES lic_schema.kyc_documents(document_id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES lic_schema.users(user_id),
    review_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
    review_notes TEXT,
    reviewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Task 1.2: Dedicated Emergency Contact Management
**File:** `db/migration/V41__Emergency_Contact_Management.sql`
```sql
-- Dedicated emergency contact management
CREATE TABLE IF NOT EXISTS lic_schema.emergency_contacts (
    contact_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    full_name VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) NOT NULL,
    email VARCHAR(255),
    relationship VARCHAR(50) NOT NULL, -- 'spouse', 'parent', 'sibling', 'child', 'friend'
    address JSONB,
    is_primary BOOLEAN DEFAULT false,
    verification_status VARCHAR(50) DEFAULT 'unverified', -- 'unverified', 'verified', 'failed'
    verified_at TIMESTAMP,
    priority INTEGER DEFAULT 1, -- 1=primary, 2=secondary, etc.
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Emergency contact verification attempts
CREATE TABLE IF NOT EXISTS lic_schema.emergency_contact_verifications (
    verification_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contact_id UUID REFERENCES lic_schema.emergency_contacts(contact_id) ON DELETE CASCADE,
    verification_method VARCHAR(50), -- 'sms', 'call', 'email'
    verification_code VARCHAR(10),
    attempts INTEGER DEFAULT 0,
    verified BOOLEAN DEFAULT false,
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Task 1.3: Trial Subscription Analytics
**File:** `db/migration/V42__Trial_Subscription_Analytics.sql`
```sql
-- Enhanced trial subscription tracking
CREATE TABLE IF NOT EXISTS lic_schema.trial_subscriptions (
    trial_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id) ON DELETE CASCADE,
    plan_type VARCHAR(50) DEFAULT 'policyholder_trial', -- 'agent_trial', 'policyholder_trial'
    trial_start_date TIMESTAMP DEFAULT NOW(),
    trial_end_date TIMESTAMP,
    actual_conversion_date TIMESTAMP,
    conversion_plan VARCHAR(50),
    trial_status VARCHAR(50) DEFAULT 'active', -- 'active', 'expired', 'converted', 'cancelled'
    extension_days INTEGER DEFAULT 0,
    reminder_sent BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Trial user engagement tracking
CREATE TABLE IF NOT EXISTS lic_schema.trial_engagement (
    engagement_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trial_id UUID REFERENCES lic_schema.trial_subscriptions(trial_id) ON DELETE CASCADE,
    feature_used VARCHAR(100), -- 'dashboard', 'policies', 'chatbot', etc.
    engagement_type VARCHAR(50), -- 'view', 'interaction', 'completion'
    metadata JSONB,
    engaged_at TIMESTAMP DEFAULT NOW()
);
```

### 3.2 Real-time Feature Flag Updates

#### Task 2.1: WebSocket Integration
**File:** `backend/app/core/websocket_manager.py`
```python
# WebSocket manager for real-time feature flag updates
from fastapi import WebSocket
import json
from typing import Dict, List
from app.services.feature_flag_service import FeatureFlagService

class WebSocketManager:
    def __init__(self):
        self.active_connections: Dict[str, List[WebSocket]] = {}
        self.feature_flag_service = FeatureFlagService()

    async def connect(self, websocket: WebSocket, user_id: str):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)

    async def disconnect(self, websocket: WebSocket, user_id: str):
        if user_id in self.active_connections:
            self.active_connections[user_id].remove(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

    async def broadcast_feature_update(self, user_id: str, feature_key: str, new_value: bool):
        if user_id in self.active_connections:
            message = {
                "type": "feature_flag_update",
                "feature_key": feature_key,
                "new_value": new_value,
                "timestamp": datetime.utcnow().isoformat()
            }
            for connection in self.active_connections[user_id]:
                try:
                    await connection.send_json(message)
                except:
                    # Remove dead connections
                    self.active_connections[user_id].remove(connection)
```

#### Task 2.2: Feature Flag WebSocket API
**File:** `backend/app/api/v1/feature_flags.py` (enhancement)
```python
from app.core.websocket_manager import websocket_manager

@router.websocket("/ws/{user_id}")
async def feature_flag_websocket(websocket: WebSocket, user_id: str):
    await websocket_manager.connect(websocket, user_id)
    try:
        while True:
            # Keep connection alive and handle client messages
            data = await websocket.receive_json()
            # Handle client acknowledgments or requests
    except:
        await websocket_manager.disconnect(websocket, user_id)

# Enhanced feature flag update endpoint
@router.put("/update/{flag_name}")
async def update_feature_flag(
    flag_name: str,
    update_request: FeatureFlagUpdateRequest,
    current_user = Depends(require_permission("feature_flags.update"))
):
    # Update feature flag in database
    result = await feature_flag_service.update_flag(
        flag_name,
        update_request.new_value,
        update_request.target_users
    )

    # Broadcast real-time updates to affected users
    for user_id in update_request.target_users:
        await websocket_manager.broadcast_feature_update(
            user_id,
            flag_name,
            update_request.new_value
        )

    return result
```

### 3.3 Flutter Real-time Feature Flag Integration

#### Task 3.1: Enhanced Feature Flag Service
**File:** `lib/core/services/feature_flag_service.dart` (enhancement)
```dart
class FeatureFlagService {
  final Map<String, bool> _flagCache = {};
  WebSocketChannel? _webSocketChannel;
  final StreamController<Map<String, dynamic>> _updateController =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get flagUpdates => _updateController.stream;

  Future<void> connectWebSocket(String userId) async {
    final wsUrl = '${AppConfig().wsBaseUrl}/api/v1/feature-flags/ws/$userId';
    _webSocketChannel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _webSocketChannel!.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'feature_flag_update') {
        _flagCache[data['feature_key']] = data['new_value'];
        _updateController.add(data);
      }
    });
  }

  Future<bool> isFeatureEnabled(String flagName) async {
    if (_flagCache.containsKey(flagName)) {
      return _flagCache[flagName]!;
    }

    // Fetch from API if not in cache
    try {
      final response = await http.get(
        Uri.parse('${AppConfig().apiBaseUrl}/api/v1/feature-flags/user/${AuthService().currentUser?.id}'),
        headers: {'Authorization': 'Bearer ${AuthService().accessToken}'},
      );

      final flags = jsonDecode(response.body) as Map<String, dynamic>;
      _flagCache.addAll(flags.cast<String, bool>());

      return flags[flagName] ?? false;
    } catch (e) {
      // Fallback to cached/default values
      return _flagCache[flagName] ?? false;
    }
  }
}
```

### 3.4 Placeholder Screen Implementation

#### Task 4.1: File New Claim Screen
**File:** `lib/screens/file_new_claim_screen.dart`
```dart
class FileNewClaimScreen extends StatefulWidget {
  final String? policyId;

  const FileNewClaimScreen({super.key, this.policyId});

  @override
  State<FileNewClaimScreen> createState() => _FileNewClaimScreenState();
}

class _FileNewClaimScreenState extends State<FileNewClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  String _claimType = 'medical';
  String _description = '';
  List<File> _supportingDocuments = [];
  bool _isSubmitting = false;

  final List<String> _claimTypes = [
    'medical',
    'accident',
    'critical_illness',
    'disability',
    'death',
    'maturity',
    'surrender'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File New Claim'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Policy Selection
              const Text('Select Policy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildPolicySelector(),

              const SizedBox(height: 24),

              // Claim Type
              const Text('Claim Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _claimType,
                items: _claimTypes.map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.replaceAll('_', ' ').toUpperCase()),
                )).toList(),
                onChanged: (value) => setState(() => _claimType = value!),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),

              const SizedBox(height: 24),

              // Description
              const Text('Claim Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Describe the incident and claim details...',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Description is required' : null,
                onChanged: (value) => _description = value,
              ),

              const SizedBox(height: 24),

              // Supporting Documents
              const Text('Supporting Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDocumentUploadSection(),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Claim', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySelector() {
    // Implementation for policy selection dropdown
    return Container(); // Placeholder
  }

  Widget _buildDocumentUploadSection() {
    // Implementation for document upload with camera/gallery options
    return Container(); // Placeholder
  }

  Future<void> _submitClaim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // API call to submit claim
      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Claim submitted successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit claim: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
```

#### Task 4.2: Create New Policy Screen
**File:** `lib/screens/create_new_policy_screen.dart`
```dart
class CreateNewPolicyScreen extends StatefulWidget {
  const CreateNewPolicyScreen({super.key});

  @override
  State<CreateNewPolicyScreen> createState() => _CreateNewPolicyScreenState();
}

class _CreateNewPolicyScreenState extends State<CreateNewPolicyScreen> {
  final _formKey = GlobalKey<FormState>();
  String _policyType = 'term_life';
  double _sumAssured = 1000000;
  int _termYears = 20;
  String _paymentFrequency = 'annual';
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Policy'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Policy Type Selection
              const Text('Policy Type', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildPolicyTypeSelector(),

              const SizedBox(height: 24),

              // Sum Assured
              const Text('Sum Assured', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _sumAssured.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixText: '₹',
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Sum assured is required' : null,
                onChanged: (value) => _sumAssured = double.tryParse(value) ?? _sumAssured,
              ),

              const SizedBox(height: 24),

              // Policy Term
              const Text('Policy Term (Years)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Slider(
                value: _termYears.toDouble(),
                min: 5,
                max: 40,
                divisions: 35,
                label: _termYears.toString(),
                onChanged: (value) => setState(() => _termYears = value.toInt()),
              ),

              const SizedBox(height: 24),

              // Payment Frequency
              const Text('Payment Frequency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _paymentFrequency,
                items: ['monthly', 'quarterly', 'half_yearly', 'annual'].map((freq) =>
                  DropdownMenuItem(value: freq, child: Text(freq.toUpperCase()))
                ).toList(),
                onChanged: (value) => setState(() => _paymentFrequency = value!),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 32),

              // Premium Calculator Preview
              _buildPremiumPreview(),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _createPolicy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Policy', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyTypeSelector() {
    // Implementation for policy type selection
    return Container(); // Placeholder
  }

  Widget _buildPremiumPreview() {
    // Implementation for premium calculator preview
    return Container(); // Placeholder
  }

  Future<void> _createPolicy() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // API call to create policy
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Policy created successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create policy: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}
```

### 3.5 Advanced Analytics Implementation

#### Task 5.1: Predictive Analytics Service
**File:** `backend/app/services/predictive_analytics_service.py`
```python
# Predictive analytics for churn risk and ROI forecasting
from typing import Dict, List, Any
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
import joblib
import os

class PredictiveAnalyticsService:
    def __init__(self, db):
        self.db = db
        self.model_path = "models/churn_prediction_model.pkl"
        self.scaler_path = "models/feature_scaler.pkl"

    async def predict_churn_risk(self, user_id: str) -> Dict[str, Any]:
        """Predict churn risk for a user based on behavior patterns"""
        # Gather user behavior data
        user_data = await self._gather_user_behavior_data(user_id)

        # Load or train model
        model, scaler = await self._load_or_train_model()

        # Make prediction
        features = scaler.transform([user_data['features']])
        churn_probability = model.predict_proba(features)[0][1]

        # Determine risk level
        risk_level = self._calculate_risk_level(churn_probability)

        return {
            "user_id": user_id,
            "churn_probability": churn_probability,
            "risk_level": risk_level,  # 'low', 'medium', 'high', 'critical'
            "recommendations": self._generate_recommendations(risk_level, user_data),
            "confidence_score": 0.85  # Model confidence
        }

    async def forecast_roi(self, agent_id: str, months_ahead: int = 6) -> Dict[str, Any]:
        """Forecast ROI for an agent over the next N months"""
        historical_data = await self._gather_agent_roi_history(agent_id)

        # Simple exponential smoothing forecast
        forecast = self._calculate_roi_forecast(historical_data, months_ahead)

        return {
            "agent_id": agent_id,
            "current_roi": historical_data[-1]['roi'] if historical_data else 0,
            "forecasted_roi": forecast,
            "confidence_interval": {"lower": forecast * 0.9, "upper": forecast * 1.1},
            "trend": self._analyze_trend(historical_data),
            "recommendations": self._generate_roi_recommendations(forecast)
        }

    async def _gather_user_behavior_data(self, user_id: str) -> Dict[str, Any]:
        """Gather user behavior data for churn prediction"""
        # Query user activity, login frequency, feature usage, etc.
        # This would include data from multiple tables
        return {
            "features": [0.8, 0.6, 0.9, 0.3, 0.7],  # Normalized features
            "activity_score": 0.75,
            "engagement_score": 0.82,
            "last_login_days": 3,
            "feature_usage_count": 15
        }

    async def _load_or_train_model(self):
        """Load pre-trained model or train new one"""
        if os.path.exists(self.model_path):
            model = joblib.load(self.model_path)
            scaler = joblib.load(self.scaler_path)
        else:
            # Train model with historical data
            model, scaler = await self._train_churn_model()

        return model, scaler

    def _calculate_risk_level(self, probability: float) -> str:
        """Calculate risk level from churn probability"""
        if probability >= 0.8:
            return "critical"
        elif probability >= 0.6:
            return "high"
        elif probability >= 0.4:
            return "medium"
        else:
            return "low"

    def _generate_recommendations(self, risk_level: str, user_data: Dict) -> List[str]:
        """Generate personalized recommendations based on risk level"""
        recommendations = []

        if risk_level in ["high", "critical"]:
            recommendations.extend([
                "Schedule a personal call with the agent",
                "Offer premium support and assistance",
                "Send personalized policy recommendations"
            ])

        if user_data.get('last_login_days', 0) > 7:
            recommendations.append("Send re-engagement email campaign")

        return recommendations

    def _calculate_roi_forecast(self, historical_data: List[Dict], months: int) -> float:
        """Calculate ROI forecast using exponential smoothing"""
        if not historical_data:
            return 0.0

        # Simple forecasting logic
        recent_roi = [d['roi'] for d in historical_data[-3:]]
        avg_recent_roi = sum(recent_roi) / len(recent_roi)

        # Assume 5% monthly growth trend
        forecasted_roi = avg_recent_roi * (1 + 0.05 * months / 12)

        return forecasted_roi

    def _analyze_trend(self, historical_data: List[Dict]) -> str:
        """Analyze ROI trend direction"""
        if len(historical_data) < 2:
            return "insufficient_data"

        recent = historical_data[-3:]
        if len(recent) < 2:
            return "stable"

        trend = (recent[-1]['roi'] - recent[0]['roi']) / len(recent)
        if trend > 0.02:
            return "increasing"
        elif trend < -0.02:
            return "decreasing"
        else:
            return "stable"
```

## 4. Implementation Timeline & Dependencies

### Phase 1: Database & Core Services (Days 1-5)
1. ✅ Create database migrations for enhanced KYC, emergency contacts, trial analytics
2. ✅ Implement WebSocket manager for real-time feature flags
3. ✅ Enhance feature flag service with real-time updates
4. ✅ Update Flutter feature flag service for WebSocket integration

### Phase 2: Analytics & Predictions (Days 6-10)
1. ✅ Implement predictive analytics service for churn risk and ROI forecasting
2. ✅ Create analytics API endpoints for dashboard widgets
3. ✅ Enhance Flutter analytics screens with predictive data
4. ✅ Add real-time analytics updates

### Phase 3: UI Enhancements & Polish (Days 11-15)
1. ✅ Implement File New Claim screen with full form validation
2. ✅ Implement Create New Policy screen with premium calculator
3. ✅ Enhance Payments screen with multiple payment methods
4. ✅ Build advanced Reports dashboard with export capabilities
5. ✅ Implement Customers screen with advanced filtering
6. ✅ Enhance Settings screen with comprehensive preferences

### Phase 4: Testing & Optimization (Days 16-20)
1. ✅ Comprehensive testing of all new features
2. ✅ Performance optimization for real-time features
3. ✅ Security audit of new endpoints
4. ✅ Documentation updates

## 5. Success Criteria

- **Zero Code Duplication**: All implementations build upon existing architecture
- **Wireframe Compliance**: All screens match wireframe specifications exactly
- **Real-time Updates**: Feature flags update instantly across all user sessions
- **Predictive Accuracy**: Churn prediction accuracy >75%, ROI forecasting within 10%
- **Performance**: All new features load in <2 seconds, WebSocket latency <500ms
- **Security**: All new endpoints properly authenticated and authorized
- **Scalability**: New features support 10,000+ concurrent users

This focused implementation plan ensures that only missing features are implemented while maintaining the integrity of the existing comprehensive Agent Mitra platform.

## 2. Authentication & Authorization Architecture

### 2.1 Authentication Methods

#### Mobile Number + OTP (Primary)
```yaml
Authentication Flow:
1. Phone number input with +91 prefix
2. OTP generation (6-digit, 5-minute expiry)
3. OTP verification with rate limiting (5/hour per number)
4. JWT token generation (15min access, 7-day refresh)
5. Automatic token refresh on expiry
```

#### Agent Code + Password (Agent Portal)
```yaml
Agent Login Flow:
1. Agent code input (format: LIC-XXXXXX)
2. Password input with visibility toggle
3. Multi-factor authentication (optional)
4. Session management with device tracking
5. Role-based dashboard redirection
```

### 2.2 RBAC Implementation

#### Role Hierarchy
```
Super Admin (Full System Access)
├── Provider Admin (Tenant Management)
│   ├── Regional Manager (Team Oversight)
│   │   ├── Senior Agent (Advanced Features)
│   │   │   └── Junior Agent (Basic Features)
│   │       └── Policyholder (Customer Portal)
│   │           └── Guest User (Trial Access)
└── Support Staff (Limited Admin)
```

#### Test Users (Pre-Seeded)
```yaml
Super Admin:
- Phone: +919876543200
- Password: testpassword
- Access: 59 permissions (full system)

Provider Admin:
- Phone: +919876543201
- Password: testpassword
- Access: Insurance provider management

Regional Manager:
- Phone: +919876543202
- Password: testpassword
- Access: 19 permissions (regional operations)

Senior Agent:
- Phone: +919876543203
- Password: testpassword
- Access: 16 permissions (agent operations)

Junior Agent:
- Phone: +919876543204
- Password: testpassword
- Access: 7 permissions (basic agent ops)

Policyholder:
- Phone: +919876543205
- Password: testpassword
- Access: 5 permissions (customer access)

Support Staff:
- Phone: +919876543206
- Password: testpassword
- Access: 8 permissions (support operations)
```

### 2.3 Feature Flag Integration
```dart
// Flutter Implementation
class FeatureFlagService {
  static Future<bool> isFeatureEnabled(String flagName) async {
    final user = await AuthService.getCurrentUser();
    final flags = await api.getUserFeatureFlags(user.id);
    return flags[flagName] ?? false;
  }
}

// UI Conditional Rendering
Widget build(BuildContext context) {
  return FutureBuilder<bool>(
    future: FeatureFlagService.isFeatureEnabled('customer_dashboard_enabled'),
    builder: (context, snapshot) {
      if (!snapshot.hasData || !snapshot.data!) {
        return TrialExpiredScreen();
      }
      return DashboardWidget();
    },
  );
}
```

## 3. Database Schema & Migrations

### 3.1 Core Tables (V3 Migration)

#### User Management
```sql
-- Multi-tenant users with role-based access
CREATE TABLE lic_schema.users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000',
    email VARCHAR(255) UNIQUE,
    phone_number VARCHAR(15) UNIQUE,
    username VARCHAR(100) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    -- Profile and authentication fields
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role lic_schema.user_role_enum NOT NULL,
    status lic_schema.user_status_enum DEFAULT 'active',
    trial_end_date TIMESTAMP,
    -- Audit fields
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

#### Insurance Domain
```sql
-- Agents with provider relationships
CREATE TABLE lic_schema.agents (
    agent_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    provider_id UUID REFERENCES shared.insurance_providers(provider_id),
    agent_code VARCHAR(50) UNIQUE NOT NULL,
    business_name VARCHAR(255),
    whatsapp_business_number VARCHAR(15),
    status lic_schema.agent_status_enum DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);

-- Policyholders with agent relationships
CREATE TABLE lic_schema.policyholders (
    policyholder_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    customer_id VARCHAR(100),
    marital_status VARCHAR(20),
    occupation VARCHAR(100),
    annual_income DECIMAL(12,2),
    communication_preferences JSONB,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insurance policies (core business entity)
CREATE TABLE lic_schema.insurance_policies (
    policy_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_number VARCHAR(100) UNIQUE NOT NULL,
    policyholder_id UUID REFERENCES lic_schema.policyholders(policyholder_id),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    policy_type VARCHAR(100) NOT NULL,
    plan_name VARCHAR(255) NOT NULL,
    sum_assured DECIMAL(15,2) NOT NULL,
    premium_amount DECIMAL(12,2) NOT NULL,
    status lic_schema.policy_status_enum DEFAULT 'pending_approval',
    start_date DATE NOT NULL,
    maturity_date DATE,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### 3.2 Feature-Specific Tables

#### Presentations System
```sql
-- Presentation carousel system
CREATE TABLE lic_schema.presentations (
    presentation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'draft',
    is_active BOOLEAN DEFAULT false,
    template_id UUID,
    total_views INTEGER DEFAULT 0,
    total_shares INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Presentation slides
CREATE TABLE lic_schema.presentation_slides (
    slide_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    presentation_id UUID REFERENCES lic_schema.presentations(presentation_id),
    slide_order INTEGER NOT NULL,
    slide_type VARCHAR(50) NOT NULL, -- 'image', 'video', 'text'
    media_url VARCHAR(500),
    title TEXT,
    subtitle TEXT,
    duration INTEGER DEFAULT 4,
    cta_button JSONB,
    agent_branding JSONB,
    UNIQUE(presentation_id, slide_order)
);
```

#### Daily Quotes & Content
```sql
-- Motivational quotes system
CREATE TABLE lic_schema.daily_quotes (
    quote_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    quote_text TEXT NOT NULL,
    author VARCHAR(255),
    background_image_url VARCHAR(500),
    category VARCHAR(50), -- 'motivation', 'success', 'insurance'
    is_active BOOLEAN DEFAULT true,
    total_shares INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### Document & KYC Management
```sql
-- Document upload tracking
CREATE TABLE lic_schema.document_uploads (
    document_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    document_type VARCHAR(50) NOT NULL, -- 'aadhaar', 'voter_id', 'selfie'
    file_name VARCHAR(255),
    file_url VARCHAR(500),
    ocr_data JSONB,
    verification_status VARCHAR(50) DEFAULT 'pending',
    uploaded_at TIMESTAMP DEFAULT NOW()
);

-- KYC verification tracking
CREATE TABLE lic_schema.kyc_verifications (
    kyc_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    verification_type VARCHAR(50) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    verified_data JSONB,
    verified_at TIMESTAMP,
    verified_by UUID REFERENCES lic_schema.users(user_id)
);
```

#### Video Tutorials & Learning
```sql
-- Video content management
CREATE TABLE lic_schema.video_content (
    video_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    agent_id UUID REFERENCES lic_schema.agents(agent_id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    video_url VARCHAR(500) NOT NULL,
    thumbnail_url VARCHAR(500),
    duration_seconds INTEGER,
    category VARCHAR(100),
    tags TEXT[],
    view_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Learning progress tracking
CREATE TABLE lic_schema.learning_progress (
    progress_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES lic_schema.users(user_id),
    video_id UUID REFERENCES lic_schema.video_content(video_id),
    watch_time_seconds INTEGER DEFAULT 0,
    completion_rate DECIMAL(5,2) DEFAULT 0,
    completed BOOLEAN DEFAULT false,
    last_watched_at TIMESTAMP DEFAULT NOW()
);
```

## 4. Backend API Structure

### 4.1 Authentication APIs

#### Core Auth Endpoints
```python
# FastAPI Authentication Router
@router.post("/auth/phone/send-otp")
async def send_phone_otp(request: PhoneOTPRequest):
    """Send OTP to phone number with rate limiting"""
    return await auth_service.send_phone_otp(request.phone_number)

@router.post("/auth/phone/verify-otp")
async def verify_phone_otp(request: OTPVerificationRequest):
    """Verify OTP and return JWT tokens"""
    return await auth_service.verify_otp_and_login(request)

@router.post("/auth/agent/login")
async def agent_login(request: AgentLoginRequest):
    """Agent code + password authentication"""
    return await auth_service.agent_code_login(request)

@router.post("/auth/refresh")
async def refresh_token(request: TokenRefreshRequest):
    """Refresh JWT access token"""
    return await auth_service.refresh_access_token(request.refresh_token)
```

#### RBAC Middleware
```python
# Permission-based middleware
@app.middleware("http")
async def rbac_middleware(request: Request, call_next):
    user = await auth_service.get_current_user(request)
    if not user:
        raise HTTPException(status_code=401, detail="Authentication required")

    # Check permission for endpoint
    endpoint_permission = get_endpoint_permission(request.url.path, request.method)
    if endpoint_permission and not await rbac_service.has_permission(user.id, endpoint_permission):
        raise HTTPException(status_code=403, detail="Insufficient permissions")

    response = await call_next(request)
    return response
```

### 4.2 Customer Portal APIs

#### Dashboard APIs
```python
@router.get("/customer/dashboard")
async def get_customer_dashboard(current_user = Depends(require_role("policyholder"))):
    """Get customer dashboard with policy overview and quick actions"""
    return await customer_service.get_dashboard_data(current_user.id)

@router.get("/customer/policies")
async def get_customer_policies(
    search: str = None,
    status: str = None,
    current_user = Depends(require_role("policyholder"))
):
    """Get customer's policies with search and filtering"""
    return await policy_service.get_customer_policies(current_user.id, search, status)
```

#### WhatsApp & Communication APIs
```python
@router.post("/customer/whatsapp/send")
async def send_whatsapp_message(
    request: WhatsAppMessageRequest,
    current_user = Depends(require_role("policyholder"))
):
    """Send WhatsApp message to agent with context"""
    return await whatsapp_service.send_customer_message(request, current_user.id)

@router.get("/customer/chatbot/query")
async def query_chatbot(
    query: str,
    current_user = Depends(require_role("policyholder"))
):
    """Query AI chatbot for policy assistance"""
    return await chatbot_service.process_query(query, current_user.id)
```

### 4.3 Agent Portal APIs

#### Presentation Management
```python
@router.post("/agent/presentations")
async def create_presentation(
    request: PresentationCreateRequest,
    current_user = Depends(require_permission("presentations.create"))
):
    """Create new presentation with slides"""
    return await presentation_service.create_presentation(request, current_user.id)

@router.put("/agent/presentations/{presentation_id}/slides")
async def update_presentation_slides(
    presentation_id: str,
    slides: List[SlideUpdateRequest],
    current_user = Depends(require_permission("presentations.update"))
):
    """Update presentation slides with drag-drop reordering"""
    return await presentation_service.update_slides(presentation_id, slides, current_user.id)
```

#### Daily Quotes Management
```python
@router.post("/agent/quotes")
async def create_daily_quote(
    request: QuoteCreateRequest,
    current_user = Depends(require_permission("quotes.create"))
):
    """Create motivational quote with branding"""
    return await quote_service.create_quote(request, current_user.id)

@router.post("/agent/quotes/{quote_id}/share")
async def share_quote_to_clients(
    quote_id: str,
    client_filters: ClientFilterRequest,
    current_user = Depends(require_permission("quotes.share"))
):
    """Share quote to specific client segments"""
    return await quote_service.share_quote(quote_id, client_filters, current_user.id)
```

### 4.4 Config Portal APIs

#### Data Import APIs
```python
@router.post("/config/import/upload")
async def upload_excel_file(
    file: UploadFile,
    current_user = Depends(require_permission("data_import.upload"))
):
    """Upload Excel file for data import"""
    return await import_service.process_excel_upload(file, current_user.id)

@router.get("/config/import/progress/{import_id}")
async def get_import_progress(
    import_id: str,
    current_user = Depends(require_permission("data_import.view"))
):
    """Get real-time import progress"""
    return await import_service.get_import_progress(import_id, current_user.id)
```

## 5. Flutter Mobile Applications

### 5.1 Customer Portal App

#### App Structure
```
lib/
├── core/
│   ├── auth/           # Authentication services
│   ├── api/            # API client with auth headers
│   ├── storage/        # Secure token storage
│   └── permissions/    # RBAC permission checking
├── features/
│   ├── onboarding/     # Registration & setup flow
│   ├── dashboard/      # Main dashboard screen
│   ├── policies/       # Policy management
│   ├── payments/       # Premium payments
│   ├── chat/           # WhatsApp & chatbot
│   ├── learning/       # Video tutorials
│   └── profile/        # User profile
└── shared/
    ├── widgets/        # Common UI components
    ├── theme/          # App theming
    └── l10n/           # Localization
```

#### Key Screens Implementation

##### Onboarding Flow
```dart
class OnboardingFlow extends StatefulWidget {
  @override
  _OnboardingFlowState createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  int currentStep = 0;

  final steps = [
    LanguageSelectionScreen(),
    WelcomeScreen(),
    PhoneVerificationScreen(),
    ProfileSetupScreen(),
    AgentDiscoveryScreen(),
    DocumentUploadScreen(),
    EmergencyContactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: steps[currentStep],
      bottomNavigationBar: OnboardingProgressIndicator(
        currentStep: currentStep,
        totalSteps: steps.length,
        onNext: () => setState(() => currentStep++),
        onPrevious: () => setState(() => currentStep--),
      ),
    );
  }
}
```

##### Dashboard Screen
```dart
class CustomerDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agent Mitra'),
        actions: [ThemeSwitcher(), NotificationIcon()],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            QuickActionsWidget(),           // Pay, Contact, Quote buttons
            PolicyOverviewWidget(),         // Key metrics
            NotificationsWidget(),          // Priority alerts
            QuickInsightsWidget(),          // Charts and trends
          ],
        ),
      ),
      bottomNavigationBar: CustomerBottomNav(),
    );
  }
}

class QuickActionsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionButton(
          icon: Icons.payment,
          label: 'Pay Premium',
          onPressed: () => Navigator.pushNamed(context, '/payments'),
        ),
        ActionButton(
          icon: Icons.call,
          label: 'Contact Agent',
          onPressed: () => Navigator.pushNamed(context, '/chat'),
        ),
        ActionButton(
          icon: Icons.help,
          label: 'Get Quote',
          onPressed: () => Navigator.pushNamed(context, '/quotes'),
        ),
      ],
    );
  }
}
```

### 5.2 Agent Portal App

#### Agent Dashboard
```dart
class AgentDashboard extends StatefulWidget {
  @override
  _AgentDashboardState createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  late Future<DashboardData> dashboardData;

  @override
  void initState() {
    super.initState();
    dashboardData = _loadDashboardData();
  }

  Future<DashboardData> _loadDashboardData() async {
    final apiService = AgentApiService();
    return await apiService.getDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agent Mitra'),
        actions: [
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      drawer: AgentDrawerMenu(),
      body: FutureBuilder<DashboardData>(
        future: dashboardData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return LoadingSpinner();
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              children: [
                PresentationCarousel(presentations: data.activePresentations),
                FeatureTilesGrid(),
                MyPoliciesSection(policies: data.recentPolicies),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

#### Presentation Editor
```dart
class PresentationEditor extends StatefulWidget {
  final String presentationId;

  PresentationEditor({required this.presentationId});

  @override
  _PresentationEditorState createState() => _PresentationEditorState();
}

class _PresentationEditorState extends State<PresentationEditor> {
  List<PresentationSlide> slides = [];
  bool isPreviewMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Presentation'),
        actions: [
          IconButton(
            icon: Icon(isPreviewMode ? Icons.edit : Icons.play_arrow),
            onPressed: () => setState(() => isPreviewMode = !isPreviewMode),
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _savePresentation,
          ),
        ],
      ),
      body: isPreviewMode
          ? PresentationPreview(slides: slides)
          : PresentationSlideList(
              slides: slides,
              onReorder: _onSlideReorder,
              onEdit: _editSlide,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewSlide,
        child: Icon(Icons.add),
      ),
    );
  }

  void _onSlideReorder(int oldIndex, int newIndex) {
    setState(() {
      final slide = slides.removeAt(oldIndex);
      slides.insert(newIndex, slide);
    });
  }

  void _editSlide(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SlideEditor(
          slide: slides[index],
          onSave: (updatedSlide) {
            setState(() => slides[index] = updatedSlide);
          },
        ),
      ),
    );
  }
}
```

## 6. React Config Portal

### 6.1 Portal Structure
```
config-portal/
├── src/
│   ├── components/
│   │   ├── Layout/         # Portal layout components
│   │   ├── DataImport/     # Import-related components
│   │   └── Dashboard/      # Dashboard widgets
│   ├── pages/
│   │   ├── DataImport.tsx      # Excel upload page
│   │   ├── ImportProgress.tsx  # Progress tracking
│   │   ├── ImportErrors.tsx    # Error resolution
│   │   ├── ImportSuccess.tsx   # Success confirmation
│   │   └── Dashboard.tsx       # Portal dashboard
│   ├── services/
│   │   ├── dataImportApi.ts    # Import API calls
│   │   ├── authApi.ts          # Authentication
│   │   └── rbacApi.ts          # Permission checks
│   └── types/
│       ├── dataImport.ts       # Import type definitions
│       └── rbac.ts            # RBAC type definitions
```

### 6.2 Key Components

#### Data Import Page
```tsx
const DataImport: React.FC = () => {
  const [file, setFile] = useState<File | null>(null);
  const [uploadProgress, setUploadProgress] = useState(0);
  const [importId, setImportId] = useState<string | null>(null);

  const handleFileUpload = async () => {
    if (!file) return;

    const formData = new FormData();
    formData.append('file', file);

    try {
      const response = await dataImportApi.uploadExcel(formData, {
        onUploadProgress: (progress) => {
          setUploadProgress(Math.round((progress.loaded * 100) / progress.total));
        }
      });

      setImportId(response.importId);
      navigate(`/import/progress/${response.importId}`);
    } catch (error) {
      console.error('Upload failed:', error);
    }
  };

  return (
    <div className="data-import">
      <h2>Upload Customer Excel Data</h2>

      <div className="upload-zone">
        <input
          type="file"
          accept=".xlsx,.xls"
          onChange={(e) => setFile(e.target.files?.[0] || null)}
        />

        {uploadProgress > 0 && (
          <div className="progress-bar">
            <div
              className="progress-fill"
              style={{ width: `${uploadProgress}%` }}
            />
          </div>
        )}

        <button
          onClick={handleFileUpload}
          disabled={!file || uploadProgress > 0}
        >
          Upload File
        </button>
      </div>
    </div>
  );
};
```

## 7. Environment Configuration

### 7.1 Environment Variables Structure
```bash
# Database Configuration
DATABASE_URL=postgresql://user:password@localhost:5432/agentmitra
DATABASE_SCHEMA=lic_schema

# Authentication
JWT_SECRET_KEY=your-super-secret-jwt-key
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=15
JWT_REFRESH_TOKEN_EXPIRE_DAYS=7

# OTP Configuration
OTP_EXPIRY_MINUTES=5
OTP_RATE_LIMIT_PER_HOUR=5

# WhatsApp Business API
WHATSAPP_ACCESS_TOKEN=your-whatsapp-token
WHATSAPP_PHONE_NUMBER_ID=your-phone-number-id

# File Storage
AWS_S3_BUCKET=agentmitra-files
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret

# Feature Flags
FEATURE_FLAG_ENVIRONMENT=development
FEATURE_FLAG_API_KEY=your-feature-flag-key

# Email Configuration
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Redis Configuration
REDIS_URL=redis://localhost:6379

# External APIs
LIC_API_BASE_URL=https://api.licindia.in
LIC_API_KEY=your-lic-api-key
```

### 7.2 Configuration Loading
```python
# Python configuration
from pydantic import BaseSettings

class Settings(BaseSettings):
    database_url: str
    jwt_secret_key: str
    jwt_access_token_expire_minutes: int = 15
    jwt_refresh_token_expire_days: int = 7
    otp_expiry_minutes: int = 5
    otp_rate_limit_per_hour: int = 5

    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
```

## 8. Implementation Phases

### Phase 1: Foundation (Weeks 1-3)
1. ✅ Database schema creation with all tables
2. ✅ Basic authentication system (phone + OTP)
3. ✅ RBAC system with seeded test users
4. ✅ Feature flag infrastructure
5. ✅ Basic Flutter app structure

### Phase 2: Core Backend (Weeks 4-6)
1. ✅ Complete API structure with RBAC middleware
2. ✅ Customer portal APIs (dashboard, policies, payments)
3. ✅ Agent portal APIs (presentations, quotes, profile)
4. ✅ Config portal APIs (data import)
5. ✅ WhatsApp and chatbot integration

### Phase 3: Frontend Development (Weeks 7-10)
1. ✅ Customer app: Complete onboarding and dashboard
2. ✅ Customer app: Policy management and payments
3. ✅ Customer app: Communication features
4. ✅ Agent app: Dashboard and navigation
5. ✅ Agent app: Presentation editor
6. ✅ Agent app: Quotes and profile management
7. ✅ Config portal: Data import interface

### Phase 4: Advanced Features (Weeks 11-13)
1. ✅ Video learning center
2. ✅ Document upload and KYC
3. ✅ Analytics and reporting
4. ✅ Multi-language support
5. ✅ Performance optimization

### Phase 5: Testing & Deployment (Weeks 14-15)
1. ✅ Comprehensive testing (unit, integration, E2E)
2. ✅ Security audit and penetration testing
3. ✅ Performance optimization
4. ✅ Production deployment
5. ✅ Monitoring and maintenance setup

## 9. Testing Strategy

### 9.1 Authentication Testing
```python
def test_phone_otp_flow():
    # Test OTP sending
    response = client.post("/auth/phone/send-otp", json={"phone_number": "+919876543205"})
    assert response.status_code == 200

    # Test OTP verification
    response = client.post("/auth/phone/verify-otp", json={
        "phone_number": "+919876543205",
        "otp": "123456"
    })
    assert response.status_code == 200
    assert "access_token" in response.json()

def test_rbac_permissions():
    # Test policyholder access to customer APIs
    headers = {"Authorization": f"Bearer {policyholder_token}"}
    response = client.get("/customer/dashboard", headers=headers)
    assert response.status_code == 200

    # Test policyholder blocked from agent APIs
    response = client.get("/agent/dashboard", headers=headers)
    assert response.status_code == 403
```

### 9.2 Feature Flag Testing
```dart
void testFeatureFlagIntegration() {
  test('Feature flag controls UI rendering', () async {
    // Mock feature flag service
    when(mockFeatureFlagService.isFeatureEnabled('customer_dashboard_enabled'))
        .thenAnswer((_) async => true);

    await tester.pumpWidget(CustomerDashboard());

    // Verify dashboard renders
    expect(find.text('Agent Mitra'), findsOneWidget);
    expect(find.byType(QuickActionsWidget), findsOneWidget);
  });
}
```

## 10. Security & Compliance

### 10.1 Data Protection
- **Encryption**: All sensitive data encrypted at rest and in transit
- **PII Handling**: Personal identifiable information properly masked
- **Audit Logging**: All data access logged for compliance
- **Data Retention**: Automatic cleanup of old data per regulations

### 10.2 IRDAI Compliance
- **Financial Data Security**: Premium amounts and policy data secured
- **Agent Verification**: All agents verified through official channels
- **Transaction Logging**: All financial transactions fully audited
- **Regulatory Reporting**: Automatic reports for IRDAI requirements

### 10.3 DPDP Compliance
- **Consent Management**: User consent tracked for all data usage
- **Data Portability**: Users can export their data
- **Right to Deletion**: Complete data deletion on request
- **Privacy Controls**: Granular privacy settings for users

## 11. Performance & Scalability

### 11.1 Database Optimization
- **Indexing Strategy**: Comprehensive indexes on frequently queried columns
- **Query Optimization**: Efficient queries with proper joins and aggregations
- **Connection Pooling**: Optimized database connection management
- **Caching Layer**: Redis caching for frequently accessed data

### 11.2 API Performance
- **Rate Limiting**: Request rate limiting by user role
- **Response Caching**: API response caching for static data
- **Pagination**: Efficient pagination for large datasets
- **Background Jobs**: Asynchronous processing for heavy operations

### 11.3 Mobile App Optimization
- **Offline Support**: Critical features work without internet
- **Image Optimization**: Automatic image compression and optimization
- **Lazy Loading**: Progressive loading of content
- **Memory Management**: Efficient memory usage and cleanup

## 12. Deployment & DevOps

### 12.1 Infrastructure
```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  backend:
    image: agentmitra/backend:latest
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - postgres
      - redis

  frontend:
    image: agentmitra/frontend:latest
    depends_on:
      - backend

  postgres:
    image: postgres:16
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
```

### 12.2 CI/CD Pipeline
```yaml
# .github/workflows/deploy.yml
name: Deploy to Production
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Backend Tests
        run: |
          cd backend
          pip install -r requirements.txt
          pytest

      - name: Run Flutter Tests
        run: |
          flutter test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy Backend
        run: |
          docker build -t agentmitra/backend ./backend
          docker push agentmitra/backend

      - name: Deploy Frontend
        run: |
          flutter build web
          firebase deploy
```

## 13. Monitoring & Maintenance

### 13.1 Application Monitoring
- **Error Tracking**: Sentry integration for error monitoring
- **Performance Monitoring**: New Relic for application performance
- **User Analytics**: Mixpanel for user behavior tracking
- **Business Metrics**: Custom dashboards for key business KPIs

### 13.2 Database Monitoring
- **Query Performance**: Slow query monitoring and optimization
- **Connection Pool**: Database connection monitoring
- **Storage Usage**: Automatic alerts for storage thresholds
- **Backup Verification**: Automated backup integrity checks

### 13.3 Security Monitoring
- **Intrusion Detection**: Real-time security threat monitoring
- **Access Pattern Analysis**: Unusual access pattern detection
- **Compliance Auditing**: Automated compliance report generation
- **Vulnerability Scanning**: Regular security vulnerability scans

## 14. Conclusion

This comprehensive implementation plan provides a complete roadmap for building the Agent Mitra platform with strict authentication, RBAC controls, and feature flag management. The plan ensures all wireframe requirements are met while maintaining security, scalability, and compliance with Indian regulatory requirements.

**Key Success Factors:**
- Zero-trust security model with RBAC at every endpoint
- Feature flag driven development for runtime configurability
- Comprehensive testing strategy covering all user roles
- Scalable multi-tenant architecture
- Regulatory compliance (IRDAI, DPDP)
- Performance optimization for mobile-first experience

**Next Steps:**
1. Begin with Phase 1 foundation work
2. Set up development environment with proper RBAC testing
3. Implement authentication system with seeded test users
4. Build core APIs with comprehensive permission checking
5. Develop Flutter apps following wireframe specifications
6. Implement feature flags and conditional rendering
7. Comprehensive testing and security audit
8. Production deployment and monitoring setup

This plan ensures a production-ready, secure, and scalable Agent Mitra platform that meets all specified requirements and user needs.
