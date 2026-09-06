param(
  [int]$Port = 8787,
  [string]$Host = '0.0.0.0',
  [string]$DataDir = '',
  [string]$FilesDir = ''
)

Set-Location $PSScriptRoot\..
$argsList = @("run", "backend/server.dart", "--host=$Host", "--port=$Port")
if ($DataDir -ne '') { $argsList += "--data-dir=$DataDir" }
if ($FilesDir -ne '') { $argsList += "--files-dir=$FilesDir" }
& dart @argsList
