# Guide for available variables and working with secrets:
# https://docs.microsoft.com/en-us/vsts/build-release/concepts/definitions/build/variables?tabs=powershell

# Needs to ensure things are Done Right and only legal commits to master get built

# Check requirements for other modules and install them first
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
$requiredModules = (Import-PowerShellDataFile -Path "$PSScriptRoot\..\PackageUpdateInfo\PackageUpdateInfo.psd1").RequiredModules
foreach ($requiredModule in $requiredModules) {
    $moduleParams = @{
        Name = $requiredModule['ModuleName']
    }
    if($requiredModule['RequiredVersion']) {
        $moduleParams.Add("RequiredVersion",$requiredModule['RequiredVersion'])
        Write-Host "Install required module: $($requiredModule['ModuleName']) (RequiredVersion: v$($requiredModule['RequiredVersion']))"
    } else {
        $moduleParams.Add("MinimumVersion",$requiredModule['ModuleVersion'])
        Write-Host "Install required module: $($requiredModule['ModuleName']) (MinimumVersion: v$($requiredModule['ModuleVersion']))"
    }
    Find-Module @moduleParams | Install-Module -Scope CurrentUser -Force -Confirm:$false
}

# Run internal pester tests
& "$PSScriptRoot\..\PackageUpdateInfo\tests\pester.ps1"