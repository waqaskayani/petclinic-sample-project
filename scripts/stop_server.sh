#!/bin/bash

DESTINATION_PATH="/home/ubuntu/app-deployment"

# Get the process ID of the Java application and kill it
pkill -f "java -jar ${DESTINATION_PATH}/petclinic.war"
