function Add-PackageUpdateRule {
    <#
    .SYNOPSIS
        Add rule for checking and reporting on installed modules

    .DESCRIPTION
        This command allows to declare how a modules is handled in reporting for special.

        For example, you can configure PackageUpdateINfo to suppress revision updates on a frequent
        updated module, so that only build, minor or major updates are reportet as "update needed".

    .PARAMETER Id
        The Id as an identifier for the rule

    .PARAMETER ExcludeModuleFromChecking
        ModuleNames to exclude from update checking

    .PARAMETER IncludeModuleForChecking
        ModuleNames to include from update checking
        By default all modules are included.

        Default value is: "*"

    .PARAMETER ReportChangeOnMajor
        Report when major version changed for a module

        This means 'Get-PackageUpdateSetting' report update need,
        only when the major version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        1      0      0     0

    .PARAMETER ReportChangeOnMinor
        Report when minor version changed for a module

        This means 'Get-PackageUpdateSetting' report update need,
        only when the minor version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      1      0     0

    .PARAMETER ReportChangeOnBuild
        Report when build version changed for a module

        This means 'Get-PackageUpdateSetting' report update need,
        when the build version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      0      1     0

    .PARAMETER ReportChangeOnRevision
        Report when revision part changed for a module

        This means 'Get-PackageUpdateSetting' report update need,
        when the revision version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        1      0      0     0

    .PARAMETER SettingObject
        Settings object parsed in from command Get-PackageUpdateSetting
        This is an optional parameter. By default it will use the default
        settings object from the module.

    .PARAMETER PassThru
        The rule object will be parsed to the pipeline for further processing

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
        PS C:\> Add-PackageUpdateRule -IncludeModuleForChecking "MyModule" -ReportChangeOnMajor $true -ReportChangeOnMinor $true -ReportChangeOnBuild $true -ReportChangeOnRevision $false

        Add a new custom rule for "MyModule" to supress notifications on revision updates of the module

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

    begin {
    }

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

        if($PassThru) {
            [PackageUpdate.ModuleRule]$rule
        }
    }

    end {
    }
}
