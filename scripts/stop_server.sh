#!/bin/bash

echo "Attempting to stop the server..."
DESTINATION_PATH="/home/ubuntu/app-deployment"
SERVICE_NAME="petclinic-app"

if systemctl list-units --full -all | grep -Fq "$SERVICE_NAME.service"; then
    echo "Service $SERVICE_NAME exists. Attempting to stop..."

    # Stop the service
    sudo systemctl stop "$SERVICE_NAME"

    echo "Service $SERVICE_NAME has been stopped."
else
    echo "Service $SERVICE_NAME does not exist."
fi
