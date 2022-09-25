function Import-PackageUpdateInfo {
    <#
    .SYNOPSIS
        Import PackageUpdateInfo from a data file

    .DESCRIPTION
        Import PackageUpdateInfo from a data file previously exported with funtion Export-PackageUpdateInfo.

    .PARAMETER Path
        The filepath where to import the informations.
        Please specify a file as path.

        Default path value is:
        Linux:   "$HOME/.local/share/powershell/PackageUpdateInfo/PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml")
        Windows: "$HOME\AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml")

    .PARAMETER ShowToastNotification
        This switch invokes nice Windows-Toast-Notifications with release note information on modules with update needed.

    .PARAMETER InputFormat
        The output format for the data
        Available formats are "XML","JSON","CSV"

    .PARAMETER Encoding
        File Encoding for the file

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
        PS C:\> Import-PackageUpdateInfo

        Try to import the default file "$HOME\AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml"
    #>
    [CmdletBinding( SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    [Alias('ipui')]
    [OutputType([PackageUpdate.Info])]
    Param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("FullName", "FilePath")]
        [String]
        $Path,

        [switch]
        [Alias('ToastNotification', 'Notify')]
        $ShowToastNotification,

        [ValidateSet("XML", "JSON", "CSV")]
        [Alias("Format")]
        [String]
        $InputFormat = "XML",

        [ValidateSet("default", "utf7", "utf8", "utf32", "unicode", "ascii", "string", "oem", "bigendianunicode")]
        [String]
        $Encoding = "default"
    )

    begin {
        if($ShowToastNotification -and (-not $script:EnableToastNotification)) {
            Write-Verbose -Message "System is not able to do Toast Notifications" -Verbose
        }

        # Set path variable to default value, when not specified
        if(-not $path) {
            if($IsLinux) {
                $path = (Join-Path $HOME ".local/share/powershell/PackageUpdateInfo/PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml")
            } else {
                $path = (Join-Path $HOME "AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml")
            }
        }
    }

    process {
        $file = Get-ChildItem -Path $Path -ErrorAction Stop

        if ($pscmdlet.ShouldProcess($Path, "Import PackageUpdateInfo")) {
            if ($file.Length -gt 2) {
                Write-Verbose "Importing package update information from $($file.FullName)"

                if ($InputFormat -like "JSON") {
                    $records = Get-Content -Path $file -Encoding $Encoding | ConvertFrom-Json -ErrorAction SilentlyContinue
                } elseif ($InputFormat -like "CSV") {
                    $records = Import-Csv -Path $file -Delimiter ";" -Encoding $Encoding
                } else {
                    $records = Import-Clixml -Path $file
                }

                foreach ($record in $records) {
                    $_date = $record.PublishedDate | Get-Date
                    $hash = [ordered]@{
                        Name             = $record.Name
                        Repository       = $record.Repository
                        VersionInstalled = [version]$record.VersionInstalled
                        VersionOnline    = [version]$record.VersionOnline
                        NeedUpdate       = [bool]::Parse($record.NeedUpdate)
                        Path             = $record.Path
                        ProjectUri       = $record.ProjectUri
                        IconUri          = $record.IconUri
                        ReleaseNotes     = $record.ReleaseNotes
                        Author           = $record.Author
                        PublishedDate    = $_date
                        Description      = $record.Description
                    }
                    $PackageUpdateInfo = [PackageUpdate.Info]$hash
                    if ($script:EnableToastNotification -and $ShowToastNotification -and $PackageUpdateInfo.NeedUpdate) { Show-ToastNotification -PackageUpdateInfo $PackageUpdateInfo }
                    $PackageUpdateInfo
                }
            } else {
                Write-Verbose "Nothing to import. Seems like, all is up to date."
            }
        }
    }

    end {
    }
}
