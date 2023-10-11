#!/bin/bash

DESTINATION_PATH="/home/ubuntu/app-deployment"
SERVICE_NAME="petclinic-app"
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

# Check if the service file already exists
if [ -f "$SERVICE_FILE" ]; then
    echo "Service file $SERVICE_FILE already exists."
else
    # Create the systemd service file
    sudo cat > "$SERVICE_FILE" <<EOL
    [Unit]
    Description=PetClinit Application
    After=network.target
    
    [Service]
    Type=simple
    User=ubuntu # or specify a specific user to run the app
    WorkingDirectory=$DESTINATION_PATH # directory of your Maven application
    ExecStart=$DESTINATION_PATH/scripts/run_app.sh # script that starts the application
    Restart=on-failure
    RestartSec=10
    TimeoutStartSec=30
    
    [Install]
    WantedBy=multi-user.target
    EOL
fi

sudo chmod 644 "$SERVICE_FILE"
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"

sudo systemctl start "$SERVICE_NAME"
