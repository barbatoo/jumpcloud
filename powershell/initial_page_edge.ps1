### set the homepage for all users
$edgePoliciesKey = "HKLM:\Software\Policies\Microsoft\Edge"
$restoreOnStartupURLsKey = "$edgePoliciesKey\RestoreOnStartupURLs"

### create the main Edge policies key if it does not exist
if (-not (Test-Path $edgePoliciesKey)) {
    New-Item -Path $edgePoliciesKey -Force | Out-Null
}

### set the RestoreOnStartup value to use specific URLs
Set-ItemProperty -Path $edgePoliciesKey -Name "RestoreOnStartup" -Value 4 -Type DWord

### create the startup URLs key if it does not exist
if (-not (Test-Path $restoreOnStartupURLsKey)) {
    New-Item -Path $restoreOnStartupURLsKey -Force | Out-Null
}

### define the initial url
Set-ItemProperty -Path $restoreOnStartupURLsKey -Name "1" -Value "https://www.exemplo.com" -Type String

Write-Host "Configuração concluída!"
