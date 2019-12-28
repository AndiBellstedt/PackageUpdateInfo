function ConvertFrom-PackageUpdateSetting {
    <#
    .SYNOPSIS
        ConvertFrom-PackageUpdateSetting

    .DESCRIPTION
        Convert from a PackageUpdateSetting object to a PSCustomObject

    .PARAMETER InputObject
        The PackageUpdateSetting object to convert

    .EXAMPLE
        PS C:\> ConvertFrom-PackageUpdateSetting -InputObject (Get-PackageUpdateSetting)

        Check if URI is a URI that can be covered for plain text release notes
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SetBehaviour")]
        [PackageUpdate.Configuration]
        $InputObject,

        [switch]
        $AsHashTable
    )

    begin {
    }

    process {
        $hash = [ordered]@{}

        $notToString = @("System.Boolean", "System.String[]", "System.Int*")
        foreach($property in $InputObject.psobject.Properties) {
            if($property.TypeNameOfValue -in $notToString) {
                $hash[$property.Name] = $property.Value
            } else {
                $hash[$property.Name] = [String]($property.Value)
            }
        }

        if($AsHashTable) {
            $hash
        } else {
            [PSCustomObject]$hash
        }
    }

    end {
    }
}