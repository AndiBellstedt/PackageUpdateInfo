function ConvertTo-PackageUpdateSetting {
    <#
    .SYNOPSIS
        ConvertFrom-PackageUpdateSetting

    .DESCRIPTION
        Convert from a PackageUpdateSetting object to a PSCustomObject

    .PARAMETER InputObject
        PSCustomObject object to convert

    .EXAMPLE
        PS C:\> Get-PackageUpdateSetting | ConvertFrom-PackageUpdateSetting | ConvertTo-PackageUpdateSetting

        Check if URI is a URI that can be covered for plain text release notes
    #>
    [CmdletBinding()]
    [OutputType([PackageUpdate.Configuration])]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SetBehaviour")]
        [PSCustomObject]
        $InputObject
    )

    begin {
    }

    process {
        $hash = [ordered]@{}

        foreach($property in $InputObject.psobject.Properties) {
                $hash[$property.Name] = $property.Value
        }

        [PackageUpdate.Configuration]$hash
    }

    end {
    }
}