function Get-PackageUpdateSetting {
    <#
    .SYNOPSIS
        Get the current settings on PackageUpdateInfo behaviour

    .DESCRIPTION
        Command query settings for behaviour on how PackageUpdateInfo module is bevahing
        with checking and reporting on updates for modules.

    .PARAMETER Path
        The filepath where to setting file

        This is optional, default path value is:
        Linux:   "$HOME/.local/share/powershell/PackageUpdateInfo/PackageUpdateInfo.xml")
        Windows: "$HOME\AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo.xml")

    .EXAMPLE
        PS C:\> Get-PackageUpdateSetting

        Get the current settings on PackageUpdateInfo behaviour.

    #>
    [CmdletBinding(SupportsShouldProcess = $false,ConfirmImpact = 'Low')]
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
        $configuration = Get-Content -Path $Path | ConvertFrom-Json

        # Initialize setting object and fill in values
        $output = New-Object -TypeName PackageUpdate.Configuration

        $output.Path = $configuration.Path

        $output.ExcludeModuleFromChecking = $configuration.ExcludeModuleFromChecking
        $output.IncludeModuleForChecking = $configuration.IncludeModuleForChecking

        $output.ReportChangeOnBuild = $configuration.ReportChangeOnBuild
        $output.ReportChangeOnMajor = $configuration.ReportChangeOnMajor
        $output.ReportChangeOnMinor = $configuration.ReportChangeOnMinor
        $output.ReportChangeOnRevision = $configuration.ReportChangeOnRevision

        if("System.TimeSpan" -in $configuration.UpdateCheckInterval.psobject.TypeNames) {
            $output.UpdateCheckInterval = [timespan]::new($configuration.UpdateCheckInterval.Days, $configuration.UpdateCheckInterval.Hours, $configuration.UpdateCheckInterval.Minutes, $configuration.UpdateCheckInterval.Seconds, $configuration.UpdateCheckInterval.Milliseconds)
        } else {
            $output.UpdateCheckInterval = [timespan]$configuration.UpdateCheckInterval
        }

        if($configuration.LastCheck) {
            $output.LastCheck = [datetime]$configuration.LastCheck
        } else {
            $output.LastCheck = [datetime]::MinValue
        }
        if($configuration.LastSuccessfulCheck) {
            $output.LastSuccessfulCheck = [datetime]$configuration.LastSuccessfulCheck
        } else {
            $output.LastSuccessfulCheck = [datetime]::MinValue
        }

        # Set module variable for version change reporting
        $script:VersionInterval = [version]::new(
            [int]($output.ReportChangeOnMajor),
            [int]($output.ReportChangeOnMinor),
            [int]($output.ReportChangeOnBuild),
            [int]($output.ReportChangeOnRevision)
        )

        $output
    }

    end {
    }
}
