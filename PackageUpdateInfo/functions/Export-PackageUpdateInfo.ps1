function Export-PackageUpdateInfo {
    <#
    .SYNOPSIS
        Exports PackageUpdateInfo objects to an XML, JSON, or CSV file.

    .DESCRIPTION
        Writes PackageUpdateInfo objects produced by Get-PackageUpdateInfo to a structured data file for persistence, reporting, or later automation.
        The cmdlet supports XML, JSON, and CSV output formats, optional timestamping, and append mode for extending an existing file.
        It also supports creating the target directory when needed and can pass the exported objects back through the pipeline.

    .PARAMETER InputObject
        One or more PackageUpdateInfo objects to export. This parameter accepts pipeline input from Get-PackageUpdateInfo and similar commands.

    .PARAMETER Path
        The destination file path for the exported data. Specify a file path rather than a directory path.

        Default path value is:
        Linux:   "$HOME/.config/powershell/PackageUpdateInfo/PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml")
        Windows: "$HOME\AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml"

    .PARAMETER OutputFormat
        The output format used for the export. Supported values are "XML", "JSON", and "CSV".

    .PARAMETER Encoding
        The file encoding to use when creating or updating the export file.

    .PARAMETER Force
        Creates the parent directory for the target file when it does not already exist and the specified path is outside the default location.

    .PARAMETER Append
        Adds exported information to an existing file instead of replacing its current contents. This is supported for JSON and CSV output and is ignored for XML output.

    .PARAMETER IncludeTimeStamp
        Adds a TimeStamp property to each exported record so that the export captures the time of export for each entry.

    .PARAMETER PassThru
        Sends the exported objects to the pipeline after writing them to disk.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed, but informational messages are displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operation that changes state.

    .EXAMPLE
        PS C:\> Get-PackageUpdateInfo | Export-PackageUpdateInfo

        Exports the current PackageUpdateInfo objects to the default XML file.

    .EXAMPLE
        PS C:\> Get-PackageUpdateInfo | Export-PackageUpdateInfo -OutputFormat JSON -Path .\updates.json -IncludeTimeStamp -PassThru

        Exports the data as JSON, includes a timestamp for each record, and passes the objects through the pipeline.

    .EXAMPLE
        PS C:\> Get-PackageUpdateInfo | Export-PackageUpdateInfo -OutputFormat CSV -Path .\updates.csv -Append -Force

        Appends the exported data to a CSV file and creates the target directory if it does not exist.

    .EXAMPLE
        PS C:\> Get-PackageUpdateInfo | Export-PackageUpdateInfo -Path C:\Temp\PackageUpdateInfo.xml -Encoding utf8

        Exports the current data to a custom XML file using UTF-8 encoding.

    .NOTES
        Version  : 1.1.0.0
        Author   : Andi Bellstedt
        Date     : 2026-06-21
        Keywords : PackageUpdateInfo, Update, Module, Export

    .LINK
        https://packageupdateinfo.andibellstedt.com/docs/commands/export-packageupdateinfo/

    #>
    [CmdletBinding( SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium')]
    [Alias('epui')]
    [OutputType([PackageUpdate.Info])]
    Param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [PackageUpdate.Info[]]
        $InputObject,

        [Parameter(Position = 0)]
        [Alias("FullName", "FilePath")]
        [String]
        $Path,

        [ValidateSet("XML", "JSON", "CSV")]
        [Alias("Format")]
        [String]
        $OutputFormat = "XML",

        [ValidateSet("default", "utf7", "utf8", "utf32", "unicode", "ascii", "string", "oem", "bigendianunicode")]
        [String]
        $Encoding = "default",

        [switch]
        $Force,

        [switch]
        $Append,

        [switch]
        $IncludeTimeStamp,

        [switch]
        $PassThru
    )

    begin {

        # Set path variable to default value, when not specified
        if (-not $path) {
            if ($IsLinux) {
                $path = (Join-Path $HOME ".config/powershell/PackageUpdateInfo/PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml")
            } else {
                $path = (Join-Path $HOME "AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo_$($PSEdition)_$($PSVersionTable.PSVersion.Major).xml")
            }
        }

        # If  file is specified as path
        if (Test-Path -Path $Path -PathType Leaf -IsValid) {

            # If file is present, resolve the path
            if (Test-Path -Path $Path -PathType Leaf) {

                $outputPath = Resolve-Path -Path $Path

            } else {

                # If Force switch is specified and the path does not exists
                if ($Force -and (-not (Resolve-Path -Path (Split-Path $Path -ErrorAction SilentlyContinue))) ) {
                    $null = New-Item -ItemType Directory -Path (Split-Path $Path) -ErrorAction Stop
                }

                # Try to create the file and resolve the path
                $outputPath = New-Item -ItemType File -Path $Path -ErrorAction Stop
                $outputPath = Resolve-Path -Path $outputPath

            }

        } elseif (Test-Path -Path $Path -PathType Container) {

            # If directory is specified as path
            Write-Error -Message "Specified Path is a directory. Please specify an file." -ErrorAction Stop

        } else {

            Write-Error -Message "Specified Path is an invalid directory. Please specify an valid file as output path." -ErrorAction Stop

        }

        $output = @()
    }

    process {

        if ($IncludeTimeStamp) {
            $InputObject | Add-Member -MemberType NoteProperty -Name TimeStamp -Value (Get-Date -Format s) -Force
        }

        if ($OutputFormat -in "JSON", "CSV") {

            $output += foreach ($object in $InputObject) {
                $hash = [ordered]@{
                    Name             = $object.Name
                    Repository       = $object.Repository
                    VersionInstalled = $object.VersionInstalled.ToString()
                    VersionOnline    = $object.VersionOnline.ToString()
                    NeedUpdate       = $object.NeedUpdate
                    Path             = $object.Path
                    ProjectUri       = $object.ProjectUri
                    IconUri          = $object.IconUri
                    ReleaseNotes     = $object.ReleaseNotes
                    Author           = $object.Author
                    PublishedDate    = ($object.PublishedDate | Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                    Description      = $object.Description
                }
                if ($IncludeTimeStamp) {
                    $hash.add("TimeStamp", $object.TimeStamp)
                }
                New-Object -TypeName psobject -Property $hash
            }

        } else {

            $output += $InputObject

        }

    }

    end {

        if ($output) {

            if ($pscmdlet.ShouldProcess($outputPath, "Export PackageUpdateInfo")) {
                $outFileParams = @{
                    Encoding = $Encoding
                }
                if ($Append -and $OutputFormat -notlike "XML") { $outFileParams.Add("Append", $true) }

                if ($OutputFormat -in "JSON") {
                    $outFileParams.Add("FilePath", $outputPath.Path)
                    $output | ConvertTo-Json | Out-File @outFileParams
                } elseif ($OutputFormat -in "CSV") {
                    $outFileParams.Add("Path", $outputPath.Path)
                    $outFileParams.Add("Delimiter", ';')
                    $outFileParams.Add("NoTypeInformation", $true)
                    $output | Export-Csv @outFileParams
                } else {
                    $Exportdata = if ($Append -and ((Get-ChildItem -Path $outputPath.Path).Length -gt 0) ) { Import-Clixml -Path $outputPath.Path -ErrorAction SilentlyContinue } else { @() }
                    $Exportdata += $output
                    $Exportdata | Export-Clixml -Path $outputPath.Path -Encoding $Encoding
                }
            }

            if ($PassThru) {
                $output | ForEach-Object { [PackageUpdate.Info]$_ }
            }

        } else {

            Write-Verbose -Message "No data were processed, nothing to output."
            "" | Out-File $outputPath.Path -Encoding $Encoding

        }

    }

}
