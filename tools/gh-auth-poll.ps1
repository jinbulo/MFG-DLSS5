# Polls GitHub's OAuth device flow until the user authorises, then stores the
# token in a local file. Prints status only - never prints the token itself.
$ErrorActionPreference = 'Stop'
$deviceFile = Join-Path $env:TEMP 'gh_device.json'
$tokenFile  = Join-Path $env:TEMP 'gh_token.json'

if (-not (Test-Path $deviceFile)) { Write-Output 'NO-DEVICE-FILE'; exit 1 }
$dev = Get-Content $deviceFile -Raw | ConvertFrom-Json
$clientId = '178c6fc778ccc68e1d6a'
if (Test-Path $tokenFile) { Remove-Item $tokenFile -Force }

for ($i = 0; $i -lt 180; $i++) {
    $body = "client_id=$clientId&device_code=$($dev.device_code)&grant_type=urn:ietf:params:oauth:grant-type:device_code"
    $r = curl.exe -s -X POST -H "Accept: application/json" -d $body https://github.com/login/oauth/access_token
    if ($r -match 'access_token') {
        [System.IO.File]::WriteAllText($tokenFile, $r)
        Write-Output "AUTHORIZED after $($i * 5)s"
        exit 0
    }
    if ($r -match 'expired_token') { Write-Output 'EXPIRED'; exit 2 }
    if ($r -match 'access_denied') { Write-Output 'DENIED'; exit 3 }
    Start-Sleep -Seconds 5
}
Write-Output 'TIMEOUT'
exit 4
