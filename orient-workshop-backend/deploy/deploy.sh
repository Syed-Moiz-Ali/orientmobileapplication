#!/bin/bash
set -e

echo "=== Orient Workshop Backend Deployment ==="

ENV_FILE=/etc/orient/orient-api.env

# CR-6: create the env file on first deploy. It is NEVER committed and must be
# populated by the operator with real credentials before the service will start.
if [ ! -f "$ENV_FILE" ]; then
    mkdir -p /etc/orient
    cat > "$ENV_FILE" <<'EOF'
# Orient API secrets — set REAL values before starting the service.
# The app fails fast at startup when these are missing or placeholder.
DB_HOST=localhost
DB_PORT=3306
DB_NAME=orient_workshop
DB_USERNAME=orient
# Minimum-privilege DB user; do NOT use root.
DB_PASSWORD=CHANGE_ME
# >= 32 chars, random: openssl rand -base64 48
JWT_SECRET=CHANGE_ME
# >= 16 chars, random, MUST differ from JWT_SECRET: openssl rand -base64 24
ENCRYPTION_KEY=CHANGE_ME
REDIS_HOST=localhost
REDIS_PORT=6379
SPRING_PROFILES_ACTIVE=mysql
EOF
    chmod 600 "$ENV_FILE"
    chown root:orient "$ENV_FILE" 2>/dev/null || true
    echo "Created $ENV_FILE with placeholders — EDIT IT with real secrets before starting."
else
    chmod 600 "$ENV_FILE" 2>/dev/null || true
    echo "Using existing $ENV_FILE"
fi

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
    echo "Verify health: curl http://localhost:8080/api/v1/health"
else
    echo "Run as root to install systemd service."
    echo "Or run manually: java -jar deploy/orient-gateway.jar --spring.profiles.active=mysql"
fi

echo "=== Done ==="
