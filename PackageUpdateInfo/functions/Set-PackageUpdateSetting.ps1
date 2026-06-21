function Set-PackageUpdateSetting {
    <#
    .SYNOPSIS
        Configures update-check behavior and reporting preferences for PackageUpdateInfo.

    .DESCRIPTION
        Configures how PackageUpdateInfo evaluates installed PowerShell modules for available updates.
        Use this command to control which modules are included in or excluded from update checks,
        decide which version changes should trigger update notifications, define how often update checks are performed,
        and reset the stored settings to their defaults.
        The configuration is persisted to a JSON settings file and can be applied either directly or by passing an existing configuration object.

    .PARAMETER Path
        The full path to the settings file that should be read from or written to.

        If this parameter is omitted, the command uses the module's default settings path:
        Linux:   "$HOME/.config/powershell/PackageUpdateInfo/PackageUpdateSetting_$($PSEdition)_$($PSVersionTable.PSVersion.Major).json"
        Windows: "$HOME\AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateSetting_$($PSEdition)_$($PSVersionTable.PSVersion.Major).json"

    .PARAMETER InputObject
        A configuration object returned by Get-PackageUpdateSetting that should be updated in place.

    .PARAMETER ExcludeModuleFromChecking
        The names of modules to exclude from update checking in the default rule.

    .PARAMETER IncludeModuleForChecking
        The names of modules to include in update checking in the default rule.
        By default, all modules are included.

        Default value is: "*"

    .PARAMETER ReportChangeOnMajor
        Indicates whether a change in the major version of a module should trigger an update notification in the default rule.

        This means Get-PackageUpdateSetting reports an update need only when the major version number of a module changes.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        1      0      0     0

    .PARAMETER ReportChangeOnMinor
        Indicates whether a change in the minor version of a module should trigger an update notification in the default rule.

        This means Get-PackageUpdateSetting reports an update need only when the minor version number of a module changes.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      1      0     0

    .PARAMETER ReportChangeOnBuild
        Indicates whether a change in the build version of a module should trigger an update notification in the default rule.

        This means Get-PackageUpdateSetting reports an update need only when the build version number of a module changes.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      0      1     0

    .PARAMETER ReportChangeOnRevision
        Indicates whether a change in the revision part of a module version should trigger an update notification in the default rule.

        This means Get-PackageUpdateSetting reports an update need only when the revision number of a module changes.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        1      0      0     0

    .PARAMETER UpdateCheckInterval
        The minimum time span that must pass before a new module update check is performed.

        Default value is: "01:00:00"

    .PARAMETER LastCheck
        The timestamp when the last update-check cycle for modules started.

    .PARAMETER LastSuccessfulCheck
        The timestamp when the last update-check cycle completed successfully.

    .PARAMETER Reset
        Resets the module configuration to its default behavior.

    .PARAMETER PassThru
        Returns the updated settings object to the pipeline for further processing.

    .PARAMETER WhatIf
        Shows what would happen if the command were to run without actually performing any changes.

    .PARAMETER Confirm
        Prompts for confirmation before executing any operation that changes state.

    .EXAMPLE
        PS C:\> Set-PackageUpdateSetting -ExcludeModuleFromChecking "MyLocalOnlyModule"

        Put the module "MyLocalOnlyModule" on the exclude list for update checking.
        By design, this should be considered only for modules not available in a online gallery.
        This capability is designed to avoid unnecessary update checks, for modules not existing in a online gallery.

        You'll not get any update information for module 'MyLocalOnlyModule' anymore!

        If you have worries/issues on performance, due to a large number of modules installed, you better follow the practice to put the 'checking mechansim' in you PSProfile as a job routine every time you start a shell.
        Doing so is described in the 'practical-usage' on the github project page:
        https://github.com/AndiBellstedt/PackageUpdateInfo#practical-usage

    .EXAMPLE
        PS C:\> Set-PackageUpdateSetting -ExcludeModuleFromChecking "Az.*"

        Put all Az. modules on the exclude list for update checking.
        This should be considered as a bad practice, because you'll not get any update information for all Az. modules anymore.
        (and they might change quite often)

        If you have worries/issues on performance, due to a large number of modules installed, you better follow the practice to put the 'checking mechansim' in you PSProfile as a job routine every time you start a shell.
        Doing so is described in the 'practical-usage' on the github project page:
        https://github.com/AndiBellstedt/PackageUpdateInfo#practical-usage

    .EXAMPLE
        PS C:\> Set-PackageUpdateSetting -IncludeModuleForChecking "*" -ReportChangeOnMajor $true -ReportChangeOnMinor $true -ReportChangeOnBuild $true -ReportChangeOnRevision $true -UpdateCheckInterval "01:00:00"

        Restores the default update-check behavior and notification thresholds while keeping the configured update interval at one hour.

    .EXAMPLE
        PS C:\> Set-PackageUpdateSetting -Reset

        Resets the package update settings to the built-in defaults.

    .EXAMPLE
        PS C:\> Get-PackageUpdateSetting | Set-PackageUpdateSetting -PassThru

        Updates the current configuration object in memory and returns it to the pipeline for further processing.

    .NOTES
        Version  : 1.1.0.0
        Author   : Andi Bellstedt
        Date     : 2026-06-21
        Keywords : PackageUpdateInfo, Update, Module, Setting

    .LINK
        https://packageupdateinfo.andibellstedt.com/docs/commands/set-packageupdatesetting/

    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [Alias('spus')]
    [OutputType([PackageUpdate.Configuration])]
    Param (
        [Parameter(ParameterSetName = "SetBehaviour")]
        [Alias("Exclude", "ExcludeModule")]
        [AllowEmptyString()]
        [String[]]
        $ExcludeModuleFromChecking,

        [Parameter(ParameterSetName = "SetBehaviour")]
        [Alias("Include", "IncludeModule")]
        [String[]]
        $IncludeModuleForChecking,

        [Parameter(ParameterSetName = "SetBehaviour")]
        [bool]
        $ReportChangeOnMajor,

        [Parameter(ParameterSetName = "SetBehaviour")]
        [bool]
        $ReportChangeOnMinor,

        [Parameter(ParameterSetName = "SetBehaviour")]
        [bool]
        $ReportChangeOnBuild,

        [Parameter(ParameterSetName = "SetBehaviour")]
        [bool]
        $ReportChangeOnRevision,

        [Parameter(ParameterSetName = "SetBehaviour")]
        [timespan]
        $UpdateCheckInterval,

        [Parameter(ParameterSetName = "SetBehaviour")]
        [datetime]
        $LastCheck,

        [Parameter(ParameterSetName = "SetBehaviour")]
        [datetime]
        $LastSuccessfulCheck,

        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "SetBehaviour")]
        [PackageUpdate.Configuration]
        $InputObject,

        [Parameter(ParameterSetName = "ResetBehaviour")]
        [switch]
        $Reset,

        [Alias("FullName", "FilePath")]
        [String]
        $Path,

        [switch]
        $PassThru
    )

    begin {}

    process {

        if ($PSCmdlet.ParameterSetName -like "ResetBehaviour") {

            if (-not $Path) { $Path = $script:ModuleSettingPath }

            if ($pscmdlet.ShouldProcess($path, "Reset PackageUpdateInfo behaviour")) {
                # Initialize default preferences
                $defaultSetting = [PackageUpdate.Configuration]@{
                    CustomRule          = @()
                    DefaultRule         = [PackageUpdate.ModuleRule]@{
                        ExcludeModuleFromChecking = @("")
                        IncludeModuleForChecking  = @("*")
                        ReportChangeOnMajor       = $true
                        ReportChangeOnMinor       = $true
                        ReportChangeOnBuild       = $true
                        ReportChangeOnRevision    = $true
                    }
                    UpdateCheckInterval = "01:00:00"
                    LastCheck           = [string][datetime]::MinValue
                    LastSuccessfulCheck = [string][datetime]::MinValue
                    Path                = $Path
                }

                # Write setting to file
                $defaultSetting | ConvertFrom-PackageUpdateSetting | ConvertTo-Json | Out-File -FilePath $Path -Encoding default -Force

                if ($PassThru) {
                    $defaultSetting
                }
            }

        }

        if ($PSCmdlet.ParameterSetName -like "SetBehaviour") {

            # If no setting object is piped in, get the current settings
            if (-not $InputObject) {
                $paramPackageUpdateSetting = @{ }
                if ($Path) { $paramPackageUpdateSetting["Path"] = $Path }
                $InputObject = Get-PackageUpdateSetting @paramPackageUpdateSetting
            }

            # check if path is specified
            if ($Path) {
                if (-not ($Path -like $InputObject.Path)) {
                    Write-Verbose -Message "Setting object is piped in but a different path for PackageUpdate setting is specified. Piped in object will override path setting. (Effective path: $($InputObject.Path))" -Verbose
                    $Path = $InputObject.Path
                }
            } else {
                $Path = $InputObject.Path
            }

            # Set the new preference values
            if ("ExcludeModuleFromChecking" -in $PSBoundParameters.Keys) {
                Write-Verbose "Setting ExcludeModuleFromChecking: '$([string]::Join(", ", $ExcludeModuleFromChecking))'"
                $InputObject.DefaultRule.ExcludeModuleFromChecking = $ExcludeModuleFromChecking
            }
            if ("IncludeModuleForChecking" -in $PSBoundParameters.Keys) {
                Write-Verbose "Setting IncludeModuleForChecking: '$([string]::Join(", ", $IncludeModuleForChecking))'"
                $InputObject.DefaultRule.IncludeModuleForChecking = $IncludeModuleForChecking
            }
            if ($PSBoundParameters["ReportChangeOnMajor"]) {
                Write-Verbose "Setting ReportChangeOnMajor: $($ReportChangeOnMajor)"
                $InputObject.DefaultRule.ReportChangeOnMajor = $ReportChangeOnMajor
            }
            if ($PSBoundParameters["ReportChangeOnMinor"]) {
                Write-Verbose "Setting ReportChangeOnMinor: $($ReportChangeOnMinor)"
                $InputObject.DefaultRule.ReportChangeOnMinor = $ReportChangeOnMinor
            }
            if ($PSBoundParameters["ReportChangeOnBuild"]) {
                Write-Verbose "Setting ReportChangeOnBuild: $($ReportChangeOnBuild)"
                $InputObject.DefaultRule.ReportChangeOnBuild = $ReportChangeOnBuild
            }
            if ($PSBoundParameters["ReportChangeOnRevision"]) {
                Write-Verbose "Setting ReportChangeOnRevision: $($ReportChangeOnRevision)"
                $InputObject.DefaultRule.ReportChangeOnRevision = $ReportChangeOnRevision
            }
            if ($PSBoundParameters["UpdateCheckInterval"]) {
                Write-Verbose "Setting UpdateCheckInterval: $($UpdateCheckInterval)"
                $InputObject.UpdateCheckInterval = $UpdateCheckInterval
            }
            if ($PSBoundParameters["LastCheck"]) {
                Write-Verbose "Setting LastCheck: $($LastCheck)"
                $InputObject.LastCheck = $LastCheck
            }
            if ($PSBoundParameters["LastSuccessfulCheck"]) {
                Write-Verbose "Setting LastSuccessfulCheck: '$($LastSuccessfulCheck)'"
                $InputObject.LastSuccessfulCheck = $LastSuccessfulCheck
            }
            Write-Verbose "Setting 'Path': $($Path)"
            $InputObject.Path = $Path

            if ($pscmdlet.ShouldProcess($path, "Export PackageUpdateInfo")) {
                $InputObject | ConvertFrom-PackageUpdateSetting | ConvertTo-Json | Out-File -FilePath $Path -Encoding default -Force
            }

        }

    }

    end {}

}
