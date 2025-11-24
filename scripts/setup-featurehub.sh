#!/bin/bash

# Setup FeatureHub for Agent Mitra
# This script sets up FeatureHub Edge server and Admin UI

set -e

echo "🚀 Setting up FeatureHub..."

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null && ! command -v docker &> /dev/null; then
    echo "❌ Docker/Docker Compose not found. Please install Docker first."
    exit 1
fi

# Start FeatureHub services
echo "📦 Starting FeatureHub services..."
docker-compose -f docker-compose.dev.yml up -d featurehub-db featurehub-admin featurehub

# Wait for services to be healthy
echo "⏳ Waiting for FeatureHub services to be ready..."
sleep 10

# Check FeatureHub Edge health
echo "🔍 Checking FeatureHub Edge server..."
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ FeatureHub Edge server is running at http://localhost:8080"
else
    echo "⚠️  FeatureHub Edge server may not be ready yet. Check logs: docker-compose -f docker-compose.dev.yml logs featurehub"
fi

# Check FeatureHub Admin health
echo "🔍 Checking FeatureHub Admin UI..."
if curl -f http://localhost:8085/health > /dev/null 2>&1; then
    echo "✅ FeatureHub Admin UI is running at http://localhost:8085"
    echo ""
    echo "📝 Next steps:"
    echo "1. Open http://localhost:8085 in your browser"
    echo "2. Create an account (first user becomes admin)"
    echo "3. Create an application and environment"
    echo "4. Generate API key and SDK key"
    echo "5. Add keys to backend/.env.local:"
    echo "   FEATUREHUB_API_KEY=your-api-key"
    echo "   FEATUREHUB_SDK_KEY=your-sdk-key"
    echo "6. Create feature flags in the Admin UI"
else
    echo "⚠️  FeatureHub Admin UI may not be ready yet. Check logs: docker-compose -f docker-compose.dev.yml logs featurehub-admin"
fi

echo ""
echo "📚 Documentation: backend/docs/FEATUREHUB_INTEGRATION.md"

