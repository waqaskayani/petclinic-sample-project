#!/bin/bash

# Install Java if it's not installed
if ! command -v java &> /dev/null
then
    wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add - 
    sudo add-apt-repository 'deb https://apt.corretto.aws stable main'
    sudo apt-get install -y java-1.8.0-amazon-corretto-jdk
fi

# Creating a backup of Jar binary
DESTINATION_PATH="/home/ubuntu/app-deployment"
BACKUP_PATH="/home/ubuntu/backup-binaries"

# Create a backup directory if it doesn't exist
mkdir -p $BACKUP_PATH

# If there's an existing JAR, backup it
if [ -f "${DESTINATION_PATH}/petclinic.war" ]; then
    cp "${DESTINATION_PATH}/petclinic.war" "${BACKUP_PATH}/petclinic-$(date +%F-%T).war"
fi
echo "Successfully created backup of last deployment binary.."
