#!/bin/bash

echo "🚀 Running Backend API..."

JAR_FILE=$(find target -name '*.jar' | head -n 1)

if [ -z "$JAR_FILE" ]; then
    echo "❌ JAR not found. Run ./setup.sh first."
    exit 1
fi

java -jar "$JAR_FILE" --spring.profiles.active=dev
