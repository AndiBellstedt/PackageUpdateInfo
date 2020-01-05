function Get-PackageUpdateSetting {
    <#
    .SYNOPSIS
        Set behaviour settings for PackageUpdateInfo module

    .DESCRIPTION
        Query the basic settings for check and report on up-to-dateness information on installed modules

    .PARAMETER Path
        The filepath where to setting file

        This is optional, default path value is:
        Linux:   "$HOME/.local/share/powershell/PackageUpdateInfo/PackageUpdateInfo.xml")
        Windows: "$HOME\AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo.xml")

    .EXAMPLE
        PS C:\> Get-PackageUpdateSetting

        Get the current settings on PackageUpdateInfo behaviour.

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

    begin {
    }

    process {
        # read settings file
        try {
            $configuration = Get-Content -Path $Path -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        } catch {
            Write-Warning -Message "Module configuration file not found! ($($Path))"
            Write-Warning -Message "Please check the path or initialize configuration by using 'Set-PackageUpdateSetting -Reset'"
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

    end {
    }
}
