function Get-VersionDifference {
    <#
    .SYNOPSIS
        Get-VersionDifference

    .DESCRIPTION
        Subtracts two version objects from each other to get the difference

    .PARAMETER LowerVersion
        The module info from the local existing version

    .PARAMETER HigherVersion
        The module info from the online existing version

    .EXAMPLE
        PS C:\> Get-VersionDifference -LowerVersion "1.0.0.0" -HigherVersion "1.1.2.3"

        Return 0.1.2.3 as difference between the both versions
    #>
    [CmdletBinding()]
    [OutputType([version])]
    param (
        [version]
        $LowerVersion,

        [version]
        $HigherVersion
    )

    $versionDiffMajor = $HigherVersion.Major - $LowerVersion.Major
    $versionDiffMinor = $HigherVersion.Minor - $LowerVersion.Minor
    $versionDiffBuild = $HigherVersion.Build - $LowerVersion.Build
    $versionDiffRevision = $HigherVersion.Revision - $LowerVersion.Revision

    if ($versionDiffMajor -lt 0) { $versionDiffMajor = 0 }
    if ($versionDiffMinor -lt 0) { $versionDiffMinor = 0 }
    if ($versionDiffBuild -lt 0) { $versionDiffBuild = 0 }
    if ($versionDiffRevision -lt 0) { $versionDiffRevision = 0 }

    $versionDiff = [version]::new($versionDiffMajor, $versionDiffMinor, $versionDiffBuild, $versionDiffRevision)

    $versionDiff
}