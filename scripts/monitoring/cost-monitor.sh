#!/bin/bash
# Agent Mitra Cost Monitoring Script
# Tracks and reports AWS and Firebase costs for the sandbox environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="agentmitra-sandbox"
REGION="us-east-1"
BUDGET_LIMIT=20
ALERT_THRESHOLD=80  # Alert when 80% of budget used

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

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Get AWS costs for current month
get_aws_costs() {
    print_status "Fetching AWS cost data..."

    # Get current month costs
    CURRENT_MONTH=$(date +%Y-%m)
    START_DATE="${CURRENT_MONTH}-01"
    END_DATE=$(date +%Y-%m-%d)

    # Get total cost
    TOTAL_COST=$(aws ce get-cost-and-usage \
        --time-period Start=$START_DATE,End=$END_DATE \
        --granularity MONTHLY \
        --metrics BlendedCost \
        --query 'ResultsByTime[0].Groups[0].Metrics.BlendedCost.Amount' \
        --output text 2>/dev/null || echo "0")

    # Get cost by service
    COST_BY_SERVICE=$(aws ce get-cost-and-usage \
        --time-period Start=$START_DATE,End=$END_DATE \
        --granularity MONTHLY \
        --metrics BlendedCost \
        --group-by Type=DIMENSION,Key=SERVICE \
        --query 'ResultsByTime[0].Groups[].{Service:Keys[0],Cost:Metrics.BlendedCost.Amount}' \
        --output json 2>/dev/null || echo "[]")

    echo "$TOTAL_COST|$COST_BY_SERVICE"
}

# Get Firebase costs (estimated based on usage)
get_firebase_costs() {
    print_status "Estimating Firebase costs..."

    # This is a simplified estimation
    # In production, you'd integrate with Firebase Billing API

    # FCM costs (based on messages sent)
    FCM_MESSAGES=${FCM_MESSAGES:-1000}  # Default estimate
    FCM_COST=0

    if (( FCM_MESSAGES > 500000 )); then
        FCM_COST=$(echo "scale=4; ($FCM_MESSAGES - 500000) * 0.000005" | bc)
    fi

    # Firestore costs (based on reads/writes)
    FIRESTORE_READS=${FIRESTORE_READS:-50000}  # Default estimate
    FIRESTORE_WRITES=${FIRESTORE_WRITES:-10000}  # Default estimate

    if (( FIRESTORE_READS > 50000 )); then
        FIRESTORE_COST=$(echo "scale=4; ($FIRESTORE_READS - 50000) / 100000 * 0.06" | bc)
    else
        FIRESTORE_COST=0
    fi

    # Auth costs
    AUTH_USERS=${AUTH_USERS:-100}  # Default estimate
    AUTH_COST=0

    if (( AUTH_USERS > 10000 )); then
        AUTH_COST=$(echo "scale=4; ($AUTH_USERS - 10000) * 0.000055" | bc)
    fi

    TOTAL_FIREBASE_COST=$(echo "scale=4; $FCM_COST + $FIRESTORE_COST + $AUTH_COST" | bc)

    echo "$TOTAL_FIREBASE_COST|$FCM_COST|$FIRESTORE_COST|$AUTH_COST"
}

# Check budget status
check_budget() {
    print_status "Checking budget status..."

    BUDGET_STATUS=$(aws budgets describe-budget \
        --budget-name "${PROJECT_NAME}-budget" \
        --query 'Budget.BudgetLimit.Amount' \
        --output text 2>/dev/null || echo "")

    if [[ -z "$BUDGET_STATUS" ]]; then
        print_warning "Budget not configured. Run AWS setup script first."
        return
    fi

    echo "$BUDGET_STATUS"
}

# Generate cost report
generate_report() {
    print_header "Agent Mitra Sandbox Cost Report"
    echo "Generated: $(date)"
    echo ""

    # AWS Costs
    print_header "AWS Costs (Current Month)"
    AWS_DATA=$(get_aws_costs)
    AWS_TOTAL=$(echo $AWS_DATA | cut -d'|' -f1)
    AWS_SERVICES=$(echo $AWS_DATA | cut -d'|' -f2)

    printf "Total AWS Cost: $%.2f\n" $AWS_TOTAL
    echo ""

    if [[ "$AWS_SERVICES" != "[]" ]]; then
        echo "Cost by Service:"
        echo "$AWS_SERVICES" | jq -r '.[] | "  \(.Service): $\(.Cost)"' 2>/dev/null || echo "  Unable to parse service costs"
        echo ""
    fi

    # Firebase Costs
    print_header "Firebase Costs (Estimated)"
    FIREBASE_DATA=$(get_firebase_costs)
    FIREBASE_TOTAL=$(echo $FIREBASE_DATA | cut -d'|' -f1)
    FCM_COST=$(echo $FIREBASE_DATA | cut -d'|' -f2)
    FIRESTORE_COST=$(echo $FIREBASE_DATA | cut -d'|' -f3)
    AUTH_COST=$(echo $FIREBASE_DATA | cut -d'|' -f4)

    printf "Total Firebase Cost: $%.2f\n" $FIREBASE_TOTAL
    printf "  FCM: $%.2f\n" $FCM_COST
    printf "  Firestore: $%.2f\n" $FIRESTORE_COST
    printf "  Auth: $%.2f\n" $AUTH_COST
    echo ""

    # Budget Status
    BUDGET=$(check_budget)
    if [[ -n "$BUDGET" ]]; then
        print_header "Budget Status"
        printf "Budget Limit: $%.0f/month\n" $BUDGET
        printf "Current Spend: $%.2f\n" $AWS_TOTAL

        USAGE_PERCENT=$(echo "scale=2; ($AWS_TOTAL / $BUDGET) * 100" | bc 2>/dev/null || echo "0")
        printf "Usage: %.1f%%\n" $USAGE_PERCENT

        if (( $(echo "$USAGE_PERCENT >= $ALERT_THRESHOLD" | bc -l 2>/dev/null || echo "0") )); then
            print_warning "⚠️  ALERT: Budget usage is above ${ALERT_THRESHOLD}%"
        else
            print_status "✓ Budget usage is within limits"
        fi
        echo ""
    fi

    # Cost Projections
    print_header "Cost Projections"

    # Estimate next month based on current usage
    DAYS_IN_MONTH=$(date -d "$(date +%Y-%m-01) +1 month -1 day" +%d)
    DAYS_PASSED=$(date +%d)
    MONTHLY_PROJECTION=$(echo "scale=2; ($AWS_TOTAL / $DAYS_PASSED) * $DAYS_IN_MONTH" | bc 2>/dev/null || echo "0")

    printf "Projected Monthly Cost: $%.2f\n" $MONTHLY_PROJECTION

    if (( $(echo "$MONTHLY_PROJECTION > $BUDGET" | bc -l 2>/dev/null || echo "0") )); then
        print_warning "⚠️  WARNING: Projected cost exceeds budget"
    fi

    echo ""

    # Cost Optimization Recommendations
    print_header "Cost Optimization Recommendations"

    if (( $(echo "$AWS_TOTAL > 5" | bc -l 2>/dev/null || echo "0") )); then
        echo "• Consider using spot instances for development workloads"
        echo "• Review and terminate unused EC2 instances"
        echo "• Use AWS Savings Plans for consistent workloads"
    fi

    if (( $(echo "$FIREBASE_TOTAL > 1" | bc -l 2>/dev/null || echo "0") )); then
        echo "• Implement Firebase usage monitoring"
        echo "• Batch FCM messages to reduce API calls"
        echo "• Optimize Firestore queries and indexes"
    fi

    echo "• Monitor usage daily and set up alerts"
    echo "• Use development environments only when needed"
    echo "• Consider reserved instances for production workloads"
    echo ""
}

# Send alert if budget exceeded
send_alert() {
    ALERT_EMAIL=${ALERT_EMAIL:-""}

    if [[ -z "$ALERT_EMAIL" ]]; then
        print_warning "No alert email configured. Set ALERT_EMAIL environment variable."
        return
    fi

    AWS_DATA=$(get_aws_costs)
    AWS_TOTAL=$(echo $AWS_DATA | cut -d'|' -f1)

    if (( $(echo "$AWS_TOTAL > ($BUDGET_LIMIT * $ALERT_THRESHOLD / 100)" | bc -l 2>/dev/null || echo "0") )); then
        print_warning "Sending budget alert email..."

        # This would require mail utilities or AWS SES
        # For now, just log the alert
        echo "ALERT: Sandbox budget usage is high - Current: $AWS_TOTAL, Limit: $BUDGET_LIMIT" >> cost-alerts.log
    fi
}

# Generate detailed breakdown
detailed_breakdown() {
    print_header "Detailed Cost Breakdown"

    # Get last 30 days of costs
    END_DATE=$(date +%Y-%m-%d)
    START_DATE=$(date -d '30 days ago' +%Y-%m-%d)

    echo "Cost breakdown for last 30 days ($START_DATE to $END_DATE):"
    echo ""

    aws ce get-cost-and-usage \
        --time-period Start=$START_DATE,End=$END_DATE \
        --granularity DAILY \
        --metrics BlendedCost \
        --group-by Type=DIMENSION,Key=SERVICE \
        --query 'ResultsByTime[].Groups[].[TimePeriod.Start,Keys[0],Metrics.BlendedCost.Amount]' \
        --output table 2>/dev/null || print_warning "Unable to fetch detailed breakdown"
}

# Main function
main() {
    case "${1:-}" in
        "report")
            generate_report
            ;;
        "alert")
            send_alert
            ;;
        "detailed")
            detailed_breakdown
            ;;
        "daily")
            generate_report > "cost-report-$(date +%Y%m%d).txt"
            send_alert
            print_status "Daily cost report generated"
            ;;
        *)
            generate_report
            ;;
    esac
}

# Run main function
main "$@"
