function Export-PackageUpdateInfo {
    <#
    .SYNOPSIS
        Export PackageUpdateInfo to a data file

    .DESCRIPTION
        Export PackageUpdateInfo to a data file

    .PARAMETER InputObject
        The PackageUpdateInfo from Get-PackageUpdateInfo function.

    .PARAMETER Path
        The filepath where to export the infos.
        Please specify a file as path.

    .PARAMETER OutputFormat
        The output format for the data
        Available formats are "XML","JSON","CSV"

    .PARAMETER Encoding
        File Encoding for the file

    .PARAMETER Force
        If the directory for the file is not present, but a directory other then the default is specified,
        the function will try to create the diretory.

    .PARAMETER Append
        The output file will not be replaced. All information will be appended.

    .PARAMETER IncludeTimeStamp
        A timestamp will be added to the information records.

    .PARAMETER PassThru
        The exported objects will be parsed to the pipeline for further processing.

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
        PS C:\> Get-PackageUpdateInfo | Export-PackageUpdateInfo

        Example for usage of Export-PackageUpdateInfo
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
        $Path = (Join-Path $HOME "AppData\Local\Microsoft\Windows\PowerShell\PackageUpdateInfo.xml"),

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
        # If  file is specified as path
        if (Test-Path -Path $Path -PathType Leaf -IsValid) {
            # If file is present, resolve the path
            if (Test-Path -Path $Path -PathType Leaf) {
                $outputPath = Resolve-Path -Path $Path
            }
            else {
                # If Force switch is specified and the path does not exists
                if ($Force -and (-not (Resolve-Path -Path (Split-Path $Path))) ) {
                    New-Item -ItemType Directory -Path (Split-Path $Path) -ErrorAction Stop
                }
                # Try to create the file and resolve the path
                $outputPath = New-Item -ItemType File -Path $Path -ErrorAction Stop
                $outputPath = Resolve-Path -Path $outputPath
            }
        }
        # If directory is specified as path
        elseif (Test-Path -Path $Path -PathType Container) {
            Write-Error -Message "Specified Path is a directory. Please specify an file." -ErrorAction Stop
        }
        else {
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
                }
                if ($IncludeTimeStamp) {
                    $hash.add("TimeStamp", $object.TimeStamp)
                }
                New-Object -TypeName psobject -Property $hash
            }
        }
        else {
            $output += $InputObject
        }

        if($PassThru) { [PackageUpdate.Info]$InputObject }
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
                }
                elseif ($OutputFormat -in "CSV") {
                    $outFileParams.Add("Path", $outputPath.Path)
                    $outFileParams.Add("Delimiter", ';')
                    $outFileParams.Add("NoTypeInformation", $true)
                    $output | Export-Csv @outFileParams
                }
                else {
                    $Exportdata = if ($Append -and ((Get-ChildItem -Path $outputPath.Path).Length -gt 0) ) { Import-Clixml -Path $outputPath.Path -ErrorAction SilentlyContinue } else { @() }
                    $Exportdata += $output
                    $Exportdata | Export-Clixml -Path $outputPath.Path -Encoding $Encoding
                }
            }
        }
        else {
            Write-Verbose -Message "No data were processed, nothing to output."
            "" | Out-File $outputPath.Path -Encoding $Encoding
        }
    }
}
