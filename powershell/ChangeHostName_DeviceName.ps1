## Created by Gabriel Barbato - https://github.com/barbatoo
## this script defines the hostname of a Windows device based on the spreadsheet you want, relating the second column with the first
## its necessary have a third column, even though it's blank

# Script 1
# download spreadsheet
$planilhaURL = 'https://docs.google.com/spreadsheets/d/SPREADSHEET_ID/export?format=csv'

# spreadsheet
$csvFilePath = 'C:\Users\planilha.csv'

Invoke-WebRequest -Uri $planilhaURL -OutFile $csvFilePath

$csvData = Import-Csv -Path $csvFilePath

# get the serial of the device
$Serial = (Get-WmiObject -Class Win32_BIOS).SerialNumber

# check if the serial of the current device is in the spreadsheet, and define his HostName based on it
# change the “Hostname” at the end of the line to the name of the second column
$Hostname = $csvData | Where-Object { $_.Serial -eq $Serial } | Select-Object -ExpandProperty Hostname

# define a new hostname
Rename-Computer -NewName $Hostname

Write-Host "O computador foi renomeado para: $Hostname"

# space to split the script
Write-Host ""

# Script 2
$apiKey="YOUR_API_KEY"
$orgID="YOUR_ORG_ID"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("x-org-id", "$orgID")
$headers.Add("Accept", "application/json")
$headers.Add("x-api-key", "$apiKey")

$serial = (Get-WmiObject -Class Win32_BIOS).SerialNumber

$response = Invoke-RestMethod "https://console.jumpcloud.com/api/systems?fields=id&limit=5&skip=0&filter=serialNumber%3A%24eq%3A$serial" -Method 'GET' -Headers $headers

$id = $response.results[0].id

Write-Host "O systemID da máquina é $id"

# space to split the script
Write-Host ""

# Script 3
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("x-org-id", "$orgID")
$headers.Add("Accept", "application/json")
$headers.Add("x-api-key", "$apiKey")

$body = @{
    displayName = $Hostname
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "https://console.jumpcloud.com/api/systems/$id" -Method PUT -Headers $headers -ContentType 'application/json' -Body $body

Write-Host "O displayName do JC foi definido para: $Hostname"

#remove the spreadsheet
Remove-Item -Path $csvFilePath -Force