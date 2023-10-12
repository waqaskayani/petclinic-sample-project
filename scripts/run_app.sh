#!/bin/bash

DESTINATION_PATH="/home/ubuntu/app-deployment"

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

# Export the variables and run application
export DB_HOST
export DB_NAME
export DB_USER
export DB_PASSWORD

# Add the command to start your application here; for example:
cd $DESTINATION_PATH
sudo mvn tomcat7:run
