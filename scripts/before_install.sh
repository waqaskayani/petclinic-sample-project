#!/bin/bash

# Install Java if it's not installed
if ! command -v java &> /dev/null
then
    wget -O- https://apt.corretto.aws/corretto.key | sudo apt-key add - 
    sudo add-apt-repository 'deb https://apt.corretto.aws stable main'
    sudo apt-get install -y java-1.8.0-amazon-corretto-jdk maven
fi

DESTINATION_PATH="/home/ubuntu/app-deployment"

# If there's an existing target directory
if [ -d "${DESTINATION_PATH}/target" ]; then
    cd ${DESTINATION_PATH}
    sudo mvn clean
fi
echo "Successfully cleaned up target path.."
