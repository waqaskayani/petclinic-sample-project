#!/bin/bash

DESTINATION_PATH="/home/ubuntu/app-deployment"

# Add the command to start your application here; for example:
cd $DESTINATION_PATH
sudo mvn tomcat7:run
