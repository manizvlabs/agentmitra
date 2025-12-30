#!/bin/bash

# Fix .env file for Flutter web builds served by nginx
# This ensures relative URLs are used for API calls

echo "=== Fixing .env file for Flutter web builds ==="
echo ""

# Backup current .env
cp .env .env.before_web_fix

# Fix API_BASE_URL for web builds (empty string for relative URLs)
sed -i '' 's/API_BASE_URL=http:\/\/localhost/API_BASE_URL=/' .env

# Fix WS_BASE_URL for web builds (empty string for relative URLs)  
sed -i '' 's/WS_BASE_URL=ws:\/\/localhost/WS_BASE_URL=/' .env

echo "✅ .env file updated for Flutter web builds"
echo ""
echo "Changes made:"
echo "- API_BASE_URL: 'http://localhost' → '' (relative URLs)"
echo "- WS_BASE_URL: 'ws://localhost' → '' (relative URLs)"
echo ""
echo "This enables proper nginx proxy routing for Flutter web apps."
echo ""
echo "Original .env backed up as .env.before_web_fix"
echo ""
echo "Now rebuild Flutter web app:"
echo "flutter clean && flutter pub get && flutter build web --release"
