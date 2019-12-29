function Test-UpdateIsNeeded {
    <#
    .SYNOPSIS
        Test-UpdateIsNeeded

    .DESCRIPTION
        Command to test if a module version update appears as "update needed".
        If "needed" depends on the set rules and report-on-different-version parts.

    .PARAMETER ModuleLocal
        The module info from the local existing version

    .PARAMETER ModuleOnline
        The module info from the online existing version

    .EXAMPLE
        PS C:\> Test-UpdateIsNeeded -ModuleLocal $moduleLocal -ModuleOnline $moduleOnline

        Check if URI is a URI that can be covered for plain text release notes
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        $ModuleLocal,

        $moduleOnline
    )

    <#
    $ModuleLocal = (Get-Module Pester -ListAvailable | select -First 1 )
    $moduleOnline = (Find-Module -Name Pester)
    #>
    $versionDiff = Get-VersionDifference -LowerVersion $ModuleLocal.Version -HigherVersion $moduleOnline.Version
    $name = $ModuleLocal.Name

    $rules = Get-PackageUpdateRule -IncludeDefaultRule | Sort-Object -Property Id -Descending

    foreach ($rule in $rules) {
        Write-Verbose -Message "Working on rule $($rule.Id)"
        $stop = $false
        # check for exclude and abort further processing for rule
        foreach ($exclude in $rule.ExcludeModuleFromChecking) {
            if ($name -like $exclude) {
                $stop = $true
                Write-Verbose -Message "Rule $($rule.Id) does match exclude pattern ($([string]::Join(", ", $rule.ExcludeModuleFromChecking))) for module $($name)"
            }
        }
        if ($stop) { continue }

        $stop = $true
        # check for inclue to declare, the rule fits for processing
        foreach ($include in $rule.IncludeModuleForChecking) {
            if ($name -like $include) {
                $stop = $false
                Write-Verbose -Message "Rule $($rule.Id) does match include pattern ($([string]::Join(", ", $rule.IncludeModuleForChecking))) for module $($name)"
            }
        }
        if ($stop) { continue }

        # Version checking and return boolean
        $higherChange = $false
        if ([bool]$versionDiff.Major) {
            if ($rule.ReportChangeOnMajor) {
                Write-Verbose -Message "Major version change in module $($name) found. (Diff: $($versionDiff))"
                return $true
            } else { $higherChange = $true }
        }
        if ([bool]$versionDiff.Minor) {
            if ($rule.ReportChangeOnMinor -and (-not $higherChange)) {
                Write-Verbose -Message "Minor version change in module $($name) found. (Diff: $($versionDiff))"
                return $true
            } else { $higherChange = $true }
        }
        if ([bool]$versionDiff.Build) {
            if ($rule.ReportChangeOnBuild -and (-not $higherChange)) {
                Write-Verbose -Message "Build version change in module $($name) found. (Diff: $($versionDiff))"
                return $true
            } else { $higherChange = $true }
        }
        if ([bool]$versionDiff.Revision) {
            if ($rule.ReportChangeOnRevision -and (-not $higherChange)) {
                Write-Verbose -Message "Revision version change in module $($name) found. (Diff: $($versionDiff))"
                return $true
            } else { $higherChange = $true }
        }

        # Arriving here means, the name filter apply and version change did not result in status for "report-update-needed"
        # Function return $false, due to there is an update present, but compairing to the defined rule(s), reporting on the version change is suppressed
        return $false
    }
}