function Assert-PossibleReleaseNotesURI {
    <#
    .SYNOPSIS
        Assert-PossibleReleaseNotesURI

    .DESCRIPTION
        Check if URI is a URI that can be covered for plain text release notes

    .PARAMETER URI
        The URI to check

    .EXAMPLE
        PS C:\> Assert-PossibleReleaseNotesURI -URI 'https://github.com/AndiBellstedt/PackageUpdateInfo/blob/master/PackageUpdateInfo/changelog.md'

        Check if URI is a URI that can be covered for plain text release notes
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [string]
        $URI
    )

    if($URI -like "https://github.com*" -or $URI -like "https://raw.githubusercontent.com*" -or $URI -like "https://gitlab.com*") {
        $true
    } else {
        $false
    }
}