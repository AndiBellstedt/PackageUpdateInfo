function Remove-PackageUpdateRule {
    <#
    .SYNOPSIS
        remove rule(s) for checking and reporting on installed modules

    .DESCRIPTION
        This command remove existing custom rule(s) on how a modules is handled in reporting.

    .PARAMETER Id
        The Id of the rule to be removed

    .PARAMETER InputObject
        Settings object parsed in from command Get-PackageUpdateSetting
        This is an optional parameter

    .PARAMETER Force
        If specified the user will not prompted on confirmation.

    .PARAMETER PassThru
        The rule object will be parsed to the pipeline for further processing

    .PARAMETER SettingObject
        Settings object from command Get-PackageUpdateSetting
        This is an optional parameter. By default it will use the default
        settings object from the module.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
        PS C:\> Get-PackageUpdateRule | Remove-PackageUpdateRule

        Remove all custom rules for module update handling.

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High', DefaultParameterSetName = "ById")]
    [Alias('rpur')]
    [OutputType([PackageUpdate.ModuleRule])]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ById")]
        [ValidateRange(1, [int]::MaxValue)]
        [int[]]
        $Id,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ByInputObject")]
        [PackageUpdate.ModuleRule[]]
        $InputObject,

        [switch]
        $Force,

        [switch]
        $PassThru,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [PackageUpdate.Configuration]
        $SettingObject
    )

    begin {
    }

    process {
        # If no setting object is piped in, get the current settings
        if (-not $SettingObject) { $SettingObject = Get-PackageUpdateSetting }

        # Find the rule by Id
        if ($id) { $InputObject = Get-PackageUpdateRule -Id $id }

        # Remove the rule(s) from the setting object
        foreach ($rule in $InputObject) {
            Write-Verbose -Message "Remove rule Id $($rule.Id)"
            $SettingObject.CustomRule = $SettingObject.CustomRule | Where-Object Id -ne $rule.id
        }

        # Write back the configuration object
        if ($Force) { $doAction = $true } else { $doAction = $pscmdlet.ShouldProcess("Rule Id $([string]::Join(", ", $rule.id))", "Remove from PackUpdateSetting object ($($SettingObject.Path))") }
        if ($doAction) {
            $SettingObject | ConvertFrom-PackageUpdateSetting | ConvertTo-Json | Out-File -FilePath $SettingObject.Path -Encoding default -Force
        }

        # Output the object if PassThru is specified
        if ($PassThru) { $InputObject }
    }

    end {
    }
}
