function Remove-PackageUpdateRule {
    <#
    .SYNOPSIS
        Removes one or more custom update-handling rules from the package update configuration.

    .DESCRIPTION
        Removes existing custom rules that define how specific PowerShell modules should be handled during update checks and reporting.
        The command can remove rules by rule Id, by piping in rule objects from Get-PackageUpdateRule,
        or by updating a settings object that contains the rule collection.

        When rules are removed, the updated configuration is written back to the settings file so the change persists.
        Use -PassThru to return the removed rule objects to the pipeline.

    .PARAMETER Id
        The Id of the rule to remove. Accepts one or more rule identifiers.

    .PARAMETER InputObject
        One or more rule objects to remove. These are typically returned by Get-PackageUpdateRule.

    .PARAMETER Force
        Suppresses the confirmation prompt and removes the rule immediately.

    .PARAMETER PassThru
        Returns the removed rule object(s) to the pipeline for further processing.

    .PARAMETER SettingObject
        The configuration object that contains the rule collection.
        If this parameter is not supplied, the command uses the current module settings from Get-PackageUpdateSetting.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
        PS C:\> Get-PackageUpdateRule | Remove-PackageUpdateRule

        Removes all custom update rules from the current module settings.

    .EXAMPLE
        PS C:\> Remove-PackageUpdateRule -Id 12

        Removes the custom rule with Id 12 from the current configuration.

    .EXAMPLE
        PS C:\> $rules = Get-PackageUpdateRule -Name "Microsoft.PowerShell.Utility"
        PS C:\> $rules | Remove-PackageUpdateRule -PassThru

        Removes the matching rules and returns the removed rule objects to the pipeline.

    .EXAMPLE
        PS C:\> $settings = Get-PackageUpdateSetting
        PS C:\> Remove-PackageUpdateRule -Id 3 -SettingObject $settings -Force

        Removes a specific rule without prompting and writes the updated settings back to disk.

    .NOTES
        Version  : 1.1.0.0
        Author   : Andi Bellstedt
        Date     : 2026-06-21
        Keywords : PackageUpdateInfo, Update, Module, Rule

    .LINK
        https://packageupdateinfo.andibellstedt.com/docs/commands/remove-packageupdaterule/

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

    begin {}

    process {

        # If no setting object is piped in, get the current settings
        if (-not $SettingObject) { $SettingObject = Get-PackageUpdateSetting }

        # Find the rule by Id
        if ($id) { $InputObject = Get-PackageUpdateRule -Id $id -SettingObject $SettingObject }

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

    end {}

}
