$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("x-org-id", "SUA_ORG_ID")
$headers.Add("Accept", "application/json")
$headers.Add("x-api-key", "SUA_API_KEY")

$Hostname = hostname

$body = @{
    displayName = $Hostname
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri 'https://console.jumpcloud.com/api/systems/64ff23b8325dea1aa84cb9c8' -Method PUT -Headers $headers -ContentType 'application/json' -Body $body