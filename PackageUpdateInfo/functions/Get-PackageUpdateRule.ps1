function Get-PackageUpdateRule {
    <#
    .SYNOPSIS
        Get rule(s) for checking and reporting on installed modules

    .DESCRIPTION
        This command get the existing custom rule(s) how modules are handled in reporting.

    .PARAMETER Id
        The Id as an identifier for the rule

    .PARAMETER ExcludeModuleFromChecking
        ModuleNames to exclude from update checking

    .PARAMETER IncludeModuleForChecking
        ModuleNames to include from update checking
        By default all modules are included.

        Default value is: "*"

    .PARAMETER IncludeDefaultRule
        Outputs the DefautRule from the setting object, in addition to the customrules

    .PARAMETER SettingObject
        Settings object parsed in from command Get-PackageUpdateSetting
        This is an optional parameter. By default it will use the default
        settings object from the module.

    .EXAMPLE
        PS C:\> Get-PackageUpdateRule

        Get all the existing custom rules

    .EXAMPLE
        PS C:\> Get-PackageUpdateRule -Id 1

        Get all the custom rule with Id 1

    #>
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low', DefaultParameterSetName = "ShowAll")]
    [Alias('gpur')]
    [OutputType([PackageUpdate.ModuleRule])]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ById")]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]
        $Id,

        [Parameter(ParameterSetName = "ShowAll")]
        [Alias("Include", "IncludeModule")]
        [String]
        $IncludeModuleForChecking,

        [Parameter(ParameterSetName = "ShowAll")]
        [Alias("Exclude", "ExcludeModule")]
        [String]
        $ExcludeModuleFromChecking,

        [Parameter(ParameterSetName = "ShowAll")]
        [switch]
        $IncludeDefaultRule,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [PackageUpdate.Configuration]
        $SettingObject
    )

    begin {
    }

    process {
        # If no setting object is piped in, get the current settings
        if (-not $SettingObject) { $SettingObject = Get-PackageUpdateSetting }

        $output = @()

        if ($Id) {
            $output += $SettingObject.CustomRule | Where-Object Id -in $Id | Sort-Object -Property Id
        } else {
            if ("ExcludeModuleFromChecking" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                $output += $SettingObject.CustomRule | Where-Object ExcludeModuleFromChecking -like $ExcludeModuleFromChecking | Sort-Object -Property Id
            } elseif ("IncludeModuleForChecking" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                $output += $SettingObject.CustomRule | Where-Object IncludeModuleForChecking -like $IncludeModuleForChecking | Sort-Object -Property Id
            } else {
                $output += $SettingObject.CustomRule | Sort-Object -Property Id
            }
        }

        if ($IncludeDefaultRule) {
            $output += $SettingObject.DefaultRule
        }

        $output
    }

    end {
    }
}
