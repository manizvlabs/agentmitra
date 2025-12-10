#!/bin/bash
# Agent Mitra Sandbox Deployment Script
# This script deploys the complete sandbox environment to AWS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="sandbox"
COMPOSE_FILE="docker-compose.sandbox.yml"
PROJECT_NAME="agentmitra-sandbox"
REGION="us-east-1"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Agent Mitra Sandbox Deployment${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check if AWS CLI is configured
    if ! aws sts get-caller-identity &> /dev/null; then
        print_error "AWS CLI is not configured. Please run 'aws configure' first."
        exit 1
    fi

    # Check if Docker is available
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH."
        exit 1
    fi

    # Check if Docker Compose is available
    if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not available."
        exit 1
    fi

    # Check required files
    required_files=(
        "$COMPOSE_FILE"
        "backend/Dockerfile"
        "scripts/aws/user-data.sh"
        ".env.sandbox"
    )

    for file in "${required_files[@]}"; do
        if [[ ! -f "$file" ]]; then
            print_error "Required file $file not found."
            exit 1
        fi
    done

    print_status "Prerequisites check passed."
}

# Setup AWS infrastructure
setup_aws_infrastructure() {
    print_status "Setting up AWS infrastructure..."

    if [[ -f ".env.sandbox.generated" ]]; then
        print_warning "AWS infrastructure appears to already be set up."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Skipping AWS infrastructure setup."
            return
        fi
    fi

    # Run AWS setup script
    if [[ -f "scripts/aws/setup-sandbox.sh" ]]; then
        bash scripts/aws/setup-sandbox.sh
    else
        print_error "AWS setup script not found."
        exit 1
    fi

    print_status "AWS infrastructure setup complete."
}

# Configure Firebase
configure_firebase() {
    print_status "Configuring Firebase..."

    # Check if Firebase CLI is installed
    if ! command -v firebase &> /dev/null; then
        print_warning "Firebase CLI not found. Installing..."
        npm install -g firebase-tools
    fi

    # Check if user is logged in
    if ! firebase projects:list &> /dev/null; then
        print_warning "Please login to Firebase:"
        firebase login
    fi

    # Create or select Firebase project
    if ! firebase projects:list | grep -q "$PROJECT_NAME"; then
        print_status "Creating Firebase project: $PROJECT_NAME"
        firebase projects:create "$PROJECT_NAME" --display-name "Agent Mitra Sandbox"
    else
        print_status "Using existing Firebase project: $PROJECT_NAME"
    fi

    # Initialize Firebase in project
    firebase use "$PROJECT_NAME"

    # Deploy Firebase rules and configuration
    if [[ -f "firebase.json" ]]; then
        print_status "Deploying Firebase configuration..."
        firebase deploy --only firestore:rules,storage
    fi

    # Get Firebase configuration
    FIREBASE_CONFIG=$(firebase apps:list --json | jq -r '.[] | select(.displayName=="Agent Mitra Sandbox") | .appId')

    if [[ -z "$FIREBASE_CONFIG" ]]; then
        print_warning "Could not find Firebase app. Please configure manually."
    else
        print_status "Firebase configured successfully."
    fi
}

# Build application
build_application() {
    print_status "Building application..."

    # Build Flutter web app
    if command -v flutter &> /dev/null; then
        print_status "Building Flutter web application..."
        flutter clean
        flutter pub get
        flutter build web --release
        print_status "Flutter web build complete."
    else
        print_warning "Flutter not found. Skipping web build."
        print_warning "Install Flutter or build manually: flutter build web"
    fi

    # Build Docker images
    print_status "Building Docker images..."
    docker compose -f "$COMPOSE_FILE" build --no-cache
    print_status "Docker images built successfully."
}

# Deploy to AWS Lightsail
deploy_to_lightsail() {
    print_status "Deploying to AWS Lightsail..."

    # Check if Lightsail instance exists
    if ! aws lightsail get-instances --region "$REGION" | jq -r '.instances[].name' | grep -q "$PROJECT_NAME"; then
        print_error "Lightsail instance '$PROJECT_NAME' not found."
        print_error "Please run AWS infrastructure setup first."
        exit 1
    fi

    # Get instance public IP
    INSTANCE_IP=$(aws lightsail get-instances --region "$REGION" \
        --query "instances[?name=='$PROJECT_NAME'].publicIpAddress" \
        --output text)

    if [[ -z "$INSTANCE_IP" ]]; then
        print_error "Could not get instance IP address."
        exit 1
    fi

    print_status "Instance IP: $INSTANCE_IP"

    # Copy files to instance
    print_status "Copying files to instance..."

    # Create tarball of application
    tar -czf sandbox-deploy.tar.gz \
        --exclude='node_modules' \
        --exclude='.git' \
        --exclude='build/ios' \
        --exclude='build/android' \
        --exclude='*.log' \
        .

    # Copy files to instance
    scp -o StrictHostKeyChecking=no sandbox-deploy.tar.gz ubuntu@$INSTANCE_IP:~

    # Deploy on instance
    ssh -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << EOF
        set -e

        echo "Deploying on Lightsail instance..."

        # Backup current deployment
        if [ -d "/opt/agentmitra" ]; then
            sudo cp -r /opt/agentmitra /opt/agentmitra.backup.\$(date +%Y%m%d_%H%M%S)
        fi

        # Extract new deployment
        sudo mkdir -p /opt/agentmitra
        sudo tar -xzf ~/sandbox-deploy.tar.gz -C /opt/agentmitra
        sudo chown -R ubuntu:ubuntu /opt/agentmitra

        # Set up environment
        cd /opt/agentmitra
        if [ -f ".env.sandbox.generated" ]; then
            cp .env.sandbox.generated .env
        elif [ -f ".env.sandbox" ]; then
            cp .env.sandbox .env
        fi

        # Deploy application
        sudo ./scripts/deploy/sandbox-deploy.sh remote

        echo "Remote deployment complete!"
EOF

    # Clean up
    rm sandbox-deploy.tar.gz

    print_status "Deployment to Lightsail complete."
}

# Setup domain and SSL
setup_domain_ssl() {
    print_status "Setting up domain and SSL..."

    # Check if domain is configured
    if [[ -z "${DOMAIN:-}" ]]; then
        print_warning "Domain not configured. Skipping SSL setup."
        print_warning "Set DOMAIN environment variable to enable SSL."
        return
    fi

    INSTANCE_IP=$(aws lightsail get-instances --region "$REGION" \
        --query "instances[?name=='$PROJECT_NAME'].publicIpAddress" \
        --output text)

    print_status "Please configure your domain DNS:"
    echo "  A record: $DOMAIN -> $INSTANCE_IP"
    echo "  A record: api.$DOMAIN -> $INSTANCE_IP"

    read -p "Have you configured DNS? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Requesting SSL certificate..."

        # Request SSL certificate
        ssh -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << EOF
            sudo certbot --nginx -d $DOMAIN -d api.$DOMAIN --non-interactive --agree-tos --email admin@$DOMAIN
            sudo systemctl reload nginx
EOF

        print_status "SSL certificate configured."
    else
        print_warning "SSL setup skipped. Configure DNS and run SSL setup manually."
    fi
}

# Setup monitoring
setup_monitoring() {
    print_status "Setting up monitoring..."

    INSTANCE_IP=$(aws lightsail get-instances --region "$REGION" \
        --query "instances[?name=='$PROJECT_NAME'].publicIpAddress" \
        --output text)

    # Configure Grafana dashboards (if monitoring is enabled)
    if [[ -n "${GRAFANA_PASSWORD:-}" ]]; then
        print_status "Grafana will be available at: http://$INSTANCE_IP:3001"
        print_status "Username: admin"
        print_status "Password: ${GRAFANA_PASSWORD}"
    fi

    # Configure Prometheus
    print_status "Prometheus will be available at: http://$INSTANCE_IP:9090"

    # Set up health monitoring
    print_status "Application health check: http://$INSTANCE_IP/health"
    print_status "API health check: http://$INSTANCE_IP/api/v1/health"
}

# Run health checks
run_health_checks() {
    print_status "Running health checks..."

    INSTANCE_IP=$(aws lightsail get-instances --region "$REGION" \
        --query "instances[?name=='$PROJECT_NAME'].publicIpAddress" \
        --output text)

    # Wait for services to start
    print_status "Waiting for services to start..."
    sleep 60

    # Check services
    services=(
        "http://$INSTANCE_IP/health:Application"
        "http://$INSTANCE_IP/api/v1/health:Backend API"
    )

    for service in "${services[@]}"; do
        url=$(echo $service | cut -d: -f1)
        name=$(echo $service | cut -d: -f2)

        if curl -f -s --max-time 10 "$url" > /dev/null 2>&1; then
            print_status "✓ $name is healthy"
        else
            print_warning "✗ $name health check failed"
        fi
    done

    print_status "Health checks complete."
}

# Main deployment function
main() {
    print_status "Starting Agent Mitra Sandbox Deployment"
    print_status "Environment: $ENVIRONMENT"
    print_status "Project: $PROJECT_NAME"

    check_prerequisites
    setup_aws_infrastructure
    configure_firebase
    build_application
    deploy_to_lightsail
    setup_domain_ssl
    setup_monitoring
    run_health_checks

    print_status "🎉 Agent Mitra Sandbox Deployment Complete!"

    INSTANCE_IP=$(aws lightsail get-instances --region "$REGION" \
        --query "instances[?name=='$PROJECT_NAME'].publicIpAddress" \
        --output text)

    echo ""
    print_status "Access URLs:"
    echo "  Application: http://$INSTANCE_IP"
    if [[ -n "${DOMAIN:-}" ]]; then
        echo "  Application: https://$DOMAIN"
        echo "  API: https://api.$DOMAIN"
    fi
    echo "  API: http://$INSTANCE_IP/api/v1"
    echo "  Grafana: http://$INSTANCE_IP:3001"
    echo "  Prometheus: http://$INSTANCE_IP:9090"

    echo ""
    print_status "Next Steps:"
    echo "  1. Update Firebase configuration in Flutter app"
    echo "  2. Test mobile app with sandbox backend"
    echo "  3. Configure team access and monitoring"
    echo "  4. Set up CI/CD pipeline for automated deployments"
}

# Handle remote deployment (when called from Lightsail instance)
if [[ "${1:-}" == "remote" ]]; then
    print_status "Running remote deployment on Lightsail instance..."

    # Set environment
    export ENVIRONMENT=sandbox

    # Load environment variables
    if [[ -f ".env" ]]; then
        set -a
        source .env
        set +a
    fi

    # Deploy with Docker Compose
    docker compose -f "$COMPOSE_FILE" down || true
    docker compose -f "$COMPOSE_FILE" up -d --build

    # Wait for services
    sleep 30

    # Run migrations if needed
    if [[ -f "backend/manage.py" ]]; then
        docker compose -f "$COMPOSE_FILE" exec -T backend python manage.py migrate || true
    fi

    print_status "Remote deployment complete!"
    exit 0
fi

# Handle command line arguments
case "${1:-}" in
    "infrastructure")
        check_prerequisites
        setup_aws_infrastructure
        ;;
    "firebase")
        check_prerequisites
        configure_firebase
        ;;
    "build")
        check_prerequisites
        build_application
        ;;
    "deploy")
        check_prerequisites
        deploy_to_lightsail
        ;;
    "ssl")
        setup_domain_ssl
        ;;
    "health")
        run_health_checks
        ;;
    *)
        main
        ;;
esac
