#!/bin/bash
# Script to create FeatureHub feature flags using Java Admin Service

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
JAVA_SERVICE_DIR="$PROJECT_ROOT/featurehub-admin-service"
JAR_FILE="$JAVA_SERVICE_DIR/target/featurehub-admin-service-1.0.0.jar"

# Load environment variables from backend/.env.local
if [ -f "$PROJECT_ROOT/backend/.env.local" ]; then
    export $(grep FEATUREHUB $PROJECT_ROOT/backend/.env.local | xargs)
fi

# Check if JAR exists, build if not
if [ ! -f "$JAR_FILE" ]; then
    echo "Building FeatureHub Admin Service..."
    cd "$JAVA_SERVICE_DIR"
    mvn clean package -DskipTests
    cd "$PROJECT_ROOT"
fi

# Extract application ID from SDK key (first part before /)
# Note: Environment ID is not a UUID - it's in the SDK key format
# For now, we'll use the application ID and skip environment-specific operations
if [ -z "$FEATUREHUB_SDK_KEY" ]; then
    echo "❌ Error: FEATUREHUB_SDK_KEY not set"
    exit 1
fi

SDK_PARTS=($(echo $FEATUREHUB_SDK_KEY | tr '/' ' '))
if [ ${#SDK_PARTS[@]} -ge 1 ]; then
    APPLICATION_ID=${SDK_PARTS[0]}
    # Environment ID from SDK key is not a UUID format
    # Use FEATUREHUB_ENVIRONMENT_ID if set, otherwise skip environment operations
    if [ -z "$ENVIRONMENT_ID" ]; then
        ENVIRONMENT_ID=""
        echo "⚠️  Warning: Environment ID not set - features will be created without environment values"
    fi
else
    echo "❌ Error: Invalid SDK key format"
    exit 1
fi

# Check required variables
# Use SaaS Admin SDK URL if FEATUREHUB_ADMIN_SDK_URL not set
if [ -z "$FEATUREHUB_ADMIN_SDK_URL" ]; then
    FEATUREHUB_ADMIN_SDK_URL="https://app.featurehub.io/vanilla/913a7a7d-3523-4f7b-85ca-9564ad10e858"
    echo "⚠️  Using default Admin SDK URL: $FEATUREHUB_ADMIN_SDK_URL"
fi

if [ -z "$FEATUREHUB_ADMIN_TOKEN" ]; then
    echo "❌ Error: FEATUREHUB_ADMIN_TOKEN not set"
    exit 1
fi

echo "=================================================================================="
echo "                    FEATUREHUB FLAG CREATION (Java Service)"
echo "=================================================================================="
echo ""
echo "Configuration:"
echo "  Admin SDK URL: $FEATUREHUB_ADMIN_SDK_URL"
echo "  Application ID: $APPLICATION_ID"
echo "  Environment ID: $ENVIRONMENT_ID"
echo ""

# Run Java service
if [ -n "$ENVIRONMENT_ID" ]; then
    java -jar "$JAR_FILE" \
        --base-url "$FEATUREHUB_ADMIN_SDK_URL" \
        --token "$FEATUREHUB_ADMIN_TOKEN" \
        --application-id "$APPLICATION_ID" \
        --environment-id "$ENVIRONMENT_ID" \
        create-all
else
    java -jar "$JAR_FILE" \
        --base-url "$FEATUREHUB_ADMIN_SDK_URL" \
        --token "$FEATUREHUB_ADMIN_TOKEN" \
        --application-id "$APPLICATION_ID" \
        create-all
fi

EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "✅ Feature flags created successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Verify flags in FeatureHub dashboard: https://app.featurehub.io/dashboard"
    echo "2. Restart backend to load flags from FeatureHub"
    echo "3. Test with: curl http://localhost:8012/api/v1/feature-flags"
else
    echo ""
    echo "❌ Feature flag creation failed"
    exit $EXIT_CODE
fi

