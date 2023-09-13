#!/bin/zsh

orgID="YOUR_ORG_ID"
apiKey="YOUR_API_KEY"
new_device_name="NEW_DEVICE_NAME"
id=$(sudo cat /opt/jc/jcagent.conf | grep -o '"systemKey":"[^"]*' | awk -F ':"' '{print $2}')

curl --request PUT \
  --url "https://console.jumpcloud.com/api/systems/$id" \
  --header "content-type: application/json" \
  --header "x-api-key: $apiKey" \
  --header "x-org-id: $orgID" \
  --data "{\"displayName\":\"$new_device_name\"}"
