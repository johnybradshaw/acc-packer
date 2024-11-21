#!/bin/bash
# Location: /usr/local/bin/set-hostname.sh
# Description: Set hostname based on metadata

# Redirect all output (stdout and stderr) to a log file and console
LOGFILE="/var/log/set-hostname.log"
exec > >(tee -a "$LOGFILE") 2>&1

echo "Set hostname based on metadata started at $(date)"

# Log environment variables
echo "Logging environment variables:"
env | sort

# Fetch Metadata Token
METADATA_TOKEN="$(curl -s -X PUT -H 'Metadata-Token-Expiry-Seconds: 3600' 'http://169.254.169.254/v1/token')"
if [ -z "$METADATA_TOKEN" ]; then
    echo "Error: Failed to fetch metadata token."
    exit 1
fi

# Fetch Metadata
METADATA_URL="http://169.254.169.254/v1/instance"
METADATA=$(curl -s -H "Metadata-Token: $METADATA_TOKEN" "$METADATA_URL")
if [ -z "$METADATA" ]; then
    echo "Error: Failed to fetch metadata."
    exit 1
fi

# Parse Metadata
LABEL=$(echo "$METADATA" | awk '/^label:/ {print $2}')
REGION=$(echo "$METADATA" | awk '/^region:/ {print $2}')
TLD=$(echo "$METADATA" | awk '/^tags: tld:/ {print $3}')

# Log parsed variables
echo "Parsed metadata:"
echo "LABEL=$LABEL"
echo "REGION=$REGION"
echo "TLD=$TLD"

# Set hostname
if [ -n "$LABEL" ] && [ -n "$REGION" ] && [ -n "$TLD" ]; then
    NEW_HOSTNAME="$LABEL.$REGION.$TLD"
    echo "Setting hostname to $NEW_HOSTNAME"
    hostnamectl set-hostname "$NEW_HOSTNAME"
else
    echo "Error: Missing metadata values. Hostname not set."
    exit 1
fi

echo "Set hostname based on metadata completed at $(date)"