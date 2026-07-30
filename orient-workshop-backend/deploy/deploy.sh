#!/bin/bash
set -e

echo "=== Orient Workshop Backend Deployment ==="

# Build the application
echo "Building application..."
./mvnw clean package -pl orient-gateway -am -DskipTests

# Copy JAR
echo "Copying JAR..."
cp orient-gateway/target/orient-gateway-*.jar deploy/orient-gateway.jar

# Setup systemd service (requires sudo)
if [ "$EUID" -eq 0 ]; then
    echo "Setting up systemd service..."
    cp deploy/orient-api.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable orient-api
    systemctl restart orient-api
    echo "Service started. Check status: systemctl status orient-api"
else
    echo "Run as root to install systemd service."
    echo "Or run manually: java -jar deploy/orient-gateway.jar"
fi

echo "=== Done ==="
