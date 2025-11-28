# 🔧 **Agent Mitra Database Schema & API Alignment Plan**
## **Comprehensive Fix Strategy for Production-Ready Backend**

---

## 📋 **EXECUTIVE SUMMARY**

**Current Status**: Backend running with import issues resolved, but SQLAlchemy relationship conflicts preventing authentication and API functionality.

**Goal**: Create a fully functional, production-ready Agent Mitra backend with:
- ✅ Working authentication system
- ✅ Proper RBAC implementation
- ✅ Aligned database schema and models
- ✅ Meaningful seed data
- ✅ Comprehensive API testing coverage

**Timeline**: 5-7 days for complete implementation

---

## 🎯 **CURRENT ISSUES IDENTIFIED**

### **1. SQLAlchemy Relationship Conflicts**
- Multiple foreign key resolution failures
- Class naming conflicts (PremiumPayment)
- Missing foreign key constraints
- Incorrect relationship mappings

### **2. Authentication System**
- Test users not working (Invalid credentials)
- RBAC permissions not properly seeded
- User-role relationships broken

### **3. Database Schema Misalignment**
- Models don't match actual Flyway migrations
- Missing foreign key constraints
- Inconsistent data types

### **4. Seed Data Issues**
- Test user credentials don't match seeded data
- Role permissions not properly configured
- Tenant context missing

---

## 📊 **PHASE-BY-FASE IMPLEMENTATION PLAN**

---

## **PHASE 1: DATABASE SCHEMA AUDIT & MODEL ALIGNMENT** 🔍
**Duration**: 2 days
**Owner**: Database Engineer

### **1.1 Database Schema Analysis**

#### **Objective**: Create comprehensive database schema documentation

**Steps:**
1. **Export current database schema**:
   ```sql
   -- Generate schema dump
   pg_dump -h localhost -U agentmitra -d agentmitra_db --schema-only > current_schema.sql
   ```

2. **Document all tables and relationships**:
   ```sql
   -- Get all tables with schema info
   SELECT schemaname, tablename, tableowner
   FROM pg_tables
   WHERE schemaname IN ('public', 'lic_schema')
   ORDER BY schemaname, tablename;
   ```

3. **Analyze foreign key constraints**:
   ```sql
   -- Get all foreign key relationships
   SELECT
       tc.table_schema,
       tc.constraint_name,
       tc.table_name,
       kcu.column_name,
       ccu.table_schema AS foreign_table_schema,
       ccu.table_name AS foreign_table_name,
       ccu.column_name AS foreign_column_name
   FROM information_schema.table_constraints AS tc
   JOIN information_schema.key_column_usage AS kcu
     ON tc.constraint_name = kcu.constraint_name
     AND tc.table_schema = kcu.table_schema
   JOIN information_schema.constraint_column_usage AS ccu
     ON ccu.constraint_name = tc.constraint_name
     AND ccu.table_schema = tc.table_schema
   WHERE tc.constraint_type = 'FOREIGN KEY'
   AND tc.table_schema IN ('public', 'lic_schema');
   ```

### **1.2 Model Relationship Audit**

#### **Objective**: Fix all SQLAlchemy relationship issues

**Current Issues Identified:**
1. `User.subscription_changes` - Multiple foreign keys to User table
2. `Lead.converted_policy` - References "Policy" instead of "InsurancePolicy"
3. `CustomerRetentionAnalytics.customer` - References "Customer" instead of "Policyholder"
4. `PremiumPayment` class conflict - Exists in both payment.py and policy.py

**Fix Strategy:**
1. **Audit all relationship() calls** in models
2. **Verify foreign key columns exist** in database
3. **Fix relationship mappings** to use correct class names
4. **Resolve naming conflicts** by renaming classes

### **1.3 Flyway Migration Strategy**

#### **Objective**: Create proper database migration sequence

**Migration Structure:**
```
db/migration/
├── V1__initial_schema.sql
├── V2__fix_relationships.sql
├── V3__add_constraints.sql
├── V4__seed_data.sql
├── V5__rbac_setup.sql
└── V6__tenant_setup.sql
```

**Key Migration Files:**

**V2__fix_relationships.sql**:
```sql
-- Add missing foreign key constraints
ALTER TABLE lic_schema.subscription_changes
ADD CONSTRAINT fk_subscription_changes_user
FOREIGN KEY (user_id) REFERENCES lic_schema.users(user_id);

ALTER TABLE lic_schema.subscription_changes
ADD CONSTRAINT fk_subscription_changes_initiated_by
FOREIGN KEY (initiated_by) REFERENCES lic_schema.users(user_id);

-- Fix other relationship issues
ALTER TABLE lic_schema.leads
ADD CONSTRAINT fk_leads_converted_policy
FOREIGN KEY (converted_policy_id) REFERENCES lic_schema.insurance_policies(policy_id);
```

---

## **PHASE 2: SEED DATA DESIGN & IMPLEMENTATION** 🌱
**Duration**: 2 days
**Owner**: Data Engineer

### **2.1 Seed Data Architecture**

#### **Objective**: Create meaningful, logical seed data aligned with APIs

**Data Structure:**
```
seed/
├── 01_tenants.sql
├── 02_users_and_roles.sql
├── 03_agents.sql
├── 04_policies_and_quotes.sql
├── 05_campaigns_and_content.sql
├── 06_analytics_data.sql
└── 07_test_scenarios.sql
```

### **2.2 User & Role Seed Data**

#### **Objective**: Create working test users with proper RBAC

**User Creation Strategy:**
1. **Create tenants first** (multi-tenant support)
2. **Create users with proper credentials**
3. **Assign roles and permissions**
4. **Set up agent relationships**

**Sample Seed Data:**

**01_tenants.sql**:
```sql
-- Create default tenant
INSERT INTO lic_schema.tenants (tenant_id, name, domain, status, created_at)
VALUES (
    '00000000-0000-0000-0000-000000000000',
    'Default Tenant',
    'agentmitra.com',
    'active',
    NOW()
);
```

**02_users_and_roles.sql**:
```sql
-- Create super admin user
INSERT INTO lic_schema.users (
    user_id, tenant_id, phone_number, password_hash, password_salt,
    email, full_name, status, created_at
) VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    '00000000-0000-0000-0000-000000000000',
    '+919876543200',
    -- Hash for 'testpassword'
    '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewfBPj6P5HfZ6Xm',
    'randomsalt123',
    'superadmin@agentmitra.com',
    'Super Administrator',
    'active',
    NOW()
);

-- Create roles
INSERT INTO lic_schema.roles (role_id, name, description, is_system_role)
VALUES
    ('role-super-admin', 'Super Admin', 'Full system access', true),
    ('role-provider-admin', 'Provider Admin', 'Insurance provider management', true),
    ('role-regional-manager', 'Regional Manager', 'Regional operations', true),
    ('role-senior-agent', 'Senior Agent', 'Senior agent operations', true),
    ('role-junior-agent', 'Junior Agent', 'Junior agent operations', true),
    ('role-policyholder', 'Policyholder', 'Customer access', true),
    ('role-support-staff', 'Support Staff', 'Support operations', true);

-- Assign super admin role
INSERT INTO lic_schema.user_roles (user_id, role_id, assigned_by, assigned_at)
VALUES (
    '550e8400-e29b-41d4-a716-446655440000',
    'role-super-admin',
    '550e8400-e29b-41d4-a716-446655440000',
    NOW()
);

-- Create other test users (provider admin, etc.)
-- ... additional user creation statements
```

### **2.3 Business Logic Seed Data**

#### **Objective**: Create realistic insurance data

**Data Categories:**
1. **Insurance Products** (Life, Health, Vehicle, Property)
2. **Policy Templates** with realistic terms
3. **Agent Territories** and hierarchies
4. **Customer Profiles** with various demographics
5. **Policy Examples** with different statuses
6. **Payment Records** and billing cycles
7. **Claims History** and processing

**Sample Data Strategy:**
```sql
-- Create insurance products
INSERT INTO lic_schema.insurance_products (product_id, name, type, coverage_amount, premium_range)
VALUES
    ('prod-life-001', 'Life Secure Plus', 'life', 5000000, '{"min": 5000, "max": 50000}'),
    ('prod-health-001', 'Health Shield', 'health', 1000000, '{"min": 3000, "max": 15000}'),
    ('prod-vehicle-001', 'Vehicle Protect', 'vehicle', 2000000, '{"min": 2000, "max": 10000}');

-- Create sample policies
INSERT INTO lic_schema.insurance_policies (
    policy_id, policy_number, product_id, policyholder_id, agent_id,
    premium_amount, coverage_amount, status, start_date, end_date
) VALUES (
    'pol-001-001',
    'POL001001',
    'prod-life-001',
    'cust-001',
    'agent-001',
    25000,
    5000000,
    'active',
    CURRENT_DATE,
    CURRENT_DATE + INTERVAL '1 year'
);
```

---

## **PHASE 3: API ALIGNMENT & TESTING** 🔗
**Duration**: 1.5 days
**Owner**: Backend Developer

### **3.1 API Endpoint Verification**

#### **Objective**: Ensure APIs work with seeded data

**Verification Steps:**
1. **Test authentication endpoints** with seeded users
2. **Verify RBAC permissions** work correctly
3. **Test CRUD operations** on all entities
4. **Validate relationships** in API responses

**API Testing Checklist:**
```python
# Authentication tests
✅ POST /auth/login - All 7 user roles
✅ GET /users/me - Profile retrieval
✅ GET /users/me/preferences - User preferences

# RBAC tests
✅ GET /rbac/roles - Role listing
✅ GET /rbac/permissions - Permission checking
✅ POST /rbac/check-permission - Permission validation

# Business logic tests
✅ GET /policies/ - Policy listing
✅ GET /agents/ - Agent management
✅ GET /analytics/dashboard - Dashboard data
✅ POST /quotes/ - Quote creation
```

### **3.2 Performance Testing**

#### **Objective**: Ensure APIs perform well with seed data

**Performance Benchmarks:**
- Authentication: < 500ms
- Dashboard loading: < 2s
- Policy search: < 1s
- Analytics queries: < 3s

---

## **PHASE 4: DEPLOYMENT & MONITORING** 🚀
**Duration**: 1 day
**Owner**: DevOps Engineer

### **4.1 Deployment Strategy**

#### **Objective**: Safe production deployment

**Deployment Steps:**
1. **Database backup** before migrations
2. **Staged deployment** (dev → staging → prod)
3. **Migration verification** scripts
4. **Rollback plan** for each phase

### **4.2 Monitoring Setup**

#### **Objective**: Production monitoring and alerting

**Monitoring Components:**
1. **API Health Checks** - All endpoints
2. **Database Performance** - Query monitoring
3. **Authentication Success Rate** - Login metrics
4. **Error Rate Monitoring** - 500/400 error tracking

---

## **PHASE 5: VALIDATION & SIGN-OFF** ✅
**Duration**: 0.5 days
**Owner**: QA Team

### **5.1 Final Validation**

#### **Objective**: Ensure everything works end-to-end

**Validation Checklist:**
- ✅ All authentication flows working
- ✅ RBAC permissions correct
- ✅ API responses match expectations
- ✅ Database relationships intact
- ✅ Performance within benchmarks
- ✅ Seed data realistic and complete

### **5.2 Documentation Update**

#### **Objective**: Update all documentation

**Documentation Updates:**
- API documentation with working examples
- Database schema documentation
- Deployment and maintenance guides
- Troubleshooting runbooks

---

## 📋 **IMPLEMENTATION TIMELINE**

```
Week 1:
├── Day 1: Database schema audit & model fixes
├── Day 2: Flyway migration creation
├── Day 3: Seed data design & tenant setup
├── Day 4: User/role seed data implementation
├── Day 5: Business logic seed data

Week 2:
├── Day 6: API alignment testing
├── Day 7: Performance testing & optimization
├── Day 8: Deployment preparation
├── Day 9: Production deployment & monitoring
└── Day 10: Final validation & documentation
```

---

## 🎯 **SUCCESS CRITERIA**

### **Functional Requirements:**
- ✅ All 7 test users can authenticate
- ✅ RBAC permissions work correctly
- ✅ All API endpoints return 200 status codes
- ✅ Database relationships are consistent
- ✅ Seed data is realistic and comprehensive

### **Performance Requirements:**
- ✅ Authentication: < 500ms
- ✅ API responses: < 2s (95th percentile)
- ✅ Database queries: < 1s average
- ✅ No SQLAlchemy relationship errors

### **Data Quality Requirements:**
- ✅ 100+ policies across different products
- ✅ 50+ users with proper role assignments
- ✅ 20+ agents with territory assignments
- ✅ 500+ analytical data points
- ✅ Complete audit trails

---

## 🔧 **TOOLS & TECHNOLOGIES**

### **Database Tools:**
- **Flyway**: Schema migrations
- **pgAdmin/DBeaver**: Schema analysis
- **PostgreSQL**: Primary database
- **Redis**: Caching and sessions

### **Development Tools:**
- **SQLAlchemy**: ORM with proper relationship handling
- **Pydantic**: Data validation
- **FastAPI**: API framework
- **pytest**: Testing framework

### **Monitoring Tools:**
- **Prometheus**: Metrics collection
- **Grafana**: Dashboard visualization
- **ELK Stack**: Log analysis

---

## 📞 **RISK MITIGATION**

### **High-Risk Items:**
1. **Database Schema Changes** - Comprehensive testing required
2. **Authentication System** - Critical for all functionality
3. **RBAC Implementation** - Security implications

### **Contingency Plans:**
1. **Database Rollback** - Automated backup/restore procedures
2. **Feature Flags** - Gradual rollout capability
3. **Blue-Green Deployment** - Zero-downtime deployment strategy

---

## 📈 **MEASUREMENT & METRICS**

### **Key Performance Indicators:**
- **API Success Rate**: Target > 99%
- **Authentication Success Rate**: Target > 95%
- **Database Query Performance**: Target < 500ms average
- **User Onboarding Time**: Target < 5 minutes

### **Quality Metrics:**
- **Test Coverage**: Target > 85%
- **Code Quality**: Maintain A grade in SonarQube
- **Security Score**: Target > 8/10
- **Performance Score**: Target > 90/100

---

## 🎯 **FINAL DELIVERABLES**

1. **✅ Fully Functional Backend** - All APIs working
2. **✅ Complete Database Schema** - Aligned with models
3. **✅ Comprehensive Seed Data** - Realistic test scenarios
4. **✅ Working Authentication** - All user roles functional
5. **✅ API Documentation** - Complete with examples
6. **✅ Deployment Scripts** - Automated deployment process
7. **✅ Monitoring Dashboard** - Production monitoring setup
8. **✅ Testing Suite** - Comprehensive API testing framework

---

## 🚀 **NEXT STEPS**

1. **Immediate Action**: Begin Phase 1 database schema audit
2. **Week 1 Focus**: Fix all SQLAlchemy relationship issues
3. **Week 2 Focus**: Implement seed data and API testing
4. **Final Week**: Deployment and production validation

**Ready to proceed with implementation?**

---

*Document Version: 1.0 | Last Updated: November 28, 2025 | Author: Agent Mitra Development Team*
