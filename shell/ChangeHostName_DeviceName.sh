#!/bin/bash

## Created by Gabriel Barbato - https://github.com/barbatoo
## this script defines the hostname of the Macbook based on the spreadsheet you want, relating the second column with the first
## its necessary have a third column, even though it's blank

# URL of the CSV spreadsheet
spreadsheet_url='https://docs.google.com/spreadsheets/d/ID_SPREADSHEET/export?format=csv'

# Download the CSV spreadsheet to /tmp
curl -L "$spreadsheet_url" -o /tmp/teste.csv || { echo "Error downloading the CSV spreadsheet."; exit 1; }

# Read the content of the CSV spreadsheet
spreadsheet=$(cat /tmp/teste.csv)

# Get the serial number of the MacBook
serial=$(ioreg -l | grep IOPlatformSerialNumber | awk -F\" '/IOPlatformSerialNumber/{print $4}')

# Get the hostname based on the serial number
hostname=$(echo "$spreadsheet" | awk -F ',' -v col1="$serial" '$1 == col1 {print $2}')

# Set the hostname, ComputerName, and LocalHostName
if [ -n "$hostname" ]; then
    sudo scutil --set HostName "$hostname"
    sudo scutil --set ComputerName "$hostname"
    sudo scutil --set LocalHostName "$hostname"
    echo "The hostname has been set to: $hostname"
else
    echo "The serial number is not in the CSV spreadsheet."
    rm -rf /tmp/teste.csv
    exit 1
fi

# Wait for 5 seconds before proceeding
sleep 5
echo ""

# Script 2: Update the displayName in JumpCloud

# API Key and JumpCloud organization ID
apiKey="YOUR_API_KEY"
orgID="YOUR_ORG_ID"

# Get the hostname and systemID
hostName=$(hostname)
systemID=$(sudo cat /opt/jc/jcagent.conf | grep -o '"systemKey":"[^"]*' | awk -F ':"' '{print $2}')

# Function to extract the value from JSON
extractValue() {
    local json="$1"
    local key="$2"
    local value=$(echo "$json" | grep -o "\"$key\": *\"[^\"]*\"" | awk -F '"' '{print $4}')
    echo "$value"
}

# Function to call the API PUT to update the displayName
apiPut() {
    local newDisplayName="$2"
    local systemID="$1"

    # Construct JSON to update the displayName
    updateData="{ \"displayName\": \"$newDisplayName\" }"

    # Call PUT to update the displayName
    curl -X PUT "https://console.jumpcloud.com/api/systems/$systemID" \
         -H 'Content-Type: application/json' \
         -H 'Accept: application/json' \
         -H "x-api-key: $apiKey" \
         -H "x-org-id: $orgID" \
         --data "$updateData"
}

# Check if the systemID was obtained
if [ -n "$systemID" ]; then
    # Set the new displayName as the hostname
    newDisplayName="$hostName"

    # Call the apiPut function to update the displayName
    apiPut "$systemID" "$newDisplayName"

    echo "The displayName has been updated to: $newDisplayName"
else
    echo "Failed to obtain the systemID."
fi

# Clean up the temporary CSV file
rm -rf /tmp/teste.csv