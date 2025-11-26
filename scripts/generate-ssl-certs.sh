#!/bin/bash
# Script to generate self-signed SSL certificates for development
# Usage: ./scripts/generate-ssl-certs.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_DIR"

SSL_DIR="nginx/ssl"
DAYS_VALID=365

echo "Generating self-signed SSL certificates for development..."
echo "=========================================================="
echo ""

# Create SSL directory if it doesn't exist
mkdir -p "$SSL_DIR"

# Generate private key
if [ ! -f "$SSL_DIR/nginx-selfsigned.key" ]; then
    echo "Generating private key..."
    openssl genrsa -out "$SSL_DIR/nginx-selfsigned.key" 2048
    echo "✓ Private key generated"
else
    echo "✓ Private key already exists"
fi

# Generate certificate signing request and self-signed certificate
if [ ! -f "$SSL_DIR/nginx-selfsigned.crt" ]; then
    echo "Generating self-signed certificate..."
    openssl req -new -x509 -key "$SSL_DIR/nginx-selfsigned.key" \
        -out "$SSL_DIR/nginx-selfsigned.crt" \
        -days $DAYS_VALID \
        -subj "/C=IN/ST=State/L=City/O=AgentMitra/CN=localhost" \
        -addext "subjectAltName=DNS:localhost,DNS:*.localhost,IP:127.0.0.1,IP:::1"
    echo "✓ Self-signed certificate generated (valid for $DAYS_VALID days)"
else
    echo "✓ Certificate already exists"
fi

# Generate Diffie-Hellman parameters (optional but recommended)
if [ ! -f "$SSL_DIR/dhparam.pem" ]; then
    echo "Generating Diffie-Hellman parameters (this may take a while)..."
    openssl dhparam -out "$SSL_DIR/dhparam.pem" 2048
    echo "✓ DH parameters generated"
else
    echo "✓ DH parameters already exist"
fi

echo ""
echo "SSL certificates generated successfully!"
echo "Location: $SSL_DIR/"
echo ""
echo "Note: These are self-signed certificates for development only."
echo "Browsers will show a security warning - this is expected."
echo "For production, use certificates from a trusted CA (Let's Encrypt, etc.)"
echo ""

