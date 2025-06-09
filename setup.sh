#!/bin/bash

echo "🔧 Starting Backend API Setup..."

# ---------------------- Java and Maven Setup -------------------------
if ! command -v java &> /dev/null; then
    echo "📦 Installing OpenJDK 17..."
    sudo apt update
    sudo apt install -y openjdk-17-jdk
else
    echo "✅ Java already installed"
fi

if ! command -v mvn &> /dev/null; then
    echo "📦 Installing Maven..."
    sudo apt install -y maven
else
    echo "✅ Maven already installed"
fi

# ---------------------- MySQL Setup ----------------------------------

# Function to check if MySQL is installed
is_mysql_installed() {
    dpkg -l | grep -q mysql-server
}

# Function to check if MySQL user exists
does_mysql_user_exist() {
    sudo mysql -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = 'dev')" | grep -q 1
}

if ! is_mysql_installed; then
    echo "📦 Installing MySQL Server..."
    sudo apt install -y mysql-server
else
    echo "✅ MySQL already installed"
fi

echo "▶️ Starting MySQL..."
sudo systemctl start mysql

if ! does_mysql_user_exist; then
    echo "👤 Creating MySQL user 'dev'"
    sudo mysql <<MYSQL_SCRIPT
CREATE USER 'dev'@'localhost' IDENTIFIED BY 'dev';
GRANT ALL PRIVILEGES ON *.* TO 'dev'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
MYSQL_SCRIPT
else
    echo "✅ MySQL user 'dev' already exists"
fi

echo "📁 Creating database 'jaltantra_v8'"
sudo mysql -u dev -pdev <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS jaltantra_v8;
MYSQL_SCRIPT

# ---------------------- Spring Properties Patching -------------------

current_dir=$(pwd)
properties_file="$current_dir/src/main/resources/application-dev.properties"

echo "📄 Patching application-dev.properties at $properties_file"

if [ ! -f "$properties_file" ]; then
    echo "❌ ERROR: Cannot find application-dev.properties"
    exit 1
fi

modified_contents=$(grep -v -E 'spring\.datasource\.username|spring\.datasource\.password|solver\.root\.dir' $properties_file)
modified_contents+="
spring.datasource.username=dev
spring.datasource.password=dev
"

echo -e "$modified_contents" > $properties_file

# ---------------------- Maven Build ----------------------------------

echo "🔨 Building Backend..."
./mvnw clean install

echo "✅ Backend API setup complete. Use './run.sh' to start the server."
