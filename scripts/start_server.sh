#!/bin/bash

DESTINATION_PATH="/home/ubuntu/app-deployment"
SERVICE_NAME="petclinic-app"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

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
EnvironmentFile=/usr/bin/pet-clinic.env
ExecStart=/usr/bin/run_app.sh #script that starts the application
Restart=on-failure
RestartSec=10
TimeoutStartSec=30

[Install]
WantedBy=multi-user.target
EOL
fi

sudo cp "${DESTINATION_PATH}/scripts/run_app.sh" /usr/bin

sudo chmod 644 "$SERVICE_FILE"
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

sudo systemctl start "$SERVICE_NAME"
if [ $? -eq 0 ]; then
    echo "Attempting to start service ${SERVICE_NAME}..."
else
    echo "Problem starting service ${SERVICE_NAME}, please look into configurations.."
fi
