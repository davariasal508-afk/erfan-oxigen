param([string]$Destination = "E:\OxygenServerBackup\$(Get-Date -Format yyyyMMdd_HHmmss)")

$projectRoot = Split-Path -Parent $PSScriptRoot
$data = Join-Path $projectRoot 'backend\data'
$files = Join-Path $projectRoot 'backend\files'
New-Item -ItemType Directory -Force -Path $Destination | Out-Null
if (Test-Path $data) { Copy-Item $data (Join-Path $Destination 'data') -Recurse -Force }
if (Test-Path $files) { Copy-Item $files (Join-Path $Destination 'files') -Recurse -Force }
Write-Host "Backup saved to $Destination"
