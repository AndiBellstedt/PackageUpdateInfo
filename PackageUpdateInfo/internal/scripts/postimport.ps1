﻿# Place all code that should be run after functions are imported here

$script:ModuleIconPath = "$($script:ModuleRoot)\bin\PackageUpdateInfo.png"
$script:ModuleTempPath = "$env:TEMP\PackageUpdateInfo"
$script:CurrentUserModulePath = $env:PSModulePath.split(';') | Where-Object {$_ -like "$(Split-Path $PROFILE -Parent)*" -or $_ -like "$($HOME)*"}
$script:AllUsersModulePath = $env:PSModulePath.split(';') | Where-Object {$_ -notlike "$(Split-Path $PROFILE -Parent)*" -and $_ -notlike "$($HOME)*"}

if(Test-Path -Path $script:ModuleTempPath) {
    Get-ChildItem -Path $script:ModuleTempPath | Where-Object LastWriteTime -lt (Get-Date).AddHours(-2) | Remove-Item -Force -Confirm:$false
} else {
    New-Item -Path $script:ModuleTempPath -ItemType Directory -Force | Out-Null
}