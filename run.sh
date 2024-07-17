#!/usr/bin/env bash

# Start a Bridgehead from the command line. Upload data if requested.
# Behind the scenes we use systemctl to do the work.

# Function to print usage
print_usage() {
    echo "Start a Bridghead, optionally upload data"
    echo "Usage: $0 [--upload | --upload-all | --help | -h]"
    echo "Options:"
    echo "  --upload       Run Bridgehead and upload just the new CSV data files."
    echo "  --upload-all   Run Bridgehead and upload all CSV data files."
    echo "  --help, -h     Display this help message."
    echo "  No options     Run Bridgehead only."
}

# Initialize variables
UPLOAD=false
UPLOAD_ALL=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --upload)
            UPLOAD=true
            ;;
        --upload-all)
            UPLOAD_ALL=true
            ;;
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

# Check for conflicting options
if [ "$UPLOAD" = true ] && [ "$UPLOAD_ALL" = true ]; then
    echo "Error: you must specify either --upload or --upload-all, specifying both is not permitted."
    print_usage
    exit 1
fi

# Disable/stop standard Bridgehead systemctl services, if present
sudo systemctl disable bridgehead@bbmri.service
sudo systemctl disable system-bridgehead.slice
sudo systemctl disable bridgehead-update@bbmri.timer
sudo systemctl stop bridgehead@bbmri.service
sudo systemctl stop system-bridgehead.slice
sudo systemctl stop bridgehead-update@bbmri.timer

# Set up systemctl for EHDS2/ECDC if necessary
cp /srv/docker/bridgehead/ecdc.service /etc/systemd/system
systemctl daemon-reload
systemctl enable ecdc.service

# Use systemctl to stop the Bridgehead if it is running
sudo systemctl stop ecdc.service

# Use files to tell the Bridgehead what to do with any data present
if [ "$UPLOAD" = true ] || [ "$UPLOAD_ALL" = true ]; then
    if [ -f /srv/docker/ecdc/data/lock ]; then
        rm /srv/docker/ecdc/data/lock
    fi
fi
if [ "$UPLOAD_ALL" = true ]; then
    echo "All CSV files in /srv/docker/ecdc/data will be uploaded"
    touch /srv/docker/ecdc/data/flush_blaze
fi

# Start up the Bridgehead
sudo systemctl start ecdc.service

