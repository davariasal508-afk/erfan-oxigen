param(
  [int]$Port = 8787,
  [string]$ApiToken = ""
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if (-not (Get-Command tailscale -ErrorAction SilentlyContinue)) {
  Write-Host "Tailscale was not found in PATH." -ForegroundColor Yellow
  Write-Host "Install it from: https://tailscale.com/download/windows" -ForegroundColor Yellow
  exit 1
}

$tsIp = (tailscale ip -4 | Select-Object -First 1).Trim()
if (-not $tsIp) {
  Write-Host "No Tailscale IPv4 address was found. Make sure Tailscale is running and signed in." -ForegroundColor Yellow
  exit 1
}

$env:OXIGEN_HOST = "0.0.0.0"
$env:OXIGEN_PORT = "$Port"
if ($ApiToken) { $env:OXIGEN_API_TOKEN = $ApiToken }

Write-Host "ERFAN OXIGEN server starting" -ForegroundColor Cyan
Write-Host "Tailscale server address: http://$tsIp`:$Port" -ForegroundColor Green
Write-Host "Keep this PC and its Tailscale service running for remote access." -ForegroundColor Gray
Write-Host ""

dart run backend/server.dart
