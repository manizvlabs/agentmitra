# Agent Mitra - Complete App Restructuring & Conformance Plan

**Date:** December 1, 2024  
**Branch:** feature/v4  
**Objective:** Achieve 100% conformance with discovery documents using existing 272 API endpoints and 88 database tables

---

## Infrastructure & Deployment Disclaimer

### 🚨 IMPORTANT INFRASTRUCTURE REQUIREMENTS

**This implementation plan assumes the following infrastructure setup:**

#### Local Services (MacBook Brew)
- **PostgreSQL 16**: Must be running locally via `brew services start postgresql@16`
- **Redis**: Must be running locally via `brew services start redis`
- **Database**: `agentmitra_dev` with schema `lic_schema` (user: `agentmitra`, password: `agentmitra_dev`)

#### Docker Services (Production)
- **Pioneer Feature Flags**: Uses the Pioneer services defined in `docker-compose.prod.yml`
  - `pioneer-nats` (NATS messaging)
  - `pioneer-compass-server` (REST API on port 4001)
  - `pioneer-scout` (SSE on port 4002)
  - `pioneer-compass-client` (Admin UI on port 4000)

#### Deployment Scripts
- **Production Startup**: Use `scripts/deploy/start-prod.sh` for complete production deployment
- **Docker Compose**: Use `docker-compose.prod.yml` for container orchestration
- **Local Services**: PostgreSQL and Redis run outside Docker (local brew services)

#### Configuration Management
- **Flutter App**: All configuration via `.env` file
- **Backend API**: All configuration via `backend/env.production` or `backend/.env`
- **React Config Portal**: All configuration via `config-portal/.env`

**⚠️ CRITICAL**: Do not add PostgreSQL or Redis containers to `docker-compose.prod.yml`. These services must run locally on the MacBook via brew services for proper data persistence and performance.

**📋 Pre-deployment Checklist:**
1. `brew services start postgresql@16`
2. `brew services start redis`
3. Verify `agentmitra_dev` database exists with `lic_schema`
4. Ensure `.env` files are configured for all components
5. Run `scripts/deploy/start-prod.sh` for production startup

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Backend Integration Reference](#2-backend-integration-reference)
3. [Database Schema Reference](#3-database-schema-reference)
4. [Phase 1: Navigation Architecture Foundation](#4-phase-1-navigation-architecture-foundation)
5. [Phase 2: Customer Portal Restructuring](#5-phase-2-customer-portal-restructuring)
6. [Phase 3: Agent Portal Restructuring & Presentation Carousel](#6-phase-3-agent-portal-restructuring--presentation-carousel)
7. [Phase 4: Admin Portal Restructuring](#7-phase-4-admin-portal-restructuring)
8. [Phase 5: Onboarding Flow Implementation](#8-phase-5-onboarding-flow-implementation)
9. [Phase 6: React Config Portal Implementation](#9-phase-6-react-config-portal-implementation)
10. [Phase 7: Wireframe Conformance Verification](#10-phase-7-wireframe-conformance-verification)
11. [Phase 8: API & Database Integration Verification](#11-phase-8-api--database-integration-verification)
12. [Phase 9: Testing & Final Validation](#12-phase-9-testing--final-validation)
13. [Implementation Guidelines](#13-implementation-guidelines)

---

## 1. Executive Summary

This plan provides step-by-step instructions for restructuring the Agent Mitra Flutter mobile app and React config portal to achieve **100% conformance** with discovery documents while integrating with the **existing 272 backend API endpoints** and **88 database tables** in `agentmitra_dev.lic_schema`.

### Key Principles
1. **100% Wireframe Conformance** - Every screen must match `discovery/content/wireframes.md` exactly
2. **Zero Mock Data** - All screens must integrate with real backend APIs
3. **Real Database Queries** - Use existing 88 tables in `lic_schema` via repositories
4. **Flyway Migrations Only** - All database changes via existing migration files
5. **Role-Based Navigation** - Implement proper navigation hierarchy per user type
6. **Presentation Carousel** - Full implementation of new feature per `discovery/design/presentation-carousel-homepage.md`

### Discovery Documents Reference
- `discovery/content/wireframes.md` - **Primary UI/UX reference** (100% conformance required)
- `discovery/design/presentation-carousel-homepage.md` - **New feature specification**
- `discovery/content/information-architecture.md` - Information architecture and user types
- `discovery/content/navigation-hierarchy.md` - Navigation patterns and user flows
- `discovery/content/user-journey.md` - Complete user journey flows
- `discovery/content/content-structure.md` - Content organization and hierarchy

---

## 2. Backend Integration Reference

### 2.1 API Endpoint Categories (272 Total Endpoints - Verified from Backend)

**Note:** This section lists all actual API endpoints found in `backend/app/api/v1/`. Total count: 272 endpoints.

#### Authentication & Authorization (`/api/v1/auth/*`)
- `POST /api/v1/auth/login` - Agent code or phone + password login
- `POST /api/v1/auth/logout` - Logout user and invalidate session
- **Note:** OTP verification endpoints may be handled via external services (`/api/v1/external/sms/otp`, `/api/v1/external/whatsapp/otp`)

#### Users (`/api/v1/users/*`)
- `GET /api/v1/users/me` - Get current user profile
- `GET /api/v1/users/` - Search and filter users (admin/manager only)
- `GET /api/v1/users/{user_id}` - Get user by ID
- `PUT /api/v1/users/{user_id}` - Update user profile
- `DELETE /api/v1/users/{user_id}` - Deactivate user (soft delete)
- `GET /api/v1/users/{user_id}/preferences` - Get user preferences
- `PUT /api/v1/users/{user_id}/preferences` - Update user preferences

#### Agents (`/api/v1/agents/*`)
- `GET /api/v1/agents/profile` - Get current agent's profile
- `PUT /api/v1/agents/profile` - Update agent profile
- `PUT /api/v1/agents/settings` - Update agent settings
- `POST /api/v1/agents/profile/photo` - Upload agent profile photo
- `POST /api/v1/agents/verification/request` - Submit verification request
- `POST /api/v1/agents/verification/{agent_id}/approve` - Approve agent verification (admin)
- `GET /api/v1/agents/performance/metrics` - Get agent performance metrics
- `GET /api/v1/agents/hierarchy` - Get agent hierarchy (parent/child agents)
- `GET /api/v1/agents/search` - Search agents by name, code, or business name
- `GET /api/v1/agents/{agent_id}` - Get agent profile by ID (admin/staff only)

#### Policies (`/api/v1/policies/*`)
- `GET /api/v1/policies/` - List policies with filtering (by policyholder, agent, status, type, etc.)
- `GET /api/v1/policies/{policy_id}` - Get policy details
- `GET /api/v1/policies/number/{policy_number}` - Get policy by policy number
- `POST /api/v1/policies/` - Create new policy
- `PUT /api/v1/policies/{policy_id}` - Update policy
- `DELETE /api/v1/policies/{policy_id}` - Delete policy
- `POST /api/v1/policies/{policy_id}/approve` - Approve policy
- `POST /api/v1/policies/{policy_id}/activate` - Activate policy
- `GET /api/v1/policies/{policy_id}/coverage` - Get policy coverage details
- `GET /api/v1/policies/{policy_id}/premiums` - Get premium payment schedule
- `GET /api/v1/policies/{policy_id}/claims` - Get claims history

#### Dashboard (`/api/v1/dashboard/*`)
- `GET /api/v1/dashboard/analytics` - Dashboard analytics summary (main router endpoint)
- `GET /api/v1/dashboard/home` - Agent home dashboard (includes carousel, KPIs, feature tiles)
- `GET /api/v1/dashboard/presentations/carousel` - Presentation carousel items
- `GET /api/v1/dashboard/feature-tiles` - Feature tiles for dashboard
- `GET /api/v1/dashboard/analytics/summary` - Analytics summary with period filter
- `POST /api/v1/dashboard/activity/log` - Log user activity on dashboard
- `GET /api/v1/dashboard/system-overview` - System overview (Super Admin)
- `GET /api/v1/dashboard/provider-overview` - Provider overview (Provider Admin)
- `GET /api/v1/dashboard/regional-overview` - Regional overview (Regional Manager)
- `GET /api/v1/dashboard/senior-agent-overview` - Senior agent overview

#### Presentations (`/api/v1/presentations/*`)
- `GET /api/v1/presentations/agent/{agent_id}/active` - Get active presentation
- `GET /api/v1/presentations/agent/{agent_id}` - Get all agent presentations
- `POST /api/v1/presentations/agent/{agent_id}` - Create presentation
- `PUT /api/v1/presentations/agent/{agent_id}/{presentation_id}` - Update presentation
- `POST /api/v1/presentations/media/upload` - Upload media (image/video)
- `GET /api/v1/presentations/templates` - Get presentation templates

#### Chat & Communication (`/api/v1/chat/*`, `/api/v1/external/*`)
- `POST /api/v1/chat/sessions` - Create chat session
- `POST /api/v1/chat/sessions/{session_id}/messages` - Send message in session
- `PUT /api/v1/chat/sessions/{session_id}/end` - End chat session
- `GET /api/v1/chat/sessions/{session_id}/analytics` - Get session analytics
- `POST /api/v1/chat/knowledge-base/articles` - Create knowledge base article
- `PUT /api/v1/chat/knowledge-base/articles/{article_id}` - Update article
- `GET /api/v1/chat/knowledge-base/search` - Search knowledge base
- `DELETE /api/v1/chat/knowledge-base/articles/{article_id}` - Delete article
- `POST /api/v1/chat/intents` - Create chatbot intent
- `GET /api/v1/chat/intents/stats` - Get intent statistics
- `GET /api/v1/chat/analytics` - Get chatbot analytics
- `GET /api/v1/chat/health` - Chat service health check
- `POST /api/v1/chat/advanced/chat` - Advanced chat with AI
- `GET /api/v1/chat/analytics/intent` - Intent analytics
- `GET /api/v1/chat/analytics/quality` - Chat quality metrics
- `POST /api/v1/chat/intents/train` - Train chatbot intents
- `GET /api/v1/chat/suggestions/proactive` - Get proactive suggestions
- `POST /api/v1/chat/escalate` - Escalate chat to human
- `GET /api/v1/chat/conversation/quality/{session_id}` - Conversation quality score
- `POST /api/v1/chat/language/detect` - Detect conversation language
- `POST /api/v1/chat/escalation/callback` - Request callback
- `GET /api/v1/chat/reports/callbacks` - Get callback reports
- `PUT /api/v1/chat/reports/callbacks/{callback_id}/status` - Update callback status
- `GET /api/v1/chat/reports/analytics` - Chat reports analytics

#### External Services (`/api/v1/external/*`)
- `POST /api/v1/external/sms/send` - Send SMS message
- `POST /api/v1/external/sms/otp` - Send SMS OTP
- `GET /api/v1/external/sms/status/{message_id}` - Get SMS status
- `POST /api/v1/external/whatsapp/send` - Send WhatsApp message
- `POST /api/v1/external/whatsapp/otp` - Send WhatsApp OTP
- `POST /api/v1/external/whatsapp/template` - Send WhatsApp template message
- `GET /api/v1/external/whatsapp/templates` - Get WhatsApp templates
- `GET /api/v1/external/whatsapp/status/{message_id}` - Get WhatsApp status
- `POST /api/v1/external/whatsapp/webhook` - WhatsApp webhook handler
- `GET /api/v1/external/whatsapp/webhook` - Get webhook configuration
- `POST /api/v1/external/ai/chat` - AI chat completion
- `POST /api/v1/external/ai/intent` - AI intent classification
- `POST /api/v1/external/ai/summarize` - AI text summarization
- `POST /api/v1/external/ai/generate` - AI content generation
- `POST /api/v1/external/ai/translate` - AI translation
- `POST /api/v1/external/ai/sentiment` - AI sentiment analysis
- `POST /api/v1/external/ai/moderate` - AI content moderation
- `GET /api/v1/external/ai/usage` - Get AI service usage stats

#### Analytics (`/api/v1/analytics/*`)
- `GET /api/v1/analytics/roi/agent/{agent_id}` - ROI analytics for agent
- `GET /api/v1/analytics/roi/dashboard/{agent_id}` - ROI dashboard data
- `GET /api/v1/analytics/forecast/revenue/{agent_id}` - Revenue forecast
- `GET /api/v1/analytics/forecast/dashboard/{agent_id}` - Forecast dashboard
- `GET /api/v1/analytics/leads/hot/{agent_id}` - Get hot leads for agent
- `GET /api/v1/analytics/leads/dashboard/{agent_id}` - Leads dashboard data
- `GET /api/v1/analytics/leads/{lead_id}/details` - Get lead details
- `GET /api/v1/analytics/customers/at-risk/{agent_id}` - Get at-risk customers
- `GET /api/v1/analytics/customers/retention/dashboard/{agent_id}` - Retention dashboard
- `GET /api/v1/analytics/customers/{customer_id}/retention-plan` - Customer retention plan
- `GET /api/v1/analytics/comprehensive/dashboard` - Comprehensive analytics dashboard
- `GET /api/v1/analytics/agents/performance/{agent_id}` - Agent performance metrics
- `GET /api/v1/analytics/agents/performance` - All agents performance comparison
- `GET /api/v1/analytics/policies/analytics` - Policy analytics
- `GET /api/v1/analytics/payments/analytics` - Payment analytics
- `GET /api/v1/analytics/users/engagement` - User engagement metrics
- `POST /api/v1/analytics/reports/custom` - Generate custom analytics report
- `GET /api/v1/analytics/export/{data_type}` - Export analytics data
- `GET /api/v1/analytics/reports/performance-summary` - Performance summary report
- `GET /api/v1/analytics/insights/business-intelligence` - Business intelligence insights
- `GET /api/v1/analytics/dashboard/overview` - Dashboard overview KPIs
- `GET /api/v1/analytics/dashboard/{agent_id}` - Agent-specific dashboard KPIs
- `GET /api/v1/analytics/dashboard/charts/revenue-trends` - Revenue trend charts
- `GET /api/v1/analytics/dashboard/charts/policy-trends` - Policy trend charts
- `GET /api/v1/analytics/dashboard/top-agents` - Top performing agents
- `GET /api/v1/analytics/agents/{agent_id}/performance` - Detailed agent performance
- `GET /api/v1/analytics/agents/performance/comparison` - Agent performance comparison
- `GET /api/v1/analytics/policies/analytics` - Policy analytics (duplicate endpoint)
- `GET /api/v1/analytics/revenue/analytics` - Revenue analytics
- `GET /api/v1/analytics/presentations/{presentation_id}/analytics` - Presentation analytics
- `GET /api/v1/analytics/presentations/{presentation_id}/analytics/trends` - Presentation trends
- `POST /api/v1/analytics/reports/generate` - Generate analytics report
- `GET /api/v1/analytics/reports/summary` - Reports summary

#### Campaigns (`/api/v1/campaigns/*`)
- `POST /api/v1/campaigns` - Create campaign
- `GET /api/v1/campaigns` - List campaigns
- `GET /api/v1/campaigns/templates` - Get campaign templates
- `GET /api/v1/campaigns/{campaign_id}` - Get campaign details
- `PUT /api/v1/campaigns/{campaign_id}` - Update campaign
- `POST /api/v1/campaigns/{campaign_id}/launch` - Launch campaign
- `GET /api/v1/campaigns/{campaign_id}/analytics` - Campaign performance analytics
- `POST /api/v1/campaigns/templates/{template_id}/create` - Create campaign from template
- `GET /api/v1/campaigns/recommendations` - Get campaign recommendations

#### Content (`/api/v1/content/*`)
- `POST /api/v1/content/upload` - Upload content file
- `GET /api/v1/content/` - List content files
- `GET /api/v1/content/{content_id}` - Get content details
- `GET /api/v1/content/{content_id}/download` - Download content file
- `DELETE /api/v1/content/{content_id}` - Delete content
- `POST /api/v1/content/{content_id}/share` - Share content
- `GET /api/v1/content/shared/{share_token}` - Get shared content
- `PUT /api/v1/content/{content_id}/tags` - Update content tags
- `GET /api/v1/content/analytics/overview` - Content analytics overview
- `GET /api/v1/content/categories` - Get content categories
- `GET /api/v1/content/types` - Get content types
- `POST /api/v1/content/videos/upload` - Upload video content
- `GET /api/v1/content/videos` - Get video library with filters
- `GET /api/v1/content/videos/{video_id}` - Get video details
- `POST /api/v1/content/videos/{video_id}/progress` - Update video watch progress
- `GET /api/v1/content/videos/recommendations` - Get video recommendations
- `GET /api/v1/content/videos/categories` - Get video categories

#### Customers (`/api/v1/customers/*` - via agents endpoint)
- `GET /api/v1/agents/{agent_id}/customers` - List customers
- Customer details via policies and policyholders tables

#### CRM & Lead Management (`/api/v1/analytics/*`, `/api/v1/leads/*` - **MISSING CRUD APIs**)
- `GET /api/v1/analytics/leads/hot/{agent_id}` - Get hot leads for agent
- `GET /api/v1/analytics/leads/dashboard/{agent_id}` - Get leads dashboard data
- `GET /api/v1/analytics/leads/{lead_id}/details` - Get lead details
- `GET /api/v1/analytics/customers/at-risk/{agent_id}` - Get at-risk customers (retention)
- `GET /api/v1/analytics/customers/retention/dashboard/{agent_id}` - Get retention dashboard
- `GET /api/v1/analytics/customers/{customer_id}/retention-plan` - Get customer retention plan

**⚠️ MISSING APIs - Implementation Required:**
- `POST /api/v1/leads/` - Create new lead (NOT IMPLEMENTED)
- `GET /api/v1/leads/` - List leads with filters (NOT IMPLEMENTED)
- `GET /api/v1/leads/{lead_id}` - Get lead by ID (NOT IMPLEMENTED)
- `PUT /api/v1/leads/{lead_id}` - Update lead (NOT IMPLEMENTED)
- `DELETE /api/v1/leads/{lead_id}` - Delete lead (NOT IMPLEMENTED)
- `POST /api/v1/leads/{lead_id}/interactions` - Add lead interaction (NOT IMPLEMENTED)
- `GET /api/v1/leads/{lead_id}/interactions` - Get lead interactions (NOT IMPLEMENTED)
- `PUT /api/v1/leads/{lead_id}/qualify` - Qualify/disqualify lead (NOT IMPLEMENTED)
- `PUT /api/v1/leads/{lead_id}/convert` - Convert lead to policy (NOT IMPLEMENTED)

**Note:** 
- Leads are currently accessed via analytics endpoints only. Full CRUD endpoints for `/api/v1/leads/*` need to be implemented for direct lead management.
- Customer segmentation data is available through analytics endpoints but may not have dedicated CRUD endpoints.
- See **Section 2.2: Implementation Plan for Missing APIs** below for detailed implementation requirements.

#### Notifications (`/api/v1/notifications/*`)
- `GET /api/v1/notifications/` - Get notifications list
- `GET /api/v1/notifications/statistics` - Get notification statistics
- `GET /api/v1/notifications/{notification_id}` - Get notification details
- `PATCH /api/v1/notifications/{notification_id}/read` - Mark notification as read
- `PATCH /api/v1/notifications/read` - Mark multiple notifications as read
- `DELETE /api/v1/notifications/{notification_id}` - Delete notification
- `POST /api/v1/notifications/` - Create notification
- `POST /api/v1/notifications/bulk` - Create bulk notifications
- `POST /api/v1/notifications/test` - Send test notification
- `GET /api/v1/notifications/settings` - Get notification settings
- `PUT /api/v1/notifications/settings` - Update notification settings
- `POST /api/v1/notifications/device-token` - Register device token for push notifications

#### Data Import (`/api/v1/import/*`)
- `GET /api/v1/import/templates` - Get all import templates
- `POST /api/v1/import/templates` - Create new import template
- `PUT /api/v1/import/templates/{template_id}` - Update import template
- `DELETE /api/v1/import/templates/{template_id}` - Delete import template
- `POST /api/v1/import/upload` - Upload Excel/CSV file for import
- `POST /api/v1/import/validate/{file_id}` - Validate uploaded file
- `POST /api/v1/import/data` - Import validated data
- `GET /api/v1/import/status/{import_id}` - Get import job status
- `GET /api/v1/import/history` - Get import history with pagination
- `GET /api/v1/import/entity-fields/{entity_type}` - Get entity field definitions
- `GET /api/v1/import/sample-data/{entity_type}` - Get sample data for entity type
- `GET /api/v1/import/templates/{entity_type}/download` - Download template file
- `GET /api/v1/import/results/{import_id}/download` - Download import results

#### RBAC (`/api/v1/rbac/*`)
- `GET /api/v1/rbac/roles` - List all roles
- `GET /api/v1/rbac/users/{user_id}/roles` - Get user roles
- `POST /api/v1/rbac/users/assign-role` - Assign role to user
- `POST /api/v1/rbac/users/remove-role` - Remove role from user
- `GET /api/v1/rbac/permissions` - List all permissions
- `POST /api/v1/rbac/feature-flags` - Create feature flag
- `GET /api/v1/rbac/feature-flags` - List feature flags
- `GET /api/v1/rbac/check-permission` - Check user permission
- `GET /api/v1/rbac/audit-log` - Get RBAC audit log

#### System & Configuration (`/api/v1/tenants/*`, `/api/v1/feature-flags/*`)
- `POST /api/v1/tenants/` - Create new tenant (multi-tenant configuration)
- `GET /api/v1/tenants/` - List all tenants (Super Admin only)
- `GET /api/v1/tenants/{tenant_id}` - Get tenant details
- `PUT /api/v1/tenants/{tenant_id}/deactivate` - Deactivate tenant
- `PUT /api/v1/tenants/{tenant_id}/reactivate` - Reactivate tenant
- `POST /api/v1/tenants/{tenant_id}/config` - Update tenant configuration

#### Feature Flags (`/api/v1/feature-flags/*`)
- `GET /api/v1/feature-flags/user/{user_id}` - Get feature flags for user
- `GET /api/v1/feature-flags/tenant/{tenant_id}` - Get feature flags for tenant
- `GET /api/v1/feature-flags/all` - Get all feature flags
- `PUT /api/v1/feature-flags/user/{user_id}/{flag_name}` - Update user feature flag override
- `PUT /api/v1/feature-flags/tenant/{tenant_id}/{flag_name}` - Update tenant feature flag override
- `POST /api/v1/feature-flags/create` - Create new feature flag
- `DELETE /api/v1/feature-flags/override/user/{user_id}/{flag_name}` - Delete user override
- `PUT /api/v1/feature-flags/update/{flag_name}` - Update feature flag
- `GET /api/v1/feature-flags/api/flags` - Get flags via API
- `POST /api/v1/feature-flags/flags` - Create feature flag
- `PUT /api/v1/feature-flags/flags/{flag_id}` - Update feature flag
- `DELETE /api/v1/feature-flags/flags/{flag_id}` - Delete feature flag
- `GET /api/v1/feature-flags/check/{flag_name}` - Check feature flag status
- `POST /api/v1/feature-flags/role-access` - Set role-based feature access
- `POST /api/v1/feature-flags/broadcast/role/{role_name}` - Broadcast flag to role
- `POST /api/v1/feature-flags/broadcast/tenant/{tenant_id}` - Broadcast flag to tenant
- `GET /api/v1/feature-flags/websocket/stats` - WebSocket connection stats
- `GET /api/v1/feature-flags/role-access/{role_name}` - Get role feature access
- `GET /api/v1/feature-flags/access-control/rules` - Get access control rules

#### Quotes (`/api/v1/quotes/*`)
- `POST /api/v1/quotes/` - Create new quote
- `GET /api/v1/quotes/` - List quotes with filters
- `GET /api/v1/quotes/{quote_id}` - Get quote details
- `PUT /api/v1/quotes/{quote_id}` - Update quote
- `DELETE /api/v1/quotes/{quote_id}` - Delete quote
- `POST /api/v1/quotes/{quote_id}/publish` - Publish quote
- `POST /api/v1/quotes/{quote_id}/share` - Share quote
- `POST /api/v1/quotes/{quote_id}/performance` - Track quote performance
- `GET /api/v1/quotes/{quote_id}/analytics` - Get quote analytics
- `GET /api/v1/quotes/analytics/summary` - Get quotes analytics summary
- `GET /api/v1/quotes/categories/list` - Get quote categories

#### Subscription (`/api/v1/subscription/*`)
- `GET /api/v1/subscription/plans` - List all subscription plans
- `GET /api/v1/subscription/plans/{plan_id}` - Get subscription plan details
- `POST /api/v1/subscription/create` - Create subscription
- `GET /api/v1/subscription/details` - Get current user subscription details
- `POST /api/v1/subscription/upgrade` - Upgrade subscription plan
- `POST /api/v1/subscription/downgrade` - Downgrade subscription plan
- `POST /api/v1/subscription/cancel` - Cancel subscription
- `GET /api/v1/subscription/billing-history` - Get billing history
- `POST /api/v1/subscription/process-trial-expiration` - Process trial expiration
- `GET /api/v1/subscription/available-upgrades` - Get available upgrade options
- `GET /api/v1/subscription/compare-plans` - Compare subscription plans

#### Trial (`/api/v1/trial/*`)
- `POST /api/v1/trial/setup` - Setup trial for user
- `GET /api/v1/trial/status/{user_id}` - Get trial status for user
- `POST /api/v1/trial/extend/{user_id}` - Extend trial period
- `POST /api/v1/trial/convert/{user_id}` - Convert trial to paid subscription
- `POST /api/v1/trial/engagement/{user_id}` - Track trial engagement
- `GET /api/v1/trial/analytics/overview` - Trial analytics overview
- `GET /api/v1/trial/expiring-soon` - Get trials expiring soon
- `POST /api/v1/trial/send-reminder/{user_id}` - Send trial expiration reminder

---

### 2.2 Implementation Plan for Missing APIs

#### Leads CRUD API Implementation (`/api/v1/leads/*`)

**Priority:** High  
**Estimated Effort:** 2-3 days  
**Dependencies:** `lic_schema.leads` table (exists), `lic_schema.lead_interactions` table (exists)

**Required Endpoints:**

1. **`POST /api/v1/leads/`** - Create new lead
   - **Request Body:** Lead creation request (customer_name, contact_number, email, location, lead_source, insurance_type, budget_range, coverage_required, agent_id)
   - **Response:** Created lead object with lead_id
   - **Database:** Insert into `lic_schema.leads` table
   - **Validation:** Required fields, phone format, email format

2. **`GET /api/v1/leads/`** - List leads with filters
   - **Query Parameters:** agent_id, lead_status, priority, lead_source, insurance_type, limit, offset
   - **Response:** Paginated list of leads
   - **Database:** Query `lic_schema.leads` with filters
   - **Permissions:** Agents can only see their own leads, admins can see all

3. **`GET /api/v1/leads/{lead_id}`** - Get lead by ID
   - **Response:** Complete lead object with all fields
   - **Database:** Query `lic_schema.leads` by lead_id
   - **Permissions:** Agent must own lead or be admin

4. **`PUT /api/v1/leads/{lead_id}`** - Update lead
   - **Request Body:** Partial lead update (any updatable fields)
   - **Response:** Updated lead object
   - **Database:** Update `lic_schema.leads` table
   - **Validation:** Field-level validation
   - **Auto-update:** Conversion score and priority based on updated fields

5. **`DELETE /api/v1/leads/{lead_id}`** - Delete lead (soft delete)
   - **Response:** Success message
   - **Database:** Update `lic_schema.leads.status` to 'inactive' (soft delete)
   - **Cascade:** Delete related `lead_interactions` records

6. **`POST /api/v1/leads/{lead_id}/interactions`** - Add lead interaction
   - **Request Body:** Interaction data (interaction_type, interaction_method, duration_minutes, outcome, notes, next_action, next_action_date)
   - **Response:** Created interaction object
   - **Database:** Insert into `lic_schema.lead_interactions` table
   - **Auto-update:** Update lead's `last_contact_at`, `last_contact_method`, `followup_count`

7. **`GET /api/v1/leads/{lead_id}/interactions`** - Get lead interactions
   - **Response:** List of interactions for the lead
   - **Database:** Query `lic_schema.lead_interactions` filtered by lead_id

8. **`PUT /api/v1/leads/{lead_id}/qualify`** - Qualify/disqualify lead
   - **Request Body:** is_qualified (boolean), qualification_notes, disqualification_reason
   - **Response:** Updated lead object
   - **Database:** Update `lic_schema.leads.is_qualified`, `qualification_notes`, `disqualification_reason`

9. **`PUT /api/v1/leads/{lead_id}/convert`** - Convert lead to policy
   - **Request Body:** converted_policy_id, conversion_value
   - **Response:** Updated lead object with conversion details
   - **Database:** Update `lic_schema.leads.converted_at`, `converted_policy_id`, `conversion_value`, `lead_status` to 'converted'

**Implementation Steps:**

1. **Create API Router File:** `backend/app/api/v1/leads.py`
   - Import FastAPI router, dependencies, models
   - Create Pydantic request/response models

2. **Create Repository:** `backend/app/repositories/lead_repository.py`
   - Implement CRUD operations for `lic_schema.leads` table
   - Implement filtering and search methods
   - Handle lead scoring calculations

3. **Create Service Layer:** `backend/app/services/lead_service.py` (optional)
   - Business logic for lead management
   - Lead scoring calculations
   - Conversion tracking

4. **Register Router:** Add to `backend/app/api/v1/__init__.py`
   ```python
   from . import leads
   api_router.include_router(leads.router, prefix="/leads", tags=["leads"])
   ```

5. **Add Permissions:** Update RBAC permissions for lead management
   - `leads.create`, `leads.read`, `leads.update`, `leads.delete`

6. **Testing:**
   - Unit tests for repository methods
   - Integration tests for API endpoints
   - Test lead scoring calculations
   - Test conversion tracking

**Database Tables Used:**
- `lic_schema.leads` - Main lead records (exists)
- `lic_schema.lead_interactions` - Lead interaction history (exists)
- `lic_schema.insurance_policies` - For conversion tracking (exists)
- `lic_schema.agents` - For agent association (exists)

**Acceptance Criteria:**
- [ ] All 9 endpoints implemented and tested
- [ ] Proper error handling and validation
- [ ] Role-based access control implemented
- [ ] Lead scoring automatically calculated
- [ ] Conversion tracking works correctly
- [ ] Integration with existing analytics endpoints maintained

---

## 3. Database Schema Reference

### 3.1 Core Tables (88 Total Tables in `lic_schema` - Verified from Migration Files)

#### User & Authentication Tables
- `users` - User accounts and profiles (multi-tenant)
- `user_sessions` - Active user sessions with tokens
- `agents` - Agent profiles and business information
- `policyholders` - Policyholder/customer information
- `user_roles` - User-role assignments
- `tenant_users` - Tenant-specific user mappings

#### Policy & Insurance Tables
- `insurance_policies` - Insurance policy records
- `premium_payments` - Premium payment records
- `user_payment_methods` - User payment method storage
- `insurance_providers` - Insurance provider information
- `insurance_categories` - Insurance product categories

#### Presentation & Content Tables
- `presentations` - Presentation records (per agent)
- `presentation_slides` - Individual slides within presentations
- `presentation_templates` - Template library
- `presentation_media` - Media files (images/videos) for presentations
- `presentation_analytics` - Presentation performance analytics
- `agent_presentation_preferences` - Agent presentation preferences
- `video_content` - Video tutorial library
- `video_analytics` - Video watch analytics

#### Communication Tables
- `chat_messages` - Chat message threads
- `chatbot_sessions` - Chatbot conversation sessions
- `chatbot_intents` - Chatbot intent definitions
- `chatbot_analytics_summary` - Chatbot performance analytics
- `whatsapp_messages` - WhatsApp message records
- `whatsapp_templates` - WhatsApp template library
- `notifications` - System notifications
- `notification_settings` - User notification preferences
- `device_tokens` - Push notification device tokens

#### Analytics & Campaign Tables
- `campaigns` - Marketing campaign records
- `campaign_triggers` - Campaign trigger definitions
- `campaign_executions` - Campaign execution logs
- `campaign_templates` - Campaign template library
- `campaign_responses` - Campaign response tracking
- `callback_requests` - Callback request records
- `callback_activities` - Callback activity logs
- `agent_daily_metrics` - Daily agent performance metrics
- `agent_monthly_summary` - Monthly agent performance summary
- `revenue_forecasts` - Revenue forecasting data
- `revenue_forecast_scenarios` - Revenue forecast scenarios
- `policy_analytics_summary` - Policy analytics aggregations
- `customer_behavior_metrics` - Customer behavior tracking
- `analytics_query_log` - Analytics query logging
- `data_export_log` - Data export logging

#### CRM & Lead Management Tables
- `leads` - Lead records (with scoring, conversion tracking, follow-up scheduling)
- `lead_interactions` - Lead interaction history and follow-up tracking
- `customer_retention_analytics` - Retention analytics and churn prediction data
- `retention_actions` - Retention action planning and execution tracking
- `predictive_insights` - AI-generated insights and recommendations

#### System & Configuration Tables
- `tenants` - Multi-tenant configuration (tenant provisioning, status, limits)
- `tenant_config` - Tenant-specific configuration settings
- `tenant_usage` - Tenant usage tracking and limits
- `commissions` - Commission calculation and tracking
- `feature_flags` - Feature flag configuration
- `feature_flag_overrides` - User/tenant-specific feature flag overrides
- `roles` - RBAC roles definition
- `permissions` - RBAC permissions definition
- `role_permissions` - Role-permission mappings
- `rbac_audit_log` - RBAC audit trail

#### Subscription & Billing Tables
- `subscription_plans` - Available subscription plans
- `user_subscriptions` - User subscription records
- `subscription_billing_history` - Billing history
- `subscription_changes` - Subscription change audit log
- `trial_subscriptions` - Trial subscription records
- `trial_engagement` - Trial user engagement tracking

#### Knowledge Base & Learning Tables
- `knowledge_base_articles` - Knowledge base article content
- `knowledge_search_log` - Knowledge base search analytics
- `daily_quotes` - Daily motivational quotes
- `quote_sharing_analytics` - Quote sharing analytics
- `quote_performance` - Quote performance metrics

#### Customer Portal & Engagement Tables
- `customer_portal_sessions` - Customer portal session tracking
- `customer_engagement_metrics` - Customer engagement metrics
- `customer_portal_preferences` - Customer portal preferences
- `customer_feedback` - Customer feedback records
- `customer_journey_events` - Customer journey event tracking
- `customer_retention_metrics` - Customer retention metrics

#### KYC & Document Management Tables
- `kyc_documents` - KYC document storage references
- `document_ocr_results` - OCR processing results
- `kyc_manual_reviews` - KYC manual review records
- `emergency_contacts` - Emergency contact information
- `emergency_contact_verifications` - Emergency contact verification records

#### Reference Data Tables
- `countries` - Country reference data
- `languages` - Language reference data
- `insurance_categories` - Insurance category reference data
- `insurance_providers` - Insurance provider reference data

#### User Journey & Analytics Tables
- `user_journeys` - User journey tracking and analytics

#### Data Import Tables
- `data_imports` - Import job records
- `import_jobs` - Import job execution tracking
- `customer_data_mapping` - Customer data field mappings
- `data_sync_status` - Data synchronization status tracking

---

## 4. Phase 1: Navigation Architecture Foundation (Days 1-2)

### Step 1.1: Create Navigation Container Components

**Location:** `lib/navigation/`

**Tasks:**
1. Create `lib/navigation/customer_navigation.dart`
   - Bottom tab bar with 5 tabs: Home, Policies, Chat, Learning, Profile
   - Drawer menu for secondary navigation
   - Tab state management using Riverpod/Provider
   - Navigation between tabs

2. Create `lib/navigation/agent_navigation.dart`
   - Bottom tab bar with 5 tabs: Dashboard, Customers, Analytics, Campaigns, Profile
   - Hamburger menu (side drawer) for advanced tools
   - Tab state management

3. Create `lib/navigation/admin_navigation.dart`
   - Contextual navigation based on admin role (Super Admin, Provider Admin, Regional Manager)
   - Tab-based or drawer-based navigation
   - Role-based content filtering

4. Create `lib/navigation/navigation_router.dart`
   - Role-based route generation
   - Protected route wrapper
   - Deep linking support

**Wireframe Reference:** `discovery/content/wireframes.md` Section 3.0.1 (Agent Side Drawer), Section 4.1 (Customer Dashboard navigation)

**API Integration:** None (pure navigation structure)

**Acceptance Criteria:**
- [ ] Customer navigation has 5 bottom tabs as specified
- [ ] Agent navigation has 5 bottom tabs as specified
- [ ] Admin navigation adapts to role
- [ ] Navigation containers handle tab switching correctly
- [ ] Drawer/hamburger menus work properly

---

### Step 1.2: Update Main App Routing

**Location:** `lib/main.dart`

**Tasks:**
1. Replace flat routing with navigation container routing
2. Implement role-based initial route selection using `AuthService`
3. Update `_getInitialRoute()` to use navigation containers
4. Remove individual screen routes, replace with tab-based navigation

**Code Pattern:**
```dart
// Instead of:
'/customer-dashboard': (context) => CustomerDashboard(),

// Use:
'/customer-portal': (context) => CustomerNavigationContainer(),
```

**Wireframe Reference:** `discovery/content/navigation-hierarchy.md` Section 4

**Acceptance Criteria:**
- [ ] Main routing uses navigation containers
- [ ] Role-based routing works correctly
- [ ] Deep links navigate to correct tab
- [ ] Back navigation works properly

---

## 5. Phase 2: Customer Portal Restructuring (Days 3-5)

### Step 2.1: Create Unified Customer Dashboard (Home Tab)

**Location:** `lib/features/customer_dashboard/presentation/pages/customer_dashboard_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Section 4.1 - "Customer Dashboard (Home Screen) - Clutter-Free Design"

**Exact Wireframe Requirements:**
- Red header bar with white text: "👋 Welcome back, {Name}!" + "📅 Today: DD MMM YYYY • 🌙 Dark Theme"
- Smart Search (Global) - collapsible
- Essential Quick Actions (Priority Section): 3 tiles - "💳 Pay Premium", "📞 Contact Agent", "❓ Get Quote"
- Policy Overview (Key Metrics Only): Active Policies count, Next Payment amount & date, Total Coverage amount
- Critical Notifications (Priority-Based): Color-coded alerts (🔴 Premium due, 🟡 Policy renewal reminder)
- Theme Switcher (Top Right Corner): 🌙 Dark / ☀️ Light toggle

**API Integration:**
- `GET /api/v1/dashboard/analytics` - Dashboard summary
- `GET /api/v1/policies` - Policy list (for overview)
- `GET /api/v1/notifications` - Notifications (priority-based)
- `GET /api/v1/users/me` - User profile (for welcome message)

**Database Tables:**
- `lic_schema.users` - User profile
- `lic_schema.insurance_policies` - Policy data
- `lic_schema.notifications` - Notification records
- `lic_schema.policy_payments` - Payment schedule

**Tasks:**
1. Restructure `customer_dashboard.dart` to match wireframe exactly
2. Implement "Clutter-Free Design" with exact spacing and layout
3. Remove all mock data, use `CustomerDashboardViewModel` with real API calls
4. Implement Quick Actions section with exact icons and colors
5. Implement Policy Overview with real metrics
6. Implement Critical Notifications with priority-based color coding
7. Implement Theme Switcher functionality

**Acceptance Criteria:**
- [ ] Dashboard matches wireframe Section 4.1 exactly (layout, colors, spacing)
- [ ] All data comes from real API endpoints
- [ ] Quick Actions navigate correctly
- [ ] Policy Overview shows real data from `insurance_policies` table
- [ ] Notifications are priority-based and color-coded
- [ ] Theme switcher works and persists preference
- [ ] No mock/placeholder data

---

### Step 2.2: Create Policies Tab Content

**Location:** `lib/features/policies/presentation/pages/policies_tab_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Section 4.2 - "Policy Details Screen"

**Exact Wireframe Requirements:**
- Policy list with searchable, filterable cards
- Policy Details page with tabs: Overview, Coverage, Premium, Documents, Claims
- Policy card shows: Policy No, Plan name, Start Date, Status
- Premium & Payment section: Annual Premium, Next Due date, Payment Method, Payment History link
- Coverage & Benefits section: Sum Assured, Bonus, Maturity date
- Quick Actions: Pay Premium, Download Documents, Get Help

**API Integration:**
- `GET /api/v1/policies` - List all policies
- `GET /api/v1/policies/{policy_id}` - Policy details
- `GET /api/v1/policies/{policy_id}/payments` - Payment history
- `GET /api/v1/policies/{policy_id}/documents` - Policy documents
- `GET /api/v1/policies/{policy_id}/claims` - Claims history

**Database Tables:**
- `lic_schema.insurance_policies` - Policy records
- `lic_schema.policy_payments` - Payment history
- `lic_schema.policy_documents` - Document references
- `lic_schema.policy_claims` - Claim records
- `lic_schema.policy_premiums` - Premium schedule

**Tasks:**
1. Consolidate `my_policies_screen.dart`, `policy_details_screen.dart`, `premium_calendar_screen.dart` into single Policies tab
2. Implement policy card structure matching wireframe exactly
3. Implement policy detail page with all required tabs
4. Implement search and filter functionality
5. Remove mock data, use real API responses

**Note:** Premium Payment flow is **deferred** per wireframes (Section 4.3 note), but UI must exist with "Contact Agent" redirection.

**Acceptance Criteria:**
- [ ] Policies tab shows all policies from API
- [ ] Policy cards match wireframe Section 4.2 exactly
- [ ] Policy details page has all required tabs
- [ ] Search and filter work correctly
- [ ] Payment history shows real data
- [ ] Documents download from real API
- [ ] No mock data

---

### Step 2.3: Create Chat Tab Content

**Location:** `lib/features/chat/presentation/pages/chat_tab_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Sections 4.4 (WhatsApp Integration) and 4.5 (Smart Chatbot Interface)

**Exact Wireframe Requirements:**
- WhatsApp Integration Screen: Message thread, Quick message templates, Direct WhatsApp Chat button
- Smart Assistant: Chat interface, Knowledge base integration, Video tutorial suggestions, Smart help options

**API Integration:**
- `GET /api/v1/chat/threads` - Get message threads
- `GET /api/v1/chat/messages` - Get messages
- `POST /api/v1/chat/messages` - Send message
- `POST /api/v1/external/whatsapp/send` - Send WhatsApp message
- `POST /api/v1/chatbot/query` - Submit chatbot query (if chatbot endpoint exists)

**Database Tables:**
- `lic_schema.chat_messages` - Message threads
- `lic_schema.whatsapp_messages` - WhatsApp message records
- `lic_schema.whatsapp_templates` - Quick message templates

**Tasks:**
1. Consolidate `whatsapp_integration_screen.dart`, `smart_chatbot_screen.dart`, `agent_chat_screen.dart` into Chat tab
2. Implement message thread design matching wireframes
3. Implement WhatsApp integration using real WhatsApp API
4. Implement Smart Assistant UI (connect to chatbot backend if available)
5. Remove mock data

**Acceptance Criteria:**
- [ ] Chat tab shows real messages from API
- [ ] WhatsApp integration works with real API
- [ ] Smart Assistant UI matches wireframe Section 4.5
- [ ] Message threads display correctly
- [ ] Quick templates work
- [ ] No mock data

---

### Step 2.4: Create Learning Tab Content

**Location:** `lib/features/learning/presentation/pages/learning_tab_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Section 4.6 - "Video Learning Center"

**Exact Wireframe Requirements:**
- Featured Content (YouTube Integration): Video cards with thumbnail, duration, views, rating
- Categories: Insurance Basics, Money Management, Policy Management
- Recent Additions: Agent-uploaded content with upload date and agent name
- Learning Analytics: Videos Watched count, Total Time, Learning Streak, Next recommended video

**API Integration:**
- `GET /api/v1/content/videos` - Get video library
- `GET /api/v1/content/categories` - Get content categories
- `GET /api/v1/content/featured` - Get featured content

**Database Tables:**
- `lic_schema.content_videos` - Video library
- `lic_schema.content_categories` - Content organization
- `lic_schema.agents` - Agent information (for "Uploaded by" display)

**Tasks:**
1. Restructure `learning_center_screen.dart` to match wireframes exactly
2. Implement video tutorial structure with YouTube integration
3. Implement learning analytics (views, watch time, progress)
4. Remove mock data

**Acceptance Criteria:**
- [ ] Learning tab shows real videos from API
- [ ] Categories match wireframe Section 4.6
- [ ] Featured content displays correctly
- [ ] Video playback works (YouTube or direct)
- [ ] Learning analytics show real data
- [ ] No mock data

---

### Step 2.5: Create Profile Tab Content

**Location:** `lib/features/profile/presentation/pages/profile_tab_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` (Profile sections referenced in navigation)

**API Integration:**
- `GET /api/v1/users/me` - Get user profile
- `PUT /api/v1/users/me` - Update profile
- `POST /api/v1/auth/change-password` - Change password

**Database Tables:**
- `lic_schema.users` - User profile data

**Tasks:**
1. Create comprehensive profile page matching wireframes
2. Implement profile sections: Personal Information, App Settings, Security & Privacy, Help & Support
3. Implement settings persistence to backend
4. Remove mock data

**Acceptance Criteria:**
- [ ] Profile tab shows real user data
- [ ] All settings save to backend
- [ ] Theme switching works
- [ ] Language switching works
- [ ] Security settings functional
- [ ] No mock data

---

## 6. Phase 3: Agent Portal Restructuring & Presentation Carousel (Days 6-9)

### Step 3.1: Agent Dashboard with Presentation Carousel (NEW FEATURE)

**Location:** `lib/features/agent_dashboard/presentation/pages/agent_dashboard_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Section 3.0 - "Agent App Home Dashboard"  
**Feature Specification:** `discovery/design/presentation-carousel-homepage.md`

**Exact Wireframe Requirements:**
- Red header bar: "☰ Hamburger Menu │ 🏠 Home │ 🔔 Notification"
- **Dynamic Presentation Carousel** (Height: 220px):
  - Auto-playing carousel (4-5s per slide)
  - Images, videos, and text overlays
  - Dot indicators showing current slide
  - Swipe navigation enabled
  - Agent branding (logo, contact CTA)
  - CTA buttons for actions
  - ✏️ Edit button (top right)
- Feature Tiles Grid (2 rows × 3 columns): Calendar, Chat, Reminders, Presentations, Daily Quotes, Profile
- My Policies Section: Red horizontal bar with right arrow icon

**API Integration:**
- `GET /api/v1/dashboard/home` - Complete dashboard data (includes carousel)
- `GET /api/v1/presentations/agent/{agent_id}/active` - Active presentation for carousel
- `GET /api/v1/dashboard/presentations/carousel` - Carousel items
- `GET /api/v1/dashboard/feature-tiles` - Feature tiles
- `GET /api/v1/dashboard/analytics/summary` - Dashboard KPIs

**Database Tables:**
- `lic_schema.presentations` - Presentation records
- `lic_schema.slides` - Slide data with media URLs
- `lic_schema.presentation_media` - Media file references
- `lic_schema.agents` - Agent information for branding

**Tasks:**
1. **Create PresentationCarousel Widget** (`lib/features/presentations/presentation/widgets/presentation_carousel.dart`):
   - Auto-play functionality (4-5s per slide)
   - Swipe navigation
   - Dot indicators
   - Support for `image` and `video` slide types
   - Agent branding overlay
   - CTA button handling

2. **Integrate Carousel into Dashboard**:
   - Fetch active presentation from `GET /api/v1/presentations/agent/{agent_id}/active`
   - Display carousel at top of dashboard (220px height)
   - Handle empty state (no active presentation)

3. **Implement Feature Tiles Grid**:
   - 2 rows × 3 columns layout
   - Icons, labels, and badge indicators
   - Navigation to respective screens

4. **Implement My Policies Section**:
   - Red horizontal bar with arrow
   - Link to Policies tab

**Acceptance Criteria:**
- [ ] Carousel matches wireframe Section 3.0 exactly (220px height, auto-play, dots, swipe)
- [ ] Carousel displays slides from real API (`presentations` and `slides` tables)
- [ ] Image and video slides render correctly
- [ ] Agent branding displays on slides
- [ ] Feature tiles grid matches wireframe layout
- [ ] All data comes from real APIs
- [ ] No mock data

---

### Step 3.2: Presentation Editor Module (NEW FEATURE)

**Location:** `lib/features/presentations/editor/pages/presentation_editor_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Section 3.0.2.1 - "Presentation Editor Screen"  
**Feature Specification:** `discovery/design/presentation-carousel-homepage.md` Section 5

**Exact Wireframe Requirements:**
- Red header: "← Back │ ✏️ Edit Presentation │ 💾 Save Draft"
- Slide List (Reorderable): Shows slide title, type, layout, duration with Edit/Delete/Reorder controls
- Add New Slide section: "➕ Add Slide │ 📋 Use Template │ 📤 Import"
- Editor Panel (when slide selected):
  - Title: Rich Text Editor
  - Subtitle: Rich Text Editor
  - Media: Image/Video Picker (Gallery │ Camera │ Video)
  - Layout: Centered/Left/Grid selector
  - Text Color: Color Picker
  - Background: Color Picker
  - Duration: Slider (2-10 seconds)
  - CTA Button: Enable toggle, Text input, Action selector
  - Agent Branding: Enable Logo toggle, Show Contact toggle
- Preview Mode: Preview │ Play │ Pause │ Refresh buttons
- Action Buttons: "💾 Save Draft │ 🚀 Publish │ ❌ Cancel"

**API Integration:**
- `GET /api/v1/presentations/agent/{agent_id}` - Get all presentations
- `POST /api/v1/presentations/agent/{agent_id}` - Create/update presentation
- `PUT /api/v1/presentations/agent/{agent_id}/{presentation_id}` - Update presentation
- `POST /api/v1/presentations/media/upload` - Upload media (image/video)
- `GET /api/v1/presentations/templates` - Get templates

**Database Tables:**
- `lic_schema.presentations` - Presentation records
- `lic_schema.slides` - Slide records with JSONB fields for CTA and branding
- `lic_schema.presentation_media` - Media file storage references
- `lic_schema.presentation_templates` - Template library

**Tasks:**
1. **Create Presentation Editor Screen**:
   - Slide list with reorderable items (drag & drop)
   - Slide editor panel with all wireframe fields
   - Rich text editor for title/subtitle
   - Media picker (Gallery/Camera/Video)
   - Color pickers for text and background
   - Layout selector (Centered/Left/Grid)
   - Duration slider
   - CTA button configuration
   - Agent branding toggles

2. **Implement Media Upload**:
   - Connect to `POST /api/v1/presentations/media/upload`
   - Handle image and video uploads
   - Display thumbnail previews

3. **Implement Preview Mode**:
   - Live carousel preview
   - Auto-play simulation
   - Full-screen preview option

4. **Implement Save/Publish**:
   - Save draft functionality
   - Publish to make active (sets `is_active=true` in `presentations` table)

**Acceptance Criteria:**
- [ ] Editor matches wireframe Section 3.0.2.1 exactly
- [ ] Slide list is reorderable
- [ ] Media upload works with real API
- [ ] Rich text editing functional
- [ ] Preview mode works correctly
- [ ] Save draft and publish work correctly
- [ ] Data persists to `presentations` and `slides` tables
- [ ] No mock data

---

### Step 3.3: Customers Tab Content

**Location:** `lib/features/customers/presentation/pages/customers_tab_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Section 5.2 - "Customer Management Screen"

**Exact Wireframe Requirements:**
- Customer Overview Cards: Total Customers, High Value Customers, At Risk Customers
- Customer List (Advanced CRM View): Customer name, Policy count, Premium/year, Phone, Engagement score, Last Contact, Next Action
- Customer Segmentation: High Value, Medium Value, Low Value filters
- Communication Tools: Bulk Email, WhatsApp Campaign, Analyze Segments

**API Integration:**
- `GET /api/v1/agents/{agent_id}/customers` - List customers
- Customer details via policies relationship

**Database Tables:**
- `lic_schema.policyholders` - Customer records
- `lic_schema.insurance_policies` - Policy associations
- `lic_schema.users` - User profile data
- `lic_schema.customer_segments` - Segmentation data

**Tasks:**
1. Restructure `customers_screen.dart` to match wireframes
2. Implement customer profile structure
3. Implement advanced CRM features: segmentation, bulk messaging
4. Remove mock data

**Acceptance Criteria:**
- [ ] Customers tab shows real customer data
- [ ] Customer profiles match wireframe Section 5.2
- [ ] Segmentation works correctly
- [ ] Bulk messaging functional
- [ ] No mock data

---

### Step 3.4: Analytics Tab Content

**Location:** `lib/features/analytics/presentation/pages/analytics_tab_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Section 5.3 - "ROI Analytics Dashboard"

**Exact Wireframe Requirements:**
- Revenue Analytics: Monthly Revenue, Growth %, Commission Rate
- Performance Metrics: Conversion Rate, Retention Rate, Customer LTV
- ROI Calculations: Marketing ROI, Time ROI, Customer Acquisition Cost
- Predictive Analytics: Next Month Revenue prediction, Upsell opportunities, Churn risk
- Interactive Charts: 6-Month Revenue Trend, Commission Breakdown, Customer LTV Analysis
- Actionable Insights: Recommendations based on analytics

**API Integration:**
- `GET /api/v1/analytics/roi/agent/{agent_id}` - ROI analytics
- `GET /api/v1/analytics/revenue` - Revenue analytics
- `GET /api/v1/analytics/performance` - Performance metrics
- `GET /api/v1/analytics/predictive` - Predictive analytics

**Database Tables:**
- `lic_schema.agent_analytics` - Agent performance metrics
- `lic_schema.roi_analytics` - ROI calculations
- `lic_schema.insurance_policies` - Revenue data
- `lic_schema.campaign_analytics` - Marketing ROI data

**Tasks:**
1. Consolidate `roi_analytics_dashboard.dart` into Analytics tab
2. Implement ROI dashboard structure matching wireframes exactly
3. Implement revenue analytics section
4. Implement performance metrics section
5. Implement ROI calculations section
6. Implement predictive analytics section
7. Remove mock data

**Acceptance Criteria:**
- [ ] Analytics tab shows real ROI data
- [ ] Revenue analytics functional
- [ ] Performance metrics accurate
- [ ] ROI calculations correct
- [ ] Predictive analytics working
- [ ] Charts display real data
- [ ] No mock data

---

### Step 3.5: Campaigns Tab Content

**Location:** `lib/features/campaigns/presentation/pages/campaigns_tab_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Sections 5.4 (Campaign Builder) and 5.7 (Campaign Performance)

**API Integration:**
- `GET /api/v1/campaigns` - List campaigns
- `POST /api/v1/campaigns` - Create campaign
- `GET /api/v1/campaigns/{campaign_id}` - Campaign details
- `GET /api/v1/campaigns/{campaign_id}/performance` - Campaign performance
- `POST /api/v1/campaigns/{campaign_id}/launch` - Launch campaign

**Database Tables:**
- `lic_schema.campaigns` - Campaign records
- `lic_schema.campaign_recipients` - Audience data
- `lic_schema.campaign_analytics` - Performance metrics

**Tasks:**
1. Consolidate campaign screens into Campaigns tab
2. Implement campaign builder interface matching wireframes
3. Connect audience segmentation to real customer data
4. Remove mock data

**Acceptance Criteria:**
- [ ] Campaigns tab shows real campaigns
- [ ] Campaign builder functional
- [ ] Audience segmentation works
- [ ] Campaign performance tracking accurate
- [ ] No mock data

---

### Step 3.6: Agent Profile Tab Content

**Location:** `lib/features/agent/presentation/pages/agent_profile_tab_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` Section 3.0.4 - "Profile Summary Screen"

**Exact Wireframe Requirements:**
- Red header: "← Back Arrow │ 👤 Profile │ 📷 Camera Icon"
- Profile Summary Card (White card, rounded corners):
  - Name, Phone, Email (pre-filled)
  - Gender, Date of Birth, Address, Address Type, Alternate Mobile, Profession, Marriage Date (editable fields)
  - Yellow edit icon (circular, white pencil)
- Action Button: "🔴 UPDATE" (Large red button, white capitalized text)
- Profile Photo Upload: Camera icon in header

**API Integration:**
- `GET /api/v1/agents/{agent_id}` - Agent profile
- `PUT /api/v1/agents/{agent_id}` - Update profile
- `POST /api/v1/agents/{agent_id}/photo` - Upload photo
- `GET /api/v1/content/videos` - Video library
- `POST /api/v1/content/videos` - Upload video

**Database Tables:**
- `lic_schema.agents` - Agent profile data
- `lic_schema.content_videos` - Video library

**Tasks:**
1. Restructure `agent_profile_page.dart` to match wireframes exactly
2. Implement profile editing with form validation
3. Implement photo upload functionality
4. Remove mock data

**Acceptance Criteria:**
- [ ] Agent profile shows real data
- [ ] Profile matches wireframe Section 3.0.4 exactly
- [ ] Photo upload works
- [ ] Update functionality works
- [ ] No mock data

---

## 7. Phase 4: Admin Portal Restructuring (Days 10-12)

### Step 4.1: Create Unified Admin Dashboard

**Location:** `lib/features/admin_dashboard/presentation/pages/admin_dashboard_page.dart`

**Wireframe Reference:** `discovery/content/wireframes.md` (Admin dashboard concepts)

**API Integration:**
- `GET /api/v1/dashboard/system-overview` - System overview (Super Admin)
- `GET /api/v1/dashboard/provider-overview` - Provider overview (Provider Admin)
- `GET /api/v1/dashboard/regional-overview` - Regional overview (Regional Manager)
- `GET /api/v1/rbac/users` - User management
- `GET /api/v1/rbac/roles` - Role management
- `GET /api/v1/feature-flags` - Feature flags
- `GET /api/v1/analytics/platform` - Platform analytics

**Database Tables:**
- `lic_schema.users` - User data
- `lic_schema.agents` - Agent data
- `lic_schema.insurance_policies` - Policy data
- `lic_schema.roles` - RBAC roles
- `lic_schema.feature_flags` - Feature flag configuration

**Tasks:**
1. Remove duplicate admin dashboards
2. Create unified admin dashboard that adapts to admin role
3. Implement role-based content filtering
4. Remove all mock data

**Acceptance Criteria:**
- [ ] Single unified admin dashboard
- [ ] Role-based content filtering works
- [ ] User management functional
- [ ] Feature flag management works
- [ ] Platform analytics show real data
- [ ] No duplicate dashboards
- [ ] No mock data

---

## 8. Phase 5: Onboarding Flow Implementation (Days 13-14)

### Step 5.1: Implement Complete Onboarding Flow

**Location:** `lib/features/onboarding/presentation/pages/`

**Wireframe Reference:** `discovery/content/wireframes.md` Sections 2.1-2.4, 4.7-4.12

**Exact Wireframe Requirements:**
- Splash Screen (Section 2.1): Logo, "Friend of Agents", Loading animation
- Welcome Screen (Section 2.2): "Welcome to LIC Agent App", "14-Day Free Trial", GET STARTED / LOGIN buttons
- Agent Code Login (Section 2.3): Logo, Agent Code input, Password input, Forgot Password link, LOGIN button
- Phone Verification (Section 2.3): Phone number input, "We'll send OTP" message, SEND OTP button
- OTP Verification (Section 2.3): 6-digit code input, Resend OTP timer, VERIFY OTP button
- Trial User Setup (Section 2.4): Basic profile form, START TRIAL button
- Agent Discovery (Section 4.9): Search methods, Agent information form, VERIFY AGENT button
- Document Upload (Section 4.10): Required documents list, Upload process, OCR results
- KYC Verification (Section 4.11): Verification checklist, Status tracking
- Emergency Contact Setup (Section 4.12): Contact details form, Relationship dropdown

**API Integration:**
- `POST /api/v1/auth/phone-verification` - Send OTP
- `POST /api/v1/auth/verify-otp` - Verify OTP
- `POST /api/v1/users/me` - Update profile
- `GET /api/v1/agents/search` - Agent discovery
- `POST /api/v1/users/kyc/documents` - Upload documents (if KYC endpoint exists)
- `POST /api/v1/users/emergency-contact` - Add emergency contact (if endpoint exists)

**Database Tables:**
- `lic_schema.users` - User profile
- `lic_schema.agents` - Agent records (for discovery)
- `lic_schema.policyholders` - Policyholder data

**Tasks:**
1. Implement complete onboarding flow matching wireframes exactly
2. Implement all steps with real API integration
3. Implement data pending state handling
4. Remove mock data

**Acceptance Criteria:**
- [ ] Complete onboarding flow matches wireframes exactly
- [ ] All steps integrate with real APIs
- [ ] Agent discovery works correctly
- [ ] Document upload functional (if API exists)
- [ ] KYC verification works (if API exists)
- [ ] Data pending state handled properly
- [ ] No mock data

---

## 9. Phase 6: React Config Portal Implementation (Days 15-17)

### Step 6.1: Implement Complete Data Import Flow

**Location:** `config-portal/src/pages/`

**Wireframe Reference:** `discovery/content/wireframes.md` Sections 4.13.1-4.13.5

**Exact Wireframe Requirements:**
- Import Dashboard (Section 4.13.1): Import Statistics (Total, Successful, Failed), Recent Activity, Quick Actions
- Excel Upload (Section 4.13.2): Drag & drop, File validation, Column mapping
- Import Progress (Section 4.13.3): Real-time progress bar, Live statistics, Pause/Cancel controls
- Import Errors (Section 4.13.4): Error summary, Error details list, Resolution options
- Import Success (Section 4.13.5): Success summary, Data quality metrics, Mobile sync status

**API Integration:**
- `GET /api/v1/import/templates` - Get import templates
- `POST /api/v1/import/upload` - Upload Excel file
- `POST /api/v1/import/validate/{file_id}` - Validate file
- `POST /api/v1/import/data` - Import validated data
- `GET /api/v1/import/status/{import_id}` - Get import status
- `GET /api/v1/import/history` - Get import history
- `GET /api/v1/import/templates/{entity_type}/download` - Download template

**Database Tables:**
- `lic_schema.data_imports` - Import job records
- `lic_schema.data_import_errors` - Import error logs
- Target tables: `lic_schema.policyholders`, `lic_schema.insurance_policies`, etc.

**Tasks:**
1. Implement complete import workflow matching wireframes exactly
2. Create/update screens: Dashboard, Upload, Progress, Errors, Success
3. Implement Excel template download
4. Implement column mapping
5. Implement real-time progress updates
6. Remove mock data

**Acceptance Criteria:**
- [ ] Complete import flow matches wireframes exactly
- [ ] File upload works with real backend
- [ ] Progress tracking shows real-time updates
- [ ] Error handling functional
- [ ] Template download works
- [ ] Column mapping functional
- [ ] Data imports to real database tables
- [ ] No mock data

---

## 10. Phase 7: Wireframe Conformance Verification (Days 18-19)

### Step 7.1: Visual Audit Against Wireframes

**Tasks:**
1. Systematically compare every implemented screen against `discovery/content/wireframes.md`
2. Verify exact match for:
   - Typography (Font sizes, weights per wireframe)
   - Colors (Primary Red #C62828, Secondary Blue/Green, White backgrounds)
   - Spacing and Grid alignment
   - Component layouts (exact positioning)
   - Icons and imagery
   - Component states (Loading, Empty, Error)

**Checklist per Screen:**
- [ ] Header bar matches wireframe (red background, white text)
- [ ] Component spacing matches wireframe exactly
- [ ] Colors match wireframe color scheme
- [ ] Typography matches wireframe font specifications
- [ ] Icons match wireframe icon descriptions
- [ ] Button styles match wireframe (red buttons, white text)
- [ ] Empty states match wireframe empty state designs

**Reference:** `discovery/content/wireframes.md` (entire document)

**Acceptance Criteria:**
- [ ] 100% visual conformance with wireframes
- [ ] All deviations documented and justified
- [ ] Color scheme matches exactly
- [ ] Typography matches exactly
- [ ] Layout matches exactly

---

## 11. Phase 8: API & Database Integration Verification (Days 20-21)

### Step 8.1: Remove All Mock Data

**Tasks:**
1. Search codebase for mock data patterns:
   ```bash
   grep -r "mockData\|MockData\|MOCK_DATA" lib/
   grep -r "fakeData\|FakeData\|FAKE_DATA" lib/
   grep -r "sampleData\|SampleData\|SAMPLE_DATA" lib/
   grep -r "placeholder.*data\|Placeholder.*Data" lib/
   grep -r "TODO.*mock\|TODO.*fake" lib/
   ```
2. Replace all mock data with real API calls
3. Update ViewModels to use real repositories
4. Update DataSources to call real endpoints
5. Remove any hardcoded test data

**Acceptance Criteria:**
- [ ] No mock data found in codebase
- [ ] All ViewModels use real APIs
- [ ] All DataSources call real endpoints
- [ ] No hardcoded test data

---

### Step 8.2: Verify API Integration

**Tasks:**
1. Create API integration test checklist for all 265 endpoints
2. Test each screen's API calls
3. Verify error handling
4. Verify loading states
5. Verify data refresh
6. Document any missing APIs

**API Endpoint Verification Checklist:**
- [ ] Authentication endpoints work
- [ ] User endpoints work
- [ ] Agent endpoints work
- [ ] Policy endpoints work
- [ ] Dashboard endpoints work
- [ ] Presentation endpoints work (NEW)
- [ ] Chat endpoints work
- [ ] Analytics endpoints work
- [ ] Campaign endpoints work
- [ ] Content endpoints work
- [ ] Import endpoints work
- [ ] RBAC endpoints work
- [ ] Feature flag endpoints work

**Acceptance Criteria:**
- [ ] All API calls work correctly
- [ ] Error handling implemented
- [ ] Loading states show properly
- [ ] Data refresh works
- [ ] Missing APIs documented

---

### Step 8.3: Verify Database Integration

**Tasks:**
1. Verify all data persistence flows correctly to 74 tables in `lic_schema`
2. Verify Presentation feature correctly populates `presentations` and `slides` tables
3. Verify import feature correctly populates target tables
4. Check for any N+1 query problems
5. Verify transaction handling

**Database Table Verification Checklist:**
- [ ] User data persists to `users` table
- [ ] Agent data persists to `agents` table
- [ ] Policy data persists to `insurance_policies` table
- [ ] Presentation data persists to `presentations` and `slides` tables
- [ ] Media uploads create records in `presentation_media` table
- [ ] Import data persists to target tables
- [ ] Analytics data reads from correct tables

**Acceptance Criteria:**
- [ ] All data persists to correct tables
- [ ] No N+1 query problems
- [ ] Transaction handling correct
- [ ] Database schema supports all features

---

## 12. Phase 9: Testing & Final Validation (Days 22-24)

### Step 9.1: End-to-End User Flow Testing

**Test Scenarios:**
- Customer: Onboarding → Dashboard → Policies → Chat → Learning → Profile
- Agent: Login → Dashboard (with carousel) → Customers → Analytics → Campaigns → Profile → Create Presentation
- Admin: Login → Overview → Management → Configuration → Analytics
- Config Portal: Login → Dashboard → Upload → Progress → Results

**Acceptance Criteria:**
- [ ] All user flows work end-to-end
- [ ] Navigation works correctly
- [ ] Data displays correctly
- [ ] No broken links or routes

---

### Step 9.2: Wireframe Conformance Testing

**Checklist:**
- [ ] All screens match wireframes 100%
- [ ] Component layouts correct
- [ ] Feature flags integrated
- [ ] Responsive design works
- [ ] Accessibility features functional

**Acceptance Criteria:**
- [ ] 100% conformance with wireframes.md
- [ ] All deviations documented and justified

---

### Step 9.3: API Integration Testing

**Acceptance Criteria:**
- [ ] All 265 API endpoints work correctly
- [ ] Error handling proper
- [ ] Loading states functional
- [ ] Data refresh works
- [ ] No API errors in production

---

### Step 9.4: Performance Testing

**Acceptance Criteria:**
- [ ] App performs well with real data
- [ ] Loading times acceptable
- [ ] Navigation smooth
- [ ] Memory usage reasonable
- [ ] Offline handling works

---

## 13. Implementation Guidelines

### 13.0 Environment Configuration

#### .env File Structure

**Flutter App (.env):**
```env
API_BASE_URL=https://your-backend-domain.com
API_KEY=your-api-key
ENABLE_LOGGING=true
APP_ENVIRONMENT=production
```

**Backend (backend/.env):**
```env
ENVIRONMENT=production
DATABASE_URL=postgresql://agentmitra:agentmitra_dev@localhost:5432/agentmitra_dev
REDIS_URL=redis://localhost:6379
JWT_SECRET_KEY=your-production-jwt-secret
PIONEER_URL=http://localhost:4001
OPENAI_API_KEY=your-openai-key
MINIO_ENDPOINT=minio:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
```

**React Config Portal (config-portal/.env):**
```env
REACT_APP_API_URL=http://localhost:8012
REACT_APP_ENVIRONMENT=production
REACT_APP_PIONEER_URL=http://localhost:4001
```

**Environment Loading Pattern:**
```dart
// Flutter
class Config {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
}

// Backend (Python)
import os
api_url = os.getenv('API_BASE_URL', 'http://localhost:8012')
database_url = os.getenv('DATABASE_URL')

// React
const apiUrl = process.env.REACT_APP_API_URL;
```

---

### 13.1 Code Quality Standards

1. **No Mock Data**
   - All screens must use real API endpoints
   - Remove all `mockData`, `fakeData`, `sampleData` patterns
   - Use real ViewModels and Repositories

2. **Real API Integration**
   - All API calls must go through proper service layers
   - Use existing API client implementations
   - Handle errors properly
   - Show loading states

3. **Database Changes**
   - Use Flyway migrations only
   - No manual database changes
   - Test migrations on clean database
   - Document schema changes

4. **Wireframe Conformance**
   - Match wireframes exactly (layout, colors, spacing, typography)
   - Use exact color codes from wireframes (#C62828 for red)
   - Follow exact component positioning
   - Match icon styles and sizes

5. **Navigation Structure**
   - Use navigation containers, not individual screens
   - Implement proper tab-based navigation
   - Use drawer/hamburger menus for secondary navigation
   - Follow navigation hierarchy exactly

### 13.2 File Organization

#### Flutter App Structure
```
lib/
├── navigation/              # Navigation containers
│   ├── customer_navigation.dart
│   ├── agent_navigation.dart
│   ├── admin_navigation.dart
│   └── navigation_router.dart
├── features/
│   ├── customer_dashboard/  # Customer portal
│   ├── policies/           # Policies management
│   ├── chat/               # Chat and communication
│   ├── learning/           # Learning center
│   ├── profile/            # User profile
│   ├── agent_dashboard/    # Agent portal
│   ├── presentations/      # Presentation carousel (NEW)
│   │   ├── presentation/   # Carousel widget
│   │   └── editor/        # Editor module
│   ├── customers/         # Customer management
│   ├── analytics/         # Analytics and ROI
│   ├── campaigns/         # Marketing campaigns
│   ├── admin_dashboard/   # Admin portal
│   └── onboarding/        # Onboarding flow
└── screens/                # Individual screens (CONSOLIDATE)
```

### 13.3 API Integration Patterns

#### Flutter API Call Pattern
```dart
// ViewModel
class CustomerDashboardViewModel extends StateNotifier<CustomerDashboardState> {
  final CustomerDashboardRepository _repository;
  
  Future<void> loadDashboard() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repository.getDashboardData();
      state = state.copyWith(
        isLoading: false,
        dashboardData: data,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

// Repository
class CustomerDashboardRepository {
  final ApiClient _apiClient;
  
  Future<CustomerDashboardData> getDashboardData() async {
    final response = await _apiClient.get('/api/v1/dashboard/analytics');
    return CustomerDashboardData.fromJson(response.data);
  }
}
```

---

## Success Criteria

### Functional Requirements
- [ ] **100% Wireframe Conformance** - All UI matches wireframes.md exactly
- [ ] **100% Navigation Conformance** - All navigation matches navigation-hierarchy.md
- [ ] **100% Content Conformance** - All content matches content-structure.md
- [ ] **100% IA Conformance** - All screens match information-architecture.md
- [ ] **100% User Journey Conformance** - All flows match user-journey.md
- [ ] **Zero Mock Data** - No mock/fake/sample data in codebase
- [ ] **Real API Integration** - All screens use real backend APIs (265 endpoints)
- [ ] **Database Integration** - All data persists to 74 tables in lic_schema
- [ ] **Presentation Carousel** - Full implementation of new feature
- [ ] **Proper Navigation** - Tab-based navigation with drawer menus
- [ ] **Unified Dashboards** - Single dashboard per user type
- [ ] **Complete Import Flow** - Full Excel import workflow in config portal

### Technical Requirements
- [ ] **Clean Codebase** - No duplicate screens, proper organization
- [ ] **API Integration** - All API calls work correctly
- [ ] **Error Handling** - Proper error handling throughout
- [ ] **Loading States** - Loading indicators where needed
- [ ] **Database Migrations** - All DB changes via Flyway
- [ ] **Environment Configuration** - All config externalized via .env files
- [ ] **Deployment Scripts** - Production deployment via `scripts/deploy/start-prod.sh`
- [ ] **Infrastructure Setup** - PostgreSQL/Redis local, Pioneer via Docker
- [ ] **Performance** - App performs well with real data
- [ ] **Accessibility** - Accessibility features work
- [ ] **Responsive Design** - Works on all screen sizes

---

## Timeline Summary

| Phase | Duration | Key Deliverables |
|-------|----------|------------------|
| Phase 1: Navigation Architecture | 2 days | Navigation containers, routing |
| Phase 2: Customer Portal | 3 days | Customer dashboard, tabs, content |
| Phase 3: Agent Portal & Carousel | 4 days | Agent dashboard, carousel, editor, tabs |
| Phase 4: Admin Portal | 3 days | Admin dashboard, management features |
| Phase 5: Onboarding Flow | 2 days | Complete onboarding implementation |
| Phase 6: Config Portal | 3 days | Data import flow, dashboard |
| Phase 7: Wireframe Conformance | 2 days | Visual audit and verification |
| Phase 8: API & DB Integration | 2 days | Mock data removal, API verification |
| Phase 9: Testing & Validation | 3 days | End-to-end testing, conformance verification |
| **Total** | **24 days** | **Complete app restructuring** |

---

## Deployment & Infrastructure

### Production Deployment

**Use the following scripts for production deployment:**

1. **Complete Production Startup**: `scripts/deploy/start-prod.sh`
   - Checks Docker daemon
   - Validates .env files
   - Generates SSL certificates
   - Builds Flutter web app
   - Starts all Docker services

2. **Docker Compose Configuration**: `docker-compose.prod.yml`
   - Backend API (port 8012)
   - React Config Portal (port 3013)
   - Nginx reverse proxy (port 80/443)
   - Monitoring stack (Prometheus, Grafana)
   - MinIO object storage (port 9000/9001)
   - Pioneer feature flag services (ports 4000-4002)

**Infrastructure Requirements:**
- ✅ PostgreSQL 16 via `brew services start postgresql@16`
- ✅ Redis via `brew services start redis`
- ✅ Pioneer services via Docker Compose
- ✅ .env files configured for all components

---

## Notes for Cursor AI Coding Agent

When implementing this plan:

1. **Read discovery documents first** - Understand the target state, especially wireframes.md
2. **Check existing code** - See what's already implemented
3. **Use real APIs** - Never create mock data, use the 265 existing endpoints
4. **Match wireframes exactly** - Colors, spacing, typography, layout must match 100%
5. **Follow patterns** - Use existing code patterns
6. **Configure environment** - Use .env files for all configuration (Flutter, Backend, React)
7. **Test incrementally** - Test each step before moving on
8. **Document changes** - Comment on why changes were made
9. **Verify database** - Ensure data persists to correct tables in lic_schema
10. **Use deployment scripts** - Production deployment via `scripts/deploy/start-prod.sh`
11. **Infrastructure setup** - PostgreSQL/Redis local via brew, Pioneer via Docker Compose

**Remember:** The goal is 100% conformance with discovery documents, especially wireframes.md. Every screen, every navigation pattern, every content structure must match the specifications exactly. All data must come from real APIs and persist to real database tables.

---

**End of Project Plan**
