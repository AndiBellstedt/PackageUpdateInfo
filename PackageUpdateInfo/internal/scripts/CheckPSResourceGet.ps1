#region -- Check for Microsoft.PowerShell.PSResourceGet module, to enable support for PowerShellGet v3

if (Get-Command -Name Install-PSResource -ErrorAction SilentlyContinue) {
    Write-Verbose "Microsoft.PowerShell.PSResourceGet module is available. Will use Find-PSResource instead of Find-Module."
    $script:UsePSResourceGet = $true
} else {
    Write-Warning "Only PowerShellGet v2 is available. PackageUpdateInfo will use Find-Module to detect updates. Consider installing Microsoft.PowerShell.PSResourceGet module to enable support for PowerShellGet v3 and use Find-PSResource in the future."
    $script:UsePSResourceGet = $false
}

#endregion Check for Microsoft.PowerShell.PSResourceGet module, to enable support for PowerShellGet v3