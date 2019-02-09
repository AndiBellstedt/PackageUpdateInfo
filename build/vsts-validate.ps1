# Guide for available variables and working with secrets:
# https://docs.microsoft.com/en-us/vsts/build-release/concepts/definitions/build/variables?tabs=powershell

# Needs to ensure things are Done Right and only legal commits to master get built
Find-Module -Name BurnToast -MinimumVersion '0.6.3' -IncludeDependencies -Confirm:$false | Install-Module -Scope CurrentUser -Force -Confirm:$false

# Run internal pester tests
& "$PSScriptRoot\..\PackageUpdateInfo\tests\pester.ps1"