#!/bin/bash

# Agent Mitra Backend Cloud Run Deployment Script
# This script deploys only the backend to Google Cloud Run while keeping everything else local

set -e

echo "🚀 Agent Mitra Backend - Cloud Run Deployment"
echo "============================================="
echo ""

# Configuration
PROJECT_ID="vaulted-scholar-480715-u4"
REGION="europe-north1"
REPO_NAME="agentmitra"
IMAGE_NAME="backend"
SERVICE_NAME="agentmitra-backend"
CLOUD_SQL_INSTANCE="vaulted-scholar-480715-u4:europe-north1:agentmitra-postgres"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Step 1: Authenticate with Google Cloud${NC}"
echo "Run this command and complete browser authentication:"
echo -e "${YELLOW}gcloud auth login${NC}"
echo ""
read -p "Press Enter after completing authentication..."

echo -e "\n${BLUE}Step 2: Set project and enable services${NC}"
gcloud config set project $PROJECT_ID
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com sqladmin.googleapis.com

echo -e "\n${BLUE}Step 3: Create Artifact Registry repository${NC}"
gcloud artifacts repositories create $REPO_NAME \
  --repository-format=docker \
  --location=$REGION \
  --description="Agent Mitra Docker Repository"

echo -e "\n${BLUE}Step 4: Configure Docker authentication${NC}"
gcloud auth configure-docker $REGION-docker.pkg.dev

echo -e "\n${BLUE}Step 5: Build and push backend image${NC}"
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:latest ./backend
docker push $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:latest

echo -e "\n${BLUE}Step 6: Create environment variables file${NC}"
cat > cloudrun-env-vars.yaml << EOF
ENVIRONMENT: production
DB_HOST: /cloudsql/vaulted-scholar-480715-u4:europe-north1:agentmitra-postgres
DB_PORT: "5432"
DB_NAME: agentmitra_dev
DB_USER: manish
DB_PASSWORD: uuq>9M"hp}t.ZQ@A
REDIS_URL: redis://host.docker.internal:6379
JWT_SECRET_KEY: dev-secret-key-change-in-production
CORS_ORIGINS: http://localhost:8080,http://localhost:3000,http://localhost:8012,http://localhost:3013,https://agentmitra-backend-*.a.run.app
USE_SSL: "false"
PIONEER_URL: http://host.docker.internal:4001
MINIO_ENDPOINT: host.docker.internal:9000
MINIO_ACCESS_KEY: minioadmin
MINIO_SECRET_KEY: minioadmin
MINIO_BUCKET_NAME: agentmitra-media
MINIO_USE_SSL: "false"
EOF

echo -e "\n${BLUE}Step 7: Deploy to Cloud Run${NC}"
gcloud run deploy $SERVICE_NAME \
  --image $REGION-docker.pkg.dev/$PROJECT_ID/$REPO_NAME/$IMAGE_NAME:latest \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 1 \
  --port 8080 \
  --add-cloudsql-instances $CLOUD_SQL_INSTANCE \
  --env-vars-file cloudrun-env-vars.yaml

echo -e "\n${GREEN}🎉 DEPLOYMENT SUCCESSFUL!${NC}"
echo ""
echo -e "${GREEN}Cloud Run URL:${NC}"
gcloud run services describe $SERVICE_NAME --region=$REGION --format="value(status.url)"

echo ""
echo -e "${YELLOW}📋 Next Steps:${NC}"
echo "1. Copy the Cloud Run URL above"
echo "2. Update docker-compose.prod.yml to remove backend service"
echo "3. Update portal REACT_APP_API_URL to use Cloud Run URL"
echo "4. Update nginx.conf to proxy /api/ to Cloud Run URL"
echo "5. Test the complete setup with: docker-compose -f docker-compose.prod.yml up -d"
echo ""
echo -e "${BLUE}💰 Estimated Monthly Cost: $0-5${NC}"
echo -e "${BLUE}   - Cloud Run: Pay-per-use (scales to zero)${NC}"
echo -e "${BLUE}   - Cloud SQL: Already running (${PROJECT_ID})${NC}"
echo -e "${BLUE}   - Artifact Registry: ~$0.10${NC}"
