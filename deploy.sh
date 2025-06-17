#!/bin/bash

# === CONFIGURATION ===
SERVER_USER="jaltantra_v8_backend"
SERVER_IP="10.129.6.131"
REMOTE_DIR="~/backend"
JAR_NAME="jaltantra-backend-v8.jar"
PROPERTIES_FILE="application-deploy.properties"
DEPLOY_PORT=8431

echo "🚀 Starting backend deployment to $SERVER_IP..."

# === STEP 1: Stop any existing backend process ===
echo "🛑 Stopping existing backend process on server..."
ssh ${SERVER_USER}@${SERVER_IP} "
    PID=\$(ps aux | grep ${JAR_NAME} | grep -v grep | awk '{print \$2}')
    if [ ! -z \"\$PID\" ]; then
        echo \"🔍 Found process ID \$PID. Killing it...\"
        kill -9 \$PID
    else
        echo \"✅ No running backend process found.\"
    fi
"

# === STEP 2: Build the JAR ===
echo "🔨 Building JAR..."
./mvnw clean package -DskipTests

# === STEP 3: Copy files to the server ===
echo "📦 Copying JAR and properties to server..."
scp target/${JAR_NAME} ${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}/
scp src/main/resources/${PROPERTIES_FILE} ${SERVER_USER}@${SERVER_IP}:${REMOTE_DIR}/

# === STEP 4: Start the new backend process ===
echo "🚀 Starting backend on remote server..."
ssh ${SERVER_USER}@${SERVER_IP} "
    cd ${REMOTE_DIR}
    nohup java -jar -Dspring.config.location=file:${PROPERTIES_FILE} ${JAR_NAME} > backend.log 2>&1 &
    sleep 2
    echo \"⏳ Waiting for service to bind to port ${DEPLOY_PORT}...\"
    lsof -i :${DEPLOY_PORT} || echo \"❌ Port ${DEPLOY_PORT} not active yet. Check backend.log.\"
"

echo "✅ Deployment completed. You can tail the log using:"
echo "   ssh ${SERVER_USER}@${SERVER_IP} 'tail -f ${REMOTE_DIR}/backend.log'"
