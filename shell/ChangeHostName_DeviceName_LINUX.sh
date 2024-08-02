#!/bin/bash

## Created by Gabriel Barbato - https://github.com/barbatoo
## this script defines the hostname of the Linux based on the spreadsheet you want, relating the second column with the first
## its necessary have a third column, even though it's blank

# Script 1
# download spreadsheet
curl -L 'https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/export?format=csv' -o /tmp/teste.csv

# spreadsheet
output=$(cat /tmp/teste.csv)

# indicators
SERIAL=$(dmidecode -s system-serial-number)
HOSTNAME=$(echo "$output" | awk -F ',' -v col1="$SERIAL" '$1 == col1 {print $2}')

# check if the serial of the current Macbook is in the spreadsheet, and define his HostName based on it
# and defines if the hostname that was asked to be defined, matches the one defined
if [ -n "$HOSTNAME" ]; then

    echo "$HOSTNAME" | sudo tee /etc/hostname >/dev/null

    sudo sed -i "s/127.0.1.1.*/127.0.1.1\t$HOSTNAME/" /etc/hosts

    sudo hostnamectl set-hostname "$HOSTNAME"

    sudo systemctl restart hostname

else
    # if the serial of the current Linux is not in the spreadsheet, it shows this error message
    echo "Serial NÃO está na planilha"

    rm -rf /tmp/teste.csv
    exit 1
fi

# Wait 5 seconds before run the next script
sleep 5
echo ""

# Script 2

# indicators
apiKey="YOUR_API_KEY"
orgID="YOUR_ORG_ID"

# function to extract the value of JSON
extractValue() {
    local json="$1"
    local key="$2"
    local value=$(echo "$json" | grep -o "\"$key\": *\"[^\"]*\"" | awk -F '"' '{print $4}')
    echo "$value"
}

# function to call API GET
apiGet() {
    response=$(curl \
        -X GET "https://console.jumpcloud.com/api/systems/?filter=serialNumber:${SERIAL}" \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -H "x-api-key: ${apiKey}" \
        -H "x-org-id: ${orgID}")

    # extract the systemID of JSON
    systemID=$(extractValue "$response" "id")

    echo "$systemID"
}

# function to call the API PUT to update the displayName
apiPut() {
    local systemID="$1"
    local newDisplayName="$2"

    # Mount JSON to update the displayName
    updateData="{ \"displayName\": \"$newDisplayName\" }"

    # Call a PUT to update the displayName
    curl \
        -X PUT "https://console.jumpcloud.com/api/systems/$systemID" \
        -H 'Content-Type: application/json' \
        -H 'Accept: application/json' \
        -H "x-api-key: ${apiKey}" \
        -H "x-org-id: ${orgID}" \
        --data "$updateData"
}

# call to function of API GET to obtain the systemID
systemID=$(apiGet)

if [ -n "$systemID" ]; then
    # define the new displayName
    newDisplayName="$HOSTNAME"

    # call the function of API PUT to update the displayName
    apiPut "$systemID" "$newDisplayName"

    echo "O displayName foi atualizado para: $newDisplayName"
else
    echo "Não foi possível obter o systemID."
fi

#remove the spreadsheet
rm -rf /tmp/teste.csv