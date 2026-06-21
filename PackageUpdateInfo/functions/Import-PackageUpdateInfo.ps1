function Import-PackageUpdateInfo {
    <#
    .SYNOPSIS
        Imports package update information from a previously exported data file.

    .DESCRIPTION
        Imports package update information from a data file that was previously exported by Export-PackageUpdateInfo.
        The command reads records from XML, JSON, or CSV files and converts them into PackageUpdateInfo objects for further use,
        display, or processing. When requested, it can also show Windows toast notifications for modules that require an update.

    .PARAMETER Path
        The file path to the data file to import. Specify a valid file path. If omitted, the command uses the default module data file for the current PowerShell edition and version.

        Default paths are:
        Linux:   "$HOME/.config/powershell/PackageUpdateInfo/PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml"
        Windows: "$HOME\AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml"

    .PARAMETER ShowToastNotification
        Displays Windows toast notifications with release-note information for modules that require an update.

    .PARAMETER InputFormat
        Specifies the format of the imported data file. Supported values are "XML", "JSON", and "CSV".

    .PARAMETER Encoding
        Specifies the file encoding used when reading the input file.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
        PS C:\> Import-PackageUpdateInfo

        Imports the default package update information file for the current PowerShell environment.

    .EXAMPLE
        PS C:\> Import-PackageUpdateInfo -Path C:\temp\packageupdateinfo.xml

        Imports update information from a specific XML file.

    .EXAMPLE
        PS C:\> Import-PackageUpdateInfo -Path .\updates.json -InputFormat JSON

        Imports update information from a JSON file that uses the specified input format.

    .EXAMPLE
        PS C:\> Import-PackageUpdateInfo -Path .\updates.csv -InputFormat CSV -ShowToastNotification

        Imports update information from a CSV file and displays toast notifications for modules that need updates.

    .NOTES
        Version  : 1.1.0.0
        Author   : Andi Bellstedt
        Date     : 2026-06-21
        Keywords : PackageUpdateInfo, Update, Module, Info

    .LINK
        https://packageupdateinfo.andibellstedt.com/docs/commands/import-packageupdateinfo/

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

        if ($ShowToastNotification -and (-not $script:EnableToastNotification)) {
            Write-Verbose -Message "System is not able to do Toast Notifications" -Verbose
        }

        # Set path variable to default value, when not specified
        if (-not $path) {
            if ($IsLinux) {
                $path = (Join-Path $HOME ".config/powershell/PackageUpdateInfo/PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml")
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

    end {}

}
