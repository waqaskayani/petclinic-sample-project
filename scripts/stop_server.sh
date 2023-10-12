#!/bin/bash

DESTINATION_PATH="/home/ubuntu/app-deployment"

# Updating permission for current user
CURRENT_USER=$(whoami)
sudo chown -R $CURRENT_USER:$CURRENT_USER $DESTINATION_PATH

SERVICE_NAME="petclinic-app"

echo "Attempting to stop the server..."
if systemctl list-units --full -all | grep -Fq "$SERVICE_NAME.service"; then
    echo "Service $SERVICE_NAME exists. Attempting to stop..."

    # Stop the service
    sudo systemctl stop "$SERVICE_NAME"

    echo "Service $SERVICE_NAME has been stopped."
else
    echo "Service $SERVICE_NAME does not exist."
fi
