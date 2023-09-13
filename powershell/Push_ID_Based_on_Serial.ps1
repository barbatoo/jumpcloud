$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("x-org-id", "SEU_ORG_ID")
$headers.Add("Accept", "application/json")
$headers.Add("x-api-key", "SUA_API_KEY")

$serial = (Get-WmiObject -Class Win32_BIOS).SerialNumber

$response = Invoke-RestMethod "https://console.jumpcloud.com/api/systems?fields=id&limit=5&skip=0&filter=serialNumber%3A%24eq%3A$serial" -Method 'GET' -Headers $headers

$id = $response.results[0].id

Write-Host "$id"