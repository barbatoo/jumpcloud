$id = "ID_DO_DEVICE"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("x-org-id", "SUA_ORG_ID")
$headers.Add("Accept", "application/json")
$headers.Add("x-api-key", "SUA_API_KEY")

$Hostname = hostname

$body = @{
    displayName = $Hostname
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/systems/$id" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body