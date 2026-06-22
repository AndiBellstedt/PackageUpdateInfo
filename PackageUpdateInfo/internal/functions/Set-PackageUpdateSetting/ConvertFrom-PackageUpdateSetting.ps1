function ConvertFrom-PackageUpdateSetting {
    <#
    .SYNOPSIS
        Convert from a PackageUpdateSetting object to a PSCustomObject

    .DESCRIPTION
        This function takes a PackageUpdateSetting object and converts it to a PSCustomObject or hashtable.
        The function iterates through the properties of the input object and adds them to a new ordered hashtable.
        For certain types of properties (boolean, string array, int, ModuleRule, ModuleRule array), the value is added to the hashtable without converting it to a string.
        For other types of properties, the value is converted to a string before being added to the hashtable.
        The resulting hashtable can be returned as a PSCustomObject or as an ordered hashtable based on the AsHashTable switch.

    .PARAMETER InputObject
        The PackageUpdateSetting object to convert

    .PARAMETER AsHashTable
        Output is done as hashtable, not as PSObject

    .EXAMPLE
        PS C:\> ConvertFrom-PackageUpdateSetting -InputObject (Get-PackageUpdateSetting)

        Convert a PackageUpdateSetting object to a PSCustomObject or hashtable

    .OUTPUTS
        [System.Collections.Specialized.OrderedDictionary] - The resulting hashtable or PSCustomObject with the properties of the input object.

    .NOTES
        Version  : 1.0.0.0
        Author   : Andreas Bellstedt
        Date     : 2019-12-28
        Keywords : PackageUpdateInfo, ConvertFrom, PackageUpdateSetting

    .LINK
        https://github.com/AndiBellstedt/PackageUpdateInfo

    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SetBehaviour")]
        [PackageUpdate.Configuration]
        $InputObject,

        [switch]
        $AsHashTable
    )

    begin {}

    process {

        $hash = [ordered]@{ }

        $notToString = @("System.Boolean", "System.String[]", "System.Int", "PackageUpdate.ModuleRule", "PackageUpdate.ModuleRule[]")
        foreach ($property in $InputObject.psobject.Properties) {
            if ($property.TypeNameOfValue -in $notToString) {
                $hash[$property.Name] = $property.Value
            } else {
                $hash[$property.Name] = [String]($property.Value)
            }
        }

        if ($AsHashTable) {
            $hash
        } else {
            [PSCustomObject]$hash
        }

    }

    end {}

}