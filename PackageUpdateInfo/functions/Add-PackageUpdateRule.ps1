function Add-PackageUpdateRule {
    <#
    .SYNOPSIS
        Adds a custom rule that controls how module updates are reported.

    .DESCRIPTION
        This command creates a custom update rule for the current PackageUpdateInfo configuration.
        Each rule defines when an update should be considered relevant for reporting based on changes in the major, minor, build, or revision portion of a module version.
        Rules can also scope reporting to specific modules by including or excluding module names, which makes it possible to suppress noisy revision-only updates or focus checks on selected modules.
        If no settings object is provided, the command uses the current module configuration and stores the new rule there.

    .PARAMETER Id
        The unique identifier for the rule.

    .PARAMETER ExcludeModuleFromChecking
        One or more module names that should be excluded from update checking by this rule.

    .PARAMETER IncludeModuleForChecking
        One or more module names that should be included in update checking by this rule.
        If omitted, the rule applies to all modules.

    .PARAMETER ReportChangeOnMajor
        Indicates whether a change in the major version part should trigger an update report.

        This means 'Get-PackageUpdateSetting' will report an update only when the major version of a module changes.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        1      0      0     0

    .PARAMETER ReportChangeOnMinor
        Indicates whether a change in the minor version part should trigger an update report.

        This means 'Get-PackageUpdateSetting' will report an update only when the minor version of a module changes.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      1      0     0

    .PARAMETER ReportChangeOnBuild
        Indicates whether a change in the build version part should trigger an update report.

        This means 'Get-PackageUpdateSetting' will report an update only when the build version of a module changes.
        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      0      1     0

    .PARAMETER ReportChangeOnRevision
        Indicates whether a change in the revision version part should trigger an update report.

        This means 'Get-PackageUpdateSetting' report update need, when the revision version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        1      0      0     0

    .PARAMETER SettingObject
        A settings object from Get-PackageUpdateSetting that should receive the new rule.
        If omitted, the current module settings are used.

    .PARAMETER PassThru
        Returns the created rule object from the pipeline.

    .PARAMETER WhatIf
        Displays what would happen if the command were to run without changing any configuration.

    .PARAMETER Confirm
        Prompts for confirmation before saving the new rule.

    .EXAMPLE
        PS C:\> Add-PackageUpdateRule -IncludeModuleForChecking "MyModule" -ReportChangeOnMajor $true -ReportChangeOnMinor $true -ReportChangeOnBuild $true -ReportChangeOnRevision $false

        Adds a rule that reports major, minor, and build updates for MyModule while suppressing revision-only changes.

    .EXAMPLE
        PS C:\> Add-PackageUpdateRule -ExcludeModuleFromChecking "PowerShellGet","PSScriptAnalyzer" -ReportChangeOnRevision $false

        Adds a rule that excludes two modules from update checking and suppresses revision updates for the remaining modules.

    .EXAMPLE
        PS C:\> Add-PackageUpdateRule -Id 99 -IncludeModuleForChecking "MyModule" -PassThru

        Adds a rule with a specific identifier and returns the created rule object.

    .EXAMPLE
        PS C:\> $settings = Get-PackageUpdateSetting; Add-PackageUpdateRule -SettingObject $settings -ExcludeModuleFromChecking "MyModule"

        Adds a rule to an existing settings object without using the default module configuration.

    .NOTES
        Version   : 1.1.0.0
        Author    : Andi Bellstedt
        Date      : 2026-06-21
        Keywords  : PackageUpdateInfo, Update, Module, Rule

    .LINK
        https://packageupdateinfo.andibellstedt.com/docs/commands/add-packageupdaterule/

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [Alias('apur')]
    [OutputType([PackageUpdate.ModuleRule])]
    Param (
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Id,

        [Alias("Include", "IncludeModule")]
        [String[]]
        $IncludeModuleForChecking,

        [Alias("Exclude", "ExcludeModule")]
        [AllowEmptyString()]
        [String[]]
        $ExcludeModuleFromChecking,

        [bool]
        $ReportChangeOnMajor = $true,

        [bool]
        $ReportChangeOnMinor = $true,

        [bool]
        $ReportChangeOnBuild = $true,

        [bool]
        $ReportChangeOnRevision = $true,

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

        if ($Id) {
            if ($Id -in $SettingObject.CustomRule.Id) {
                Write-Error -Message "Unable to add rule with Id $($Id), because a rule with this Id already exist." -ErrorAction Stop
            }
        }

        if ($ExcludeModuleFromChecking) {
            foreach ($item in $SettingObject.CustomRule) {
                foreach ($toExclude in $ExcludeModuleFromChecking) {
                    if ($toExclude -in $item.ExcludeModuleFromChecking) {
                        Write-Error -Message "Unable to add rule with exclude module '$($toExclude)', because a rule with this module as excluded module already exist." -ErrorAction Stop
                    }
                }
            }
        }

        if ($IncludeModuleForChecking) {
            foreach ($item in $SettingObject.CustomRule) {
                foreach ($toInclude in $IncludeModuleForChecking) {
                    if ($toInclude -in $item.IncludeModuleForChecking) {
                        Write-Error -Message "Unable to add rule with include module '$($toInclude)', because a rule with this module to include already exist." -ErrorAction Stop
                    }
                }
            }
        }

        $rule = [PackageUpdate.ModuleRule]::new()

        # Set the rule properties values
        if ("Id" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
            Write-Verbose "Setting Id: '$($Id)'"
            $rule.Id = $Id
        } else {
            $Id = ($SettingObject.CustomRule.Id | Sort-Object | Select-Object -Last 1) + 1
            Write-Verbose "Setting Id: '$($Id)'"
            $rule.Id = $Id
        }

        if ("ExcludeModuleFromChecking" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
            Write-Verbose "Setting ExcludeModuleFromChecking: '$([string]::Join(", ", $ExcludeModuleFromChecking))'"
            $rule.ExcludeModuleFromChecking = $ExcludeModuleFromChecking
        }
        if ("IncludeModuleForChecking" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) {
            Write-Verbose "Setting IncludeModuleForChecking: '$([string]::Join(", ", $IncludeModuleForChecking))'"
            $rule.IncludeModuleForChecking = $IncludeModuleForChecking
        }

        if ("ReportChangeOnMajor" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) { Write-Verbose "Setting ReportChangeOnMajor: $($ReportChangeOnMajor)" }
        $rule.ReportChangeOnMajor = $ReportChangeOnMajor

        if ("ReportChangeOnMinor" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) { Write-Verbose "Setting ReportChangeOnMinor: $($ReportChangeOnMinor)" }
        $rule.ReportChangeOnMinor = $ReportChangeOnMinor

        if ("ReportChangeOnBuild" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) { Write-Verbose "Setting ReportChangeOnBuild: $($ReportChangeOnBuild)" }
        $rule.ReportChangeOnBuild = $ReportChangeOnBuild

        if ("ReportChangeOnRevision" -in $PSCmdlet.MyInvocation.BoundParameters.Keys) { Write-Verbose "Setting ReportChangeOnRevision: $($ReportChangeOnRevision)" }
        $rule.ReportChangeOnRevision = $ReportChangeOnRevision

        $SettingObject.CustomRule += $rule

        if ($pscmdlet.ShouldProcess($SettingObject.Path, "Add custom ModuleRule")) {
            $SettingObject | ConvertFrom-PackageUpdateSetting | ConvertTo-Json | Out-File -FilePath $SettingObject.Path -Encoding default -Force
        }

        if ($PassThru) {
            [PackageUpdate.ModuleRule]$rule
        }

    }

    end {}
}
