function Set-PackageUpdateRule {
    <#
    .SYNOPSIS
        Updates an existing PackageUpdateInfo rule that controls how module version changes are reported.

    .DESCRIPTION
        This cmdlet modifies an existing update rule stored in the PackageUpdateInfo configuration so that update checks can be narrowed or expanded for specific modules.
        You can use it to include or exclude modules from update detection, control which version parts trigger an update report, and persist those rule changes back to the active settings file.
        The command works with a rule identified by Id or with a rule object supplied through InputObject, and it can return the updated rule when -PassThru is specified.

    .PARAMETER Id
        The numeric identifier of the rule to modify.

    .PARAMETER InputObject
        The rule object to update. This is useful when you already have a rule from Get-PackageUpdateRule and want to change it without referring to its Id.

    .PARAMETER ExcludeModuleFromChecking
        One or more module names that should be excluded from update checks for the rule being changed.

    .PARAMETER IncludeModuleForChecking
        One or more module names that should be included in update checks for the rule being changed. When omitted, the rule keeps the default behavior of evaluating all modules.

    .PARAMETER ReportChangeOnMajor
        Controls whether a change in the major version part causes the rule to report that an update is needed.

        Report when major version changed for a module

        This means 'Get-PackageUpdateSetting' report update need,
        only when the major version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        1      0      0     0

    .PARAMETER ReportChangeOnMinor
        Controls whether a change in the minor version part causes the rule to report that an update is needed.

        Report when minor version changed for a module

        This means 'Get-PackageUpdateSetting' report update need,
        only when the minor version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      1      0     0

    .PARAMETER ReportChangeOnBuild
        Controls whether a change in the build version part causes the rule to report that an update is needed.

        Report when build version changed for a module

        This means 'Get-PackageUpdateSetting' report update need,
        only when the build version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      0      1     0

    .PARAMETER ReportChangeOnRevision
        Controls whether a change in the revision version part causes the rule to report that an update is needed.

        Report when revision part changed for a module

        This means 'Get-PackageUpdateSetting' report update need,
        only when the revision version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      0      0      1

    .PARAMETER SettingObject
        The PackageUpdateInfo configuration object to update. When omitted, the cmdlet uses the current module settings from Get-PackageUpdateSetting.

    .PARAMETER PassThru
        Returns the updated rule object to the pipeline after the change has been written to the settings file.

    .PARAMETER WhatIf
        Shows what would happen if the command were to run without applying any changes.

    .PARAMETER Confirm
        Prompts for confirmation before the cmdlet writes changed rule data back to the settings file.

    .EXAMPLE
        PS C:\> Set-PackageUpdateRule -Id 3 -IncludeModuleForChecking 'MyModule' -ReportChangeOnMajor $true -ReportChangeOnMinor $true -ReportChangeOnBuild $true -ReportChangeOnRevision $false -PassThru

        Updates rule 3 so that MyModule is evaluated explicitly and only major, minor, and build changes are reported as update needs.

    .EXAMPLE
        PS C:\> Get-PackageUpdateRule -Id 7 | Set-PackageUpdateRule -ExcludeModuleFromChecking 'AzureTools' -ReportChangeOnRevision $false

        Takes the rule with Id 7 from the pipeline and suppresses revision-based update reporting for AzureTools while keeping the rule stored in the current settings.

    .EXAMPLE
        PS C:\> $rule = Get-PackageUpdateRule -Id 12
        PS C:\> Set-PackageUpdateRule -InputObject $rule -IncludeModuleForChecking 'PowershellGet','PSReadLine' -ReportChangeOnMinor $false -ReportChangeOnBuild $false

        Loads an existing rule object, expands the included modules, and updates the rule so that only major and revision changes are treated as actionable updates.

    .EXAMPLE
        PS C:\> Set-PackageUpdateRule -Id 5 -ReportChangeOnMajor $false -ReportChangeOnMinor $false -ReportChangeOnBuild $false -ReportChangeOnRevision $true -WhatIf

        Shows the effect of changing rule 5 to report only revision-based updates without actually writing the change to disk.

    .NOTES
        Version  : 1.1.0.0
        Author   : Andi Bellstedt
        Date     : 2026-06-21
        Keywords : PackageUpdateInfo, Update, Module, Rule

    .LINK
        https://packageupdateinfo.andibellstedt.com/docs/commands/set-packageupdaterule/

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium', DefaultParameterSetName = "ById")]
    [Alias('spur')]
    [OutputType([PackageUpdate.ModuleRule])]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ById")]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ByInputObject")]
        [PackageUpdate.ModuleRule[]]
        $InputObject,

        [Alias("Include", "IncludeModule")]
        [String[]]
        $IncludeModuleForChecking,

        [Alias("Exclude", "ExcludeModule")]
        [AllowEmptyString()]
        [String[]]
        $ExcludeModuleFromChecking,

        [bool]
        $ReportChangeOnMajor,

        [bool]
        $ReportChangeOnMinor,

        [bool]
        $ReportChangeOnBuild,

        [bool]
        $ReportChangeOnRevision,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [PackageUpdate.Configuration]
        $SettingObject,

        [switch]
        $PassThru
    )

    begin {}

    process {

        # If no setting object is piped in, get the current settings
        if (-not $SettingObject) { $SettingObject = Get-PackageUpdateSetting }

        # Find the rule by Id or take the piped in objectect to update
        if ($id) { $InputObject = Get-PackageUpdateRule -Id $id -SettingObject $SettingObject }

        # Work through all objects to update and set the new values
        foreach ($rule in $InputObject) {
            # Set the new preference values
            if ("ExcludeModuleFromChecking" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                Write-Verbose "Setting ExcludeModuleFromChecking: '$([string]::Join(", ", $ExcludeModuleFromChecking))'"
                $rule.ExcludeModuleFromChecking = $ExcludeModuleFromChecking
            }
            if ("IncludeModuleForChecking" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                Write-Verbose "Setting IncludeModuleForChecking: '$([string]::Join(", ", $IncludeModuleForChecking))'"
                $rule.IncludeModuleForChecking = $IncludeModuleForChecking
            }
            if ("ReportChangeOnMajor" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                Write-Verbose "Setting ReportChangeOnMajor: $($ReportChangeOnMajor)"
                $rule.ReportChangeOnMajor = $ReportChangeOnMajor
            }
            if ("ReportChangeOnMinor" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                Write-Verbose "Setting ReportChangeOnMinor: $($ReportChangeOnMinor)"
                $rule.ReportChangeOnMinor = $ReportChangeOnMinor
            }
            if ("ReportChangeOnBuild" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                Write-Verbose "Setting ReportChangeOnBuild: $($ReportChangeOnBuild)"
                $rule.ReportChangeOnBuild = $ReportChangeOnBuild
            }
            if ("ReportChangeOnRevision" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
                Write-Verbose "Setting ReportChangeOnRevision: $($ReportChangeOnRevision)"
                $rule.ReportChangeOnRevision = $ReportChangeOnRevision
            }

            # change rule and write back PackageUpdateSetting object
            if ($pscmdlet.ShouldProcess("Rule Id $($rule.id)", "Set properties from PackUpdateSetting object ($($SettingObject.Path))")) {
                $SettingObject.CustomRule = $SettingObject.CustomRule | Where-Object Id -ne $rule.Id | Sort-Object -Property Id
                $SettingObject.CustomRule += $rule
                $SettingObject.CustomRule = $SettingObject.CustomRule | Sort-Object -Property Id

                $SettingObject | ConvertFrom-PackageUpdateSetting | ConvertTo-Json | Out-File -FilePath $SettingObject.Path -Encoding default -Force
            }

            if ($PassThru) { $rule }
        }
    }

    end {}

}
