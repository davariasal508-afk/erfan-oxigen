$ErrorActionPreference = "Stop"
$offlineHome = "D:\Oxygen-AGP-8.9.1-Offline"
if (Test-Path $offlineHome) {
  $env:GRADLE_USER_HOME = $offlineHome
  Write-Host "GRADLE_USER_HOME=$offlineHome"
} else {
  Write-Warning "Offline Gradle Home not found: $offlineHome"
  Write-Warning "Continuing with the normal Gradle cache."
}
Set-Location (Join-Path $PSScriptRoot "..")
dart run backend/server.dart
