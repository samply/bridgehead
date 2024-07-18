#!/usr/bin/env bash

# Shut down a running Bridgehead.
# Behind the scenes we use systemctl to do the work.

# Function to print usage
print_usage() {
    echo "Stop the running Bridgehead"
    echo "Usage: $0 [--help | -h]"
    echo "Options:"
    echo "  --help, -h     Display this help message."
    echo "  No options     Stop Bridgehead only."
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --help|-h)
            print_usage
            exit 0
            ;;
        *)
            echo "Error: Unknown argument '$1'"
            print_usage
            exit 1
            ;;
    esac
    shift
done

# Set up systemctl for EHDS2/ECDC if necessary
cp /srv/docker/bridgehead/ecdc.service /etc/systemd/system
systemctl daemon-reload
systemctl enable ecdc.service

# Use systemctl to stop the Bridgehead if it is running
sudo systemctl stop ecdc.service

# Show status of Bridgehead service
sleep 20
systemctl status ecdc.service
docker ps

