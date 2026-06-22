function Assert-PossibleReleaseNotesURI {
    <#
    .SYNOPSIS
        Check if URI is a URI that can be covered for plain text release notes

    .DESCRIPTION
        This function checks if the provided URI is a URI that can be covered for plain text release notes.
        It checks if the URI starts with "https://github.com", "https://raw.githubusercontent.com" or "https://gitlab.com".
        If the URI matches any of these patterns, the function returns $true, indicating that it is a possible URI for plain text release notes.
        Otherwise, it returns $false. This is used to determine if the release notes can be fetched as plain text from the URI.

    .PARAMETER URI
        The URI to check for being a possible URI for plain text release notes.

    .EXAMPLE
        PS C:\> Assert-PossibleReleaseNotesURI -URI 'https://github.com/AndiBellstedt/PackageUpdateInfo/blob/master/PackageUpdateInfo/changelog.md'

        Returns $true, indicating that the provided URI is a possible URI for plain text release notes.

    .OUTPUTS
        [bool] - $true if the URI is a possible URI for plain text release notes, otherwise $false.

    .NOTES
        Version  : 1.0.0.0
        Author   : Andreas Bellstedt
        Date     : 2019-12-27
        Keywords : PackageUpdateInfo, Assert, PossibleReleaseNotesURI

    .LINK
        https://github.com/AndiBellstedt/PackageUpdateInfo
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [string]
        $URI
    )

    if ($URI -like "https://github.com*" -or $URI -like "https://raw.githubusercontent.com*" -or $URI -like "https://gitlab.com*") {
        $true
    } else {
        $false
    }

}