function ConvertTo-PackageUpdateSetting {
    <#
    .SYNOPSIS
        Convert from a PSCustomObject to a PackageUpdateSetting object

    .DESCRIPTION
        This function takes a PSCustomObject and converts it to a PackageUpdateSetting object.
        The function iterates through the properties of the input object and adds them to a new ordered hashtable.
        The resulting hashtable is then cast to a PackageUpdateSetting object.

    .PARAMETER InputObject
        PSCustomObject object to convert

    .EXAMPLE
        PS C:\> Get-PackageUpdateSetting | ConvertFrom-PackageUpdateSetting | ConvertTo-PackageUpdateSetting

        Check if URI is a URI that can be covered for plain text release notes

    .OUTPUTS
        [PackageUpdate.Configuration] - The resulting PackageUpdateSetting object with the properties of the input object.

    .NOTES
        Version  : 1.0.0.0
        Author   : Andreas Bellstedt
        Date     : 2019-12-28
        Keywords : PackageUpdateInfo, ConvertTo, PackageUpdateSetting

    .LINK
        https://github.com/AndiBellstedt/PackageUpdateInfo
    #>
    [CmdletBinding()]
    [OutputType([PackageUpdate.Configuration])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SetBehaviour")]
        [PSCustomObject]
        $InputObject
    )

    begin {}

    process {

        $hash = [ordered]@{ }

        foreach ($property in $InputObject.psobject.Properties) {
            $hash[$property.Name] = $property.Value
        }

        [PackageUpdate.Configuration]$hash

    }

    end {}
}