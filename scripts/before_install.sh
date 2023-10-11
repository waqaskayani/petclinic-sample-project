#!/bin/bash

# Install Java if it's not installed
if ! command -v java &> /dev/null
then
    sudo apt-get update -y
    sudo apt-get install -y openjdk-8-jdk -y
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
