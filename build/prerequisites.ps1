[CmdletBinding()]
param (
    [string]
    $Repository = 'PSGallery',

    [string[]]
    $OptionalModules = @("BurntToast")
)


# All modules that are required for test- or build-processes.
$modules = @(
    'Pester' # Testing Framework
    'PSScriptAnalyzer' # Best Practices Analyzer used during tests
    #'PSModuleDevelopment' # Potentially used in Tests or Publish
    #'Microsoft.PowerShell.PlatyPS' # Generate docs from help
)


# Add optional modules specified in CI/CD pipelines or local runs.
$modules = $modules + $OptionalModules


# Automatically add missing dependencies
$data = Import-PowerShellDataFile -Path (Resolve-Path (Join-Path -Path $PSScriptRoot -ChildPath "..\PackageUpdateInfo\PackageUpdateInfo.psd1")).Path
foreach ($dependency in $data.RequiredModules) {
    if ($dependency -is [string]) {
        if ($modules -contains $dependency) { continue }
        $modules += $dependency
    } else {
        if ($modules -contains $dependency.ModuleName) { continue }
        $modules += $dependency.ModuleName
    }
}

<# Intentionall not using PSFramework.NuGet cause it is causing problems on linux
Invoke-WebRequest 'https://raw.githubusercontent.com/PowershellFrameworkCollective/PSFramework.NuGet/refs/heads/master/bootstrap.ps1' -UseBasicParsing | Invoke-Expression
Install-PSFPowerShellGet

Install-PSFModule -Name $modules -Repository $Repository -TrustRepository
#>
foreach ($moduleRequired in $modules) {
    # Install the required modules if they are not already present.
    if (-not (Get-Module -ListAvailable -Name $moduleRequired -ErrorAction SilentlyContinue)) {
        if (Get-Command -Name Install-PSResource -ErrorAction SilentlyContinue) {
            Install-PSResource -Name $moduleRequired -Scope CurrentUser -TrustRepository -Quiet -AcceptLicense #-AuthenticodeCheck:$false
        } else {
            Install-Module -Name $moduleRequired -Scope CurrentUser -Force -SkipPublisherCheck -AcceptLicense
        }
    }
}
