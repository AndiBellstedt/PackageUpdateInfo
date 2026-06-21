function Get-PackageUpdateRule {
    <#
    .SYNOPSIS
        Retrieve one or more package update rules used to control module update checks and reporting.

    .DESCRIPTION
        Retrieves the custom rules that define how modules are handled during update checks and reporting.
        You can filter rules by identifier, by module inclusion or exclusion patterns, or include the default rule
        from the active settings object to compare custom behavior with the built-in fallback behavior.

    .PARAMETER Id
        Specifies one or more rule identifiers to retrieve.

    .PARAMETER ExcludeModuleFromChecking
        Filters the returned rules to those that exclude the specified module name from update checking.

    .PARAMETER IncludeModuleForChecking
        Filters the returned rules to those that include the specified module name for update checking.
        By default, all modules are included when no filter is supplied.

        Default value is: "*"

    .PARAMETER IncludeDefaultRule
        Adds the default rule from the supplied or active settings object to the output in addition to any custom rules.

    .PARAMETER SettingObject
        Specifies a settings object returned by Get-PackageUpdateSetting.
        If this parameter is omitted, the command uses the current module settings object.

    .EXAMPLE
        PS C:\> Get-PackageUpdateRule

        Retrieve all custom rules currently configured for package update handling.

    .EXAMPLE
        PS C:\> Get-PackageUpdateRule -Id 1, 2

        Retrieve the custom rules that have the specified identifiers.

    .EXAMPLE
        PS C:\> Get-PackageUpdateRule -ExcludeModuleFromChecking 'Pester'

        Retrieve the custom rules that exclude Pester from update checking.

    .EXAMPLE
        PS C:\> Get-PackageUpdateRule -IncludeModuleForChecking 'PackageManagement' -IncludeDefaultRule

        Retrieve the custom rules that include PackageManagement for update checking and also return the default rule.

    .NOTES
        Version  : 1.1.0.0
        Author   : Andi Bellstedt
        Date     : 2026-06-21
        Keywords : PackageUpdateInfo, Update, Module, Rule

    .LINK
        https://packageupdateinfo.andibellstedt.com/docs/commands/get-packageupdaterule/

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

    begin {}

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

    end {}

}
