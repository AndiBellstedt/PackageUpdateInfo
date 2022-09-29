function Set-PackageUpdateSetting {
    <#
    .SYNOPSIS
        Set behaviour settings for PackageUpdateInfo module

    .DESCRIPTION
        Set-PackageUpdateInfo configure basic settings for check and report on up-to-dateness information on installed modules

    .PARAMETER Path
        The filepath where to setting file is stored

        This is optional, default path value is:
        Linux:   "$HOME/.local/share/powershell/PackageUpdateInfo/PackageUpdateSetting_$($PSEdition)_$($PSVersionTable.PSVersion.Major).json")
        Windows: "$HOME\AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateSetting_$($PSEdition)_$($PSVersionTable.PSVersion.Major).json")

    .PARAMETER InputObject
        Settings object parsed in from command Get-PackageUpdateSetting

    .PARAMETER ExcludeModuleFromChecking
        ModuleNames to exclude from update checking in the default rule

    .PARAMETER IncludeModuleForChecking
        ModuleNames to include from update checking in the default rule
        By default all modules are included.

        Default value is: "*"

    .PARAMETER ReportChangeOnMajor
        Report when major version changed for a module in the default rule

        This means 'Get-PackageUpdateSetting' report update need,
        only when the major version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        1      0      0     0

    .PARAMETER ReportChangeOnMinor
        Report when minor version changed for a module in the default rule

        This means 'Get-PackageUpdateSetting' report update need,
        only when the minor version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      1      0     0

    .PARAMETER ReportChangeOnBuild
        Report when build version changed for a module in the default rule

        This means 'Get-PackageUpdateSetting' report update need,
        when the build version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        0      0      1     0

    .PARAMETER ReportChangeOnRevision
        Report when revision part changed for a module in the default rule

        This means 'Get-PackageUpdateSetting' report update need,
        when the revision version version of a module change.

        Major  Minor  Build  Revision
        -----  -----  -----  --------
        1      0      0     0

    .PARAMETER UpdateCheckInterval
        The minimum interval/timespan has to gone by,for doing a new module update check

        Default value is: "01:00:00"

    .PARAMETER LastCheck
        Timestamp when last check for update need on modules started

    .PARAMETER LastSuccessfulCheck
        Timestamp when last check for update need finished

    .PARAMETER Reset
        Reset module to it'S default behaviour

    .PARAMETER PassThru
        The setting object will be parsed to the pipeline for further processing

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
        PS C:\> Set-PackageUpdateSetting -ExcludeModuleFromChecking @("") -IncludeModuleForChecking "*" -ReportChangeOnMajor $true -ReportChangeOnMinor $true -ReportChangeOnBuild $true -ReportChangeOnRevision $true -UpdateCheckInterval "01:00:00"

        Reset module to it'S default behaviour

    .EXAMPLE
        PS C:\> Set-PackageUpdateSetting -Reset

        Reset module to it'S default behaviour

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

    begin {
    }

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

    end {
    }
}
