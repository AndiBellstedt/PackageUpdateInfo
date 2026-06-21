function Test-UpdateIsNeeded {
    <#
    .SYNOPSIS
        Function to test if a module version update appears as "update needed".

    .DESCRIPTION
        This function takes the local and online module info and checks if the online version is higher than the local version.
        The function uses the defined rules to check if the version difference should be reported as "update needed".
        The rules can include or exclude modules based on their name and define which version changes (major, minor, build, revision)
        should be reported as "update needed". If a module is excluded by a rule, it will not be considered for update checking.
        If a module is included by a rule, the function checks the version difference against the rule's settings to determine
        if an update is needed. The function returns $true if an update is needed according to the rules, and $false otherwise.

    .PARAMETER ModuleLocal
        The module info from the local existing version

    .PARAMETER ModuleOnline
        The module info from the online existing version

    .OUTPUTS
        [bool] - $true if an update is needed according to the defined rules, $false otherwise.

    .EXAMPLE
        PS C:\> Test-UpdateIsNeeded -ModuleLocal $moduleLocal -ModuleOnline $moduleOnline

        Check if an update is needed based on the defined rules and version differences

    .NOTES
        Version  : 1.0.0.0
        Author   : Andreas Bellstedt
        Date     : 2019-12-29
        Keywords : PackageUpdateInfo, UpdateCheck, VersionDifference

    .LINK
        https://github.com/AndiBellstedt/PackageUpdateInfo

    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        $ModuleLocal,

        $moduleOnline
    )

    $versionDiff = Get-VersionDifference -LowerVersion $ModuleLocal.Version -HigherVersion $moduleOnline.Version
    $name = $ModuleLocal.Name

    $rules = Get-PackageUpdateRule -IncludeDefaultRule | Sort-Object -Property Id -Descending

    foreach ($rule in $rules) {

        Write-Verbose -Message "Working on rule $($rule.Id)"
        $stop = $false

        # Check for exclude and abort further processing for rule, if the rule does not fit for processing
        foreach ($exclude in $rule.ExcludeModuleFromChecking) {
            if ($name -like $exclude) {
                $stop = $true
                Write-Verbose -Message "Rule $($rule.Id) does match exclude pattern ($([string]::Join(", ", $rule.ExcludeModuleFromChecking))) for module $($name)"
            }
        }
        if ($stop) { continue }

        $stop = $true
        # Check for include to declare, the rule fits for processing
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
        # Function return $false, due to there is an update present, but comparing to the defined rule(s), reporting on the version change is suppressed
        return $false

    }

}