﻿# Place all code that should be run after functions are imported here

$script:ModuleIconPath = Join-Path -Path $script:ModuleRoot -ChildPath "\bin\PackageUpdateInfo.png"

if ($isLinux) {
    $script:ModuleTempPath = Join-Path -Path "/tmp" -ChildPath "PackageUpdateInfo"
    $script:ModuleSettingPath = Join-Path -Path $HOME -ChildPath ".local/share/powershell/PackageUpdateInfo/PackageUpdateSetting_$($PSEdition)_$($PSVersionTable.PSVersion.Major).json"
} else {
    $script:ModuleTempPath = Join-Path -Path $env:TEMP -ChildPath "PackageUpdateInfo"
    $script:ModuleSettingPath = Join-Path -Path $HOME -ChildPath "AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateSetting_$($PSEdition)_$($PSVersionTable.PSVersion.Major).json"
}

$script:CurrentUserModulePath = $env:PSModulePath.split(';') | Where-Object { $_ -like "$(Split-Path $PROFILE -Parent)*" -or $_ -like "$($HOME)*" }
$script:AllUsersModulePath = $env:PSModulePath.split(';') | Where-Object { $_ -notlike "$(Split-Path $PROFILE -Parent)*" -and $_ -notlike "$($HOME)*" }

if (Test-Path -Path $script:ModuleTempPath) {
    Get-ChildItem -Path $script:ModuleTempPath | Where-Object LastWriteTime -lt (Get-Date).AddHours(-2) | Remove-Item -Force -Confirm:$false
} else {
    New-Item -Path $script:ModuleTempPath -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path -Path $script:ModuleSettingPath)) {
    Write-Verbose -Message "Going to initialize default settings for module PackageUpdateInfo"
    Set-PackageUpdateSetting -Reset -Path $script:ModuleSettingPath
}
