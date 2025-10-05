#!/bin/bash
# iOS Simulator Screenshot Automation Script
# Usage: ./screenshot_ios_app.sh <app_name>

APP_NAME=$1
SCREENSHOTS_DIR="screenshots_ios"

mkdir -p "$SCREENSHOTS_DIR"

echo "Taking screenshots of $APP_NAME..."

# List of screens to capture (you would need to navigate to each screen manually)
SCREENS=(
  "Splash Screen"
  "Welcome Screen" 
  "Phone Verification"
  "OTP Verification"
  "Trial Setup"
  "Trial Expiration"
  "Customer Dashboard"
  "Policy Details"
  "WhatsApp Integration"
  "Smart Chatbot"
  "Learning Center"
  "Agent Config Dashboard"
  "ROI Analytics"
  "Campaign Builder"
)

for i in "${!SCREENS[@]}"; do
  echo "Please navigate to: ${SCREENS[$i]}"
  echo "Press Enter when ready..."
  read
  
  # Take screenshot using simctl
  xcrun simctl io booted screenshot "$SCREENSHOTS_DIR/${SCREENS[$i]// /_}_$(date +%Y%m%d_%H%M%S).png"
  
  echo "Screenshot saved: ${SCREENS[$i]}"
done

echo "All screenshots saved to: $SCREENSHOTS_DIR/"
