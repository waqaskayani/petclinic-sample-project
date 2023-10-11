#!/bin/bash

DESTINATION_PATH="/home/ubuntu/app-deployment"
SERVICE_NAME="petclinic-app"

sudo systemctl stop "$SERVICE_NAME"
