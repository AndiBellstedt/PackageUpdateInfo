function Get-PackageUpdateSetting {
    <#
    .SYNOPSIS
        Retrieves the PackageUpdateInfo configuration from the module settings file.

    .DESCRIPTION
        Reads the PackageUpdateInfo configuration file and returns the current module behavior settings as a PackageUpdate.Configuration object. The returned object includes the default and custom update rules, the update check interval, and the timestamps of the last and last successful checks.

    .PARAMETER Path
        The full path to the settings file to read.

        This parameter is optional. If it is omitted, the function uses the default module settings path:
        Linux:   "$HOME/.config/powershell/PackageUpdateInfo/PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).json"
        Windows: "$HOME\AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).json"

    .EXAMPLE
        PS C:\> Get-PackageUpdateSetting

        Retrieves the current PackageUpdateInfo settings from the default configuration file.

    .EXAMPLE
        PS C:\> Get-PackageUpdateSetting -Path "C:\temp\PackageUpdateInfo.json"

        Reads the PackageUpdateInfo configuration from a specific settings file.

    .EXAMPLE
        PS C:\> Get-PackageUpdateSetting | Select-Object -ExpandProperty UpdateCheckInterval

        Returns the configured update check interval from the current settings.

    .NOTES
        Version  : 1.1.0.0
        Author   : Andi Bellstedt
        Date     : 2026-06-21
        Keywords : PackageUpdateInfo, Update, Module, Setting

    .LINK
        https://packageupdateinfo.andibellstedt.com/docs/commands/get-packageupdatesetting/

    #>
    [CmdletBinding(SupportsShouldProcess = $false, ConfirmImpact = 'Low')]
    [Alias('gpus')]
    [OutputType([PackageUpdate.Configuration])]
    Param (
        [Parameter(Position = 0)]
        [Alias("FullName", "FilePath")]
        [String]
        $Path = $script:ModuleSettingPath
    )

    begin {}

    process {

        # read settings file
        try {
            $configuration = Get-Content -Path $Path -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        } catch {
            Write-Warning -Message "Module configuration file not found! ($($Path))"
            Write-Warning -Message "Please check the path or initialize configuration by using 'Set-PackageUpdateSetting -Reset'"
            throw
        }

        # Initialize setting object and fill in values
        $output = New-Object -TypeName PackageUpdate.Configuration

        $output.CustomRule = foreach ($rule in $configuration.CustomRule) {
            [PackageUpdate.ModuleRule]@{
                Id                        = $rule.Id
                ExcludeModuleFromChecking = $rule.ExcludeModuleFromChecking
                IncludeModuleForChecking  = $rule.IncludeModuleForChecking
                ReportChangeOnBuild       = $rule.ReportChangeOnBuild
                ReportChangeOnMajor       = $rule.ReportChangeOnMajor
                ReportChangeOnMinor       = $rule.ReportChangeOnMinor
                ReportChangeOnRevision    = $rule.ReportChangeOnRevision
            }
        }

        $output.DefaultRule = [PackageUpdate.ModuleRule]@{
            ExcludeModuleFromChecking = $configuration.DefaultRule.ExcludeModuleFromChecking
            IncludeModuleForChecking  = $configuration.DefaultRule.IncludeModuleForChecking
            ReportChangeOnBuild       = $configuration.DefaultRule.ReportChangeOnBuild
            ReportChangeOnMajor       = $configuration.DefaultRule.ReportChangeOnMajor
            ReportChangeOnMinor       = $configuration.DefaultRule.ReportChangeOnMinor
            ReportChangeOnRevision    = $configuration.DefaultRule.ReportChangeOnRevision
        }

        if ("System.TimeSpan" -in $configuration.UpdateCheckInterval.psobject.TypeNames) {
            $output.UpdateCheckInterval = [timespan]::new($configuration.UpdateCheckInterval.Days, $configuration.UpdateCheckInterval.Hours, $configuration.UpdateCheckInterval.Minutes, $configuration.UpdateCheckInterval.Seconds, $configuration.UpdateCheckInterval.Milliseconds)
        } else {
            $output.UpdateCheckInterval = [timespan]$configuration.UpdateCheckInterval
        }

        if ($configuration.LastCheck) {
            $output.LastCheck = [datetime]$configuration.LastCheck
        } else {
            $output.LastCheck = [datetime]::MinValue
        }
        if ($configuration.LastSuccessfulCheck) {
            $output.LastSuccessfulCheck = [datetime]$configuration.LastSuccessfulCheck
        } else {
            $output.LastSuccessfulCheck = [datetime]::MinValue
        }

        $output.Path = $configuration.Path

        $output

    }

    end {}

}
