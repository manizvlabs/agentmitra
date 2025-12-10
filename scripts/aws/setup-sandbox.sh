#!/bin/bash
# AWS Sandbox Setup Script for Agent Mitra
# This script sets up the complete AWS infrastructure for the sandbox environment
#
# SECURITY NOTE: This script uses AWS profiles for authentication.
# Set AWS_PROFILE environment variable or use the default 'agentmitra-dev' profile.
# DO NOT use root access keys - configure IAM user or SSO instead.
# See AWS_SECURITY_SETUP.md for details.

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="sandbox"
PROJECT_NAME="agentmitra-sandbox"
REGION="us-east-1"
VPC_CIDR="10.0.0.0/16"
SUBNET_CIDR="10.0.1.0/24"
AWS_PROFILE="${AWS_PROFILE:-agentmitra-dev}"  # Use profile from env or default

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Agent Mitra AWS Sandbox Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    echo "https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi

if ! aws sts get-caller-identity --profile $AWS_PROFILE &> /dev/null; then
    echo -e "${RED}AWS CLI is not configured or profile '$AWS_PROFILE' is invalid.${NC}"
    echo -e "${YELLOW}Please run one of the following:${NC}"
    echo "  aws configure sso"
    echo "  aws configure --profile $AWS_PROFILE"
    echo "  aws login (if using AWS CLI v2)"
    exit 1
fi

# Security check: Ensure not using root access keys
CALLER_IDENTITY=$(aws sts get-caller-identity --profile $AWS_PROFILE --output json)
USER_ID=$(echo $CALLER_IDENTITY | jq -r '.UserId')
if [[ "$USER_ID" == "root" ]]; then
    echo -e "${RED}ERROR: You are using root access keys, which is not recommended!${NC}"
    echo -e "${YELLOW}Please configure AWS CLI with IAM user credentials or SSO.${NC}"
    echo -e "${YELLOW}See AWS_SECURITY_SETUP.md for instructions.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Prerequisites and security check passed${NC}"
echo ""

# Get AWS account information
ACCOUNT_ID=$(aws sts get-caller-identity --profile $AWS_PROFILE --query Account --output text)
echo -e "${BLUE}AWS Account ID: ${ACCOUNT_ID}${NC}"
echo ""

# Create VPC and networking
echo -e "${BLUE}Setting up VPC and networking...${NC}"

# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --profile $AWS_PROFILE \
    --query 'Vpc.VpcId' --output text)
echo -e "${GREEN}✓ Created VPC: ${VPC_ID}${NC}"

# Create subnet
SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID --cidr-block $SUBNET_CIDR \
    --region $REGION --profile $AWS_PROFILE --query 'Subnet.SubnetId' --output text)
echo -e "${GREEN}✓ Created subnet: ${SUBNET_ID}${NC}"

# Create internet gateway
IGW_ID=$(aws ec2 create-internet-gateway --region $REGION --profile $AWS_PROFILE \
    --query 'InternetGateway.InternetGatewayId' --output text)
echo -e "${GREEN}✓ Created internet gateway: ${IGW_ID}${NC}"

# Attach internet gateway to VPC
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $IGW_ID \
    --region $REGION --profile $AWS_PROFILE
echo -e "${GREEN}✓ Attached internet gateway to VPC${NC}"

# Create route table
RTB_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --region $REGION --profile $AWS_PROFILE \
    --query 'RouteTable.RouteTableId' --output text)
echo -e "${GREEN}✓ Created route table: ${RTB_ID}${NC}"

# Create route to internet
aws ec2 create-route --route-table-id $RTB_ID --destination-cidr-block 0.0.0.0/0 \
    --gateway-id $IGW_ID --region $REGION --profile $AWS_PROFILE
echo -e "${GREEN}✓ Created route to internet${NC}"

# Associate route table with subnet
aws ec2 associate-route-table --subnet-id $SUBNET_ID --route-table-id $RTB_ID \
    --region $REGION --profile $AWS_PROFILE
echo -e "${GREEN}✓ Associated route table with subnet${NC}"

# Create security group
SG_ID=$(aws ec2 create-security-group --group-name "${PROJECT_NAME}-sg" \
    --description "Security group for Agent Mitra sandbox" --vpc-id $VPC_ID --region $REGION \
    --profile $AWS_PROFILE --query 'GroupId' --output text)
echo -e "${GREEN}✓ Created security group: ${SG_ID}${NC}"

# Add security group rules
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp \
    --port 22 --cidr 0.0.0.0/0 --region $REGION --profile $AWS_PROFILE  # SSH
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp \
    --port 80 --cidr 0.0.0.0/0 --region $REGION --profile $AWS_PROFILE  # HTTP
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp \
    --port 443 --cidr 0.0.0.0/0 --region $REGION --profile $AWS_PROFILE  # HTTPS
aws ec2 authorize-security-group-ingress --group-id $SG_ID --protocol tcp \
    --port 8012 --cidr 0.0.0.0/0 --region $REGION --profile $AWS_PROFILE  # Backend API
echo -e "${GREEN}✓ Added security group rules${NC}"

echo -e "${GREEN}✓ VPC and networking setup complete${NC}"
echo ""

# Create RDS PostgreSQL database (Free Tier)
echo -e "${BLUE}Setting up RDS PostgreSQL database...${NC}"

DB_PASSWORD=$(openssl rand -base64 12)
DB_INSTANCE_ID="${PROJECT_NAME}-db"

aws rds create-db-instance \
    --db-instance-identifier $DB_INSTANCE_ID \
    --db-instance-class db.t4g.micro \
    --engine postgres \
    --master-username admin \
    --master-user-password $DB_PASSWORD \
    --allocated-storage 20 \
    --vpc-security-group-ids $SG_ID \
    --db-subnet-group-name default \
    --backup-retention-period 7 \
    --region $REGION \
    --profile $AWS_PROFILE

echo -e "${GREEN}✓ Created RDS instance: ${DB_INSTANCE_ID}${NC}"

# Wait for DB to be available
echo "Waiting for database to be available..."
aws rds wait db-instance-available --db-instance-identifier $DB_INSTANCE_ID \
    --region $REGION --profile $AWS_PROFILE
echo -e "${GREEN}✓ Database is available${NC}"

# Get DB endpoint
DB_ENDPOINT=$(aws rds describe-db-instances --db-instance-identifier $DB_INSTANCE_ID \
    --region $REGION --profile $AWS_PROFILE --query 'DBInstances[0].Endpoint.Address' --output text)
echo -e "${GREEN}✓ Database endpoint: ${DB_ENDPOINT}${NC}"

echo -e "${GREEN}✓ Database setup complete${NC}"
echo ""

# Create ElastiCache Redis cluster (Free Tier)
echo -e "${BLUE}Setting up ElastiCache Redis cluster...${NC}"

CACHE_CLUSTER_ID="${PROJECT_NAME}-cache"

aws elasticache create-cache-cluster \
    --cache-cluster-id $CACHE_CLUSTER_ID \
    --cache-node-type cache.t4g.micro \
    --engine redis \
    --num-cache-nodes 1 \
    --vpc-security-group-ids $SG_ID \
    --cache-subnet-group-name default \
    --region $REGION \
    --profile $AWS_PROFILE

echo -e "${GREEN}✓ Created ElastiCache cluster: ${CACHE_CLUSTER_ID}${NC}"

# Wait for cache cluster to be available
echo "Waiting for cache cluster to be available..."
aws elasticache wait cache-cluster-available --cache-cluster-id $CACHE_CLUSTER_ID \
    --region $REGION --profile $AWS_PROFILE
echo -e "${GREEN}✓ Cache cluster is available${NC}"

# Get cache endpoint
CACHE_ENDPOINT=$(aws elasticache describe-cache-clusters --cache-cluster-id $CACHE_CLUSTER_ID \
    --region $REGION --profile $AWS_PROFILE --query 'CacheClusters[0].CacheNodes[0].Endpoint.Address' --output text)
echo -e "${GREEN}✓ Cache endpoint: ${CACHE_ENDPOINT}${NC}"

echo -e "${GREEN}✓ Cache setup complete${NC}"
echo ""

# Create S3 bucket
echo -e "${BLUE}Setting up S3 bucket...${NC}"

BUCKET_NAME="${PROJECT_NAME}-media"

aws s3 mb s3://$BUCKET_NAME --region $REGION --profile $AWS_PROFILE
echo -e "${GREEN}✓ Created S3 bucket: ${BUCKET_NAME}${NC}"

# Configure bucket for public read access (for media files)
aws s3api put-bucket-policy --bucket $BUCKET_NAME --profile $AWS_PROFILE --policy "{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
        {
            \"Sid\": \"PublicReadGetObject\",
            \"Effect\": \"Allow\",
            \"Principal\": \"*\",
            \"Action\": \"s3:GetObject\",
            \"Resource\": \"arn:aws:s3:::$BUCKET_NAME/*\"
        }
    ]
}"
echo -e "${GREEN}✓ Configured bucket policy${NC}"

echo -e "${GREEN}✓ S3 setup complete${NC}"
echo ""

# Create IAM user for application
echo -e "${BLUE}Creating IAM user for application...${NC}"

IAM_USER_NAME="${PROJECT_NAME}-app-user"

# Create IAM user
aws iam create-user --user-name $IAM_USER_NAME --profile $AWS_PROFILE
echo -e "${GREEN}✓ Created IAM user: ${IAM_USER_NAME}${NC}"

# Create access key
ACCESS_KEY=$(aws iam create-access-key --user-name $IAM_USER_NAME --profile $AWS_PROFILE)
ACCESS_KEY_ID=$(echo $ACCESS_KEY | jq -r '.AccessKey.AccessKeyId')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEY | jq -r '.AccessKey.SecretAccessKey')

echo -e "${GREEN}✓ Created access key${NC}"

# Create IAM policy for S3 and RDS access
POLICY_DOCUMENT="{
    \"Version\": \"2012-10-17\",
    \"Statement\": [
        {
            \"Effect\": \"Allow\",
            \"Action\": [
                \"s3:GetObject\",
                \"s3:PutObject\",
                \"s3:DeleteObject\",
                \"s3:ListBucket\"
            ],
            \"Resource\": [
                \"arn:aws:s3:::$BUCKET_NAME\",
                \"arn:aws:s3:::$BUCKET_NAME/*\"
            ]
        },
        {
            \"Effect\": \"Allow\",
            \"Action\": [
                \"rds:DescribeDBInstances\",
                \"elasticache:DescribeCacheClusters\"
            ],
            \"Resource\": \"*\"
        }
    ]
}"

POLICY_ARN=$(aws iam create-policy --policy-name "${PROJECT_NAME}-policy" \
    --policy-document "$POLICY_DOCUMENT" --profile $AWS_PROFILE --query 'Policy.Arn' --output text)
echo -e "${GREEN}✓ Created IAM policy: ${POLICY_ARN}${NC}"

# Attach policy to user
aws iam attach-user-policy --user-name $IAM_USER_NAME --policy-arn $POLICY_ARN --profile $AWS_PROFILE
echo -e "${GREEN}✓ Attached policy to user${NC}"

echo -e "${GREEN}✓ IAM setup complete${NC}"
echo ""

# Generate environment configuration
echo -e "${BLUE}Generating environment configuration...${NC}"

cat > .env.sandbox.generated << EOF
# Generated AWS Sandbox Configuration
# Copy this to your .env.sandbox file and customize as needed

# Database
DATABASE_URL=postgresql://admin:$DB_PASSWORD@$DB_ENDPOINT:5432/agentmitra_db

# Redis
REDIS_URL=redis://$CACHE_ENDPOINT:6379

# AWS S3
AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY
AWS_REGION=$REGION
MINIO_BUCKET_NAME=$BUCKET_NAME
MINIO_ENDPOINT=s3.amazonaws.com

# Networking
VPC_ID=$VPC_ID
SUBNET_ID=$SUBNET_ID
SECURITY_GROUP_ID=$SG_ID

# Firebase (configure manually)
FIREBASE_API_KEY=your-firebase-api-key
FIREBASE_PROJECT_ID=${PROJECT_NAME}

# JWT Secret (generate new one for production)
JWT_SECRET_KEY=$(openssl rand -hex 32)

# CORS Origins (update with your domain)
CORS_ORIGINS=https://sandbox.agentmitra.com,https://api.sandbox.agentmitra.com
EOF

echo -e "${GREEN}✓ Generated .env.sandbox.generated file${NC}"
echo ""

# Setup cost monitoring
echo -e "${BLUE}Setting up cost monitoring...${NC}"

# Create budget
aws budgets create-budget \
    --budget-name "${PROJECT_NAME}-budget" \
    --budget-limit Amount=20,Unit=USD \
    --time-unit MONTHLY \
    --budget-type COST \
    --profile $AWS_PROFILE

echo -e "${GREEN}✓ Created budget alert ($20/month)${NC}"

# Enable Cost Explorer
aws ce create-cost-category-definition \
    --name "${PROJECT_NAME}-cost-tracking" \
    --rule-version 1.0 \
    --rules '[{"value":"Sandbox","rule":{"tags":{"key":"Environment","values":["sandbox"]}}}]' \
    --profile $AWS_PROFILE

echo -e "${GREEN}✓ Enabled cost tracking${NC}"

echo -e "${GREEN}✓ Cost monitoring setup complete${NC}"
echo ""

# Summary
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}AWS Sandbox Setup Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Infrastructure Created:${NC}"
echo "• VPC: $VPC_ID"
echo "• RDS PostgreSQL: $DB_INSTANCE_ID ($DB_ENDPOINT)"
echo "• ElastiCache Redis: $CACHE_CLUSTER_ID ($CACHE_ENDPOINT)"
echo "• S3 Bucket: $BUCKET_NAME"
echo "• Security Group: $SG_ID"
echo "• IAM User: $IAM_USER_NAME"
echo ""
echo -e "${YELLOW}Cost Estimate (First 3 Months):${NC}"
echo "• AWS Lightsail (2GB): $10/month"
echo "• RDS PostgreSQL: FREE (750 hours)"
echo "• ElastiCache Redis: FREE (750 hours)"
echo "• S3 Storage: $0-2/month"
echo "• Cloudflare: FREE"
echo "• Firebase: FREE (within limits)"
echo -e "${GREEN}Total: ~$10-12/month${NC}"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Configure Firebase project and update .env.sandbox.generated"
echo "2. Set up domain and SSL certificates"
echo "3. Deploy application using docker-compose.sandbox.yml"
echo "4. Configure monitoring and alerts"
echo "5. IMPORTANT: Delete root access keys from AWS Console after verifying setup"
echo ""
echo -e "${BLUE}Environment file generated: .env.sandbox.generated${NC}"
echo -e "${BLUE}Review and customize this file before deployment.${NC}"
echo ""
echo -e "${GREEN}Setup complete! 🎉${NC}"
