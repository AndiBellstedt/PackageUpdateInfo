function Get-VersionDifference {
    <#
    .SYNOPSIS
        Subtracts two version objects from each other to get the difference between them.

    .DESCRIPTION
        This function takes two version objects and calculates the difference between them for each
        version part (major, minor, build, revision). If the higher version has a smaller value for
        a version part than the lower version, the difference for that part is set to 0.
        The resulting version object represents the difference between the two versions.

    .PARAMETER LowerVersion
        The module info from the local existing version

    .PARAMETER HigherVersion
        The module info from the online existing version

    .OUTPUTS
        [version] - The difference between the two versions as a version object.

    .EXAMPLE
        PS C:\> Get-VersionDifference -LowerVersion "1.0.0.0" -HigherVersion "1.1.2.3"

        Returns 0.1.2.3 as the difference between the two versions

    .NOTES
        Version  : 1.0.0.0
        Author   : Andreas Bellstedt
        Date     : 2019-12-29
        Keywords : PackageUpdateInfo, Version, Difference

    .LINK
        https://github.com/AndiBellstedt/PackageUpdateInfo

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