#!/bin/bash

DESTINATION_PATH="/home/ubuntu/app-deployment"
SERVICE_NAME="petclinic-app"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"
ENV_FILE="/usr/bin/pet-clinic.env"

# Check if the service file already exists
if [ -f "$SERVICE_FILE" ]; then
    echo "Service file $SERVICE_FILE already exists."
else
# Create the systemd service file
sudo tee "${SERVICE_FILE}" > /dev/null <<EOL
[Unit]
Description=PetClinic Application
After=network.target

[Service]
Type=simple
EnvironmentFile=$ENV_FILE
ExecStart=/usr/bin/run_app.sh #script that starts the application
Restart=on-failure
RestartSec=10
TimeoutStartSec=30

[Install]
WantedBy=multi-user.target
EOL
fi

sudo cp "${DESTINATION_PATH}/scripts/run_app.sh" /usr/bin

# Fetch parameters from AWS SSM Parameter Store
echo "Fetching parameters from AWS SSM Parameter store..."
DB_HOST=$(aws ssm get-parameter --name "/dev/database/host" --with-decryption --query "Parameter.Value" --output text)
DB_NAME=$(aws ssm get-parameter --name "/dev/database/db_name" --with-decryption --query "Parameter.Value" --output text)
DB_USER=$(aws ssm get-parameter --name "/dev/database/user" --with-decryption --query "Parameter.Value" --output text)
DB_PASSWORD=$(aws ssm get-parameter --name "/dev/database/password" --with-decryption --query "Parameter.Value" --output text)
if [ $? -eq 0 ]; then
    echo "Fetched parameters successfully..."
else
    echo "Problem fetching parameters, please look into configurations.."
fi

# Create the environment file  file
sudo tee "${ENV_FILE}" > /dev/null <<EOL
DB_HOST=$DB_HOST
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASSWORD=$DB_PASSWORD
EOL

# Reloading daemon and starting service
sudo chmod 644 "$SERVICE_FILE"
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

sudo systemctl start "$SERVICE_NAME"
if [ $? -eq 0 ]; then
    echo "Attempting to start service ${SERVICE_NAME}..."
else
    echo "Problem starting service ${SERVICE_NAME}, please look into configurations.."
fi
