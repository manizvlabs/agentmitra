#!/bin/bash
# Script to create feature flags in Pioneer
# Run this after starting Pioneer service

set -e

PIONEER_URL="http://localhost:4001"

echo "Creating feature flags in Pioneer..."

# Function to create a feature flag
create_flag() {
    local title="$1"
    local description="$2"
    local is_active="${3:-false}"

    echo "Creating flag: $title"

    curl -X POST "$PIONEER_URL/flags" \
        -H "Content-Type: application/json" \
        -d "{
            \"flag\": {
                \"title\": \"$title\",
                \"description\": \"$description\",
                \"is_active\": $is_active,
                \"rollout\": 100
            }
        }" || echo "Failed to create $title"
}

# Create presentation-related flags
create_flag "presentation_carousel_enabled" "Enable presentation carousel on home screen" true
create_flag "presentation_editor_enabled" "Enable in-app presentation editor" true
create_flag "presentation_templates_enabled" "Enable presentation templates" true
create_flag "presentation_offline_mode_enabled" "Enable offline presentation editing" true
create_flag "presentation_analytics_enabled" "Enable presentation analytics tracking" true
create_flag "presentation_branding_enabled" "Enable agent branding in presentations" true

# Create dashboard flags
create_flag "agent_dashboard_enabled" "Enable agent dashboard" true
create_flag "customer_dashboard_enabled" "Enable customer dashboard" false

# Create communication flags
create_flag "whatsapp_integration_enabled" "Enable WhatsApp integration" true
create_flag "chatbot_enabled" "Enable chatbot assistance" true

# Create payment flags (start disabled for compliance)
create_flag "premium_payments_enabled" "Enable premium payment processing" false

# Create policy management flags
create_flag "policy_management_enabled" "Enable policy management features" true

# Create analytics flags
create_flag "analytics_enabled" "Enable analytics dashboard" true
create_flag "roi_analytics_enabled" "Enable ROI analytics" true

echo ""
echo "Feature flags creation completed!"
echo "You can now start the Flutter app - it will connect to Pioneer instead of using mocks."
echo ""
echo "To verify flags were created:"
echo "curl http://localhost:4001/api/flags"
