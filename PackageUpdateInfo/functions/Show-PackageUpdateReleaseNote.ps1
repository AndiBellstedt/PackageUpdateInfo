function Show-PackageUpdateReleaseNote {
    <#
    .SYNOPSIS
        Show release notes from a module

    .DESCRIPTION
        Show release notes from a module.

    .PARAMETER InputObject
        Input object(s) from Get-PackageUpdateInfo or Import-PackageUpdateInfo to show release notes

    .PARAMETER Module
        Input object(s) from Get-Module to show release notes

    .PARAMETER WhatIf
        If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

    .PARAMETER Confirm
        If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.

    .EXAMPLE
        PS C:\> Get-PackageUpdateInfo | Show-PackageUpdateReleaseNote

        Get release notes out of PackageUpdateInfo objects

    .EXAMPLE
        PS C:\> Get-Module PackageUpdateInfo | Show-PackageUpdateReleaseNote

        Get relase notes from a module

    #>
    [CmdletBinding( SupportsShouldProcess = $true,
        ConfirmImpact = 'Low')]
    [Alias('spurn')]
    [OutputType([PackageUpdate.ReleaseNote])]
    Param (
        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByPackageUpdeInfoObject')]
        [Alias("Input")]
        [PackageUpdate.Info[]]
        $InputObject,

        [Parameter(Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'ByModuleObject')]
        [System.Management.Automation.PSModuleInfo[]]
        [Alias('ModuleName')]
        $Module
    )

    begin {
    }

    process {
        $modulesToProcess = @()

        # Process input pipeline for PackageUpdateInfo objects
        $modulesToProcess += foreach ($inputObjectItem in $InputObject) {
            if ($inputObjectItem.HasReleaseNotes) {
                [PackageUpdate.ReleaseNote]@{
                    Name         = $inputObjectItem.Name
                    Version      = $inputObjectItem.VersionOnline
                    ReleaseNotes = $inputObjectItem.ReleaseNotes
                }
            } else {
                Write-Verbose "No release notes found for module $($inputObjectItem.Name) ($($inputObjectItem.Version))" -Verbose
            }
        }

        # Process input pipeline for modules
        $modulesToProcess += foreach ($moduleItem in $Module) {
            if ($moduleItem.ReleaseNotes) {
                [PackageUpdate.ReleaseNote]@{
                    Name         = $moduleItem.Name
                    Version      = $moduleItem.Version
                    ReleaseNotes = $moduleItem.ReleaseNotes
                }
            } else {
                Write-Verbose "No release notes found for module $($moduleItem.Name) ($($moduleItem.Version))" -Verbose
            }
        }

        # Working through the module objects
        foreach ($item in $modulesToProcess) {
            if ($pscmdlet.ShouldProcess($item.Name, "Show release notes")) {

                # If release notes are an URL, try to gather release notes from web site
                if ($item.ReleaseNotesIsURI) {
                    # Set basic variables
                    $msgUnableToGather = "Unable to gather release notes from website. Please use a browser to visit: $($item.ReleaseNotesURI)"
                    $paramInvokeWebRequest = @{
                        TimeoutSec  = 2
                        ErrorAction = "SilentlyContinue"
                    }

                    # Gathering release notes from web modules is only possible in some certain cases
                    # if url points to a file on a github repo, it is possible to get plain text information
                    # in other cases, the url will be tried to resolve and double check if it is a github repo (quicklinks/ forwardings)
                    switch ($item.ReleaseNotesURI) {
                        { Assert-PossibleReleaseNotesURI -URI $_ } {
                            if ($item.ReleaseNotesURI -like "*/releases/*") {
                                # Github release pages can't be covered. Set unable-message
                                $item.Notes = $msgUnableToGather

                            } else {
                                # Set variables for Invoke-WebRequest
                                $paramInvokeWebRequest["Uri"] = $item.ReleaseNotesURI.ToString() -replace "/blob/", "/raw/"
                                if ($PSVersionTable.PSEdition -like "Desktop") { $paramInvokeWebRequest["UseBasicParsing"] = $true }

                                # Gather release notes from web
                                $webData = Invoke-WebRequest @paramInvokeWebRequest

                                # Set web content as notes
                                $item.Notes = $webData.Content

                            }
                        }

                        default {
                            # Default case. URL seams not to be a known/parseable URL for plain text release notes.
                            # gather the URL anyway to check if it is a forwarding/shortlink URL to github

                            # Set variables for Invoke-WebRequest to resolve the specified URI
                            $paramInvokeWebRequest["Uri"] = $item.ReleaseNotesURI.ToString()
                            if ($PSVersionTable.PSEdition -like "Desktop") { $paramInvokeWebRequest["UseBasicParsing"] = $true }

                            # Gather URI from web
                            $webData = Invoke-WebRequest @paramInvokeWebRequest

                            # Extract URI from WebRequest response
                            if ($PSVersionTable.PSEdition -like "Desktop") {
                                $_uri = $webData.BaseResponse.ResponseUri
                            } else {
                                $_uri = $webData.BaseResponse.RequestMessage.RequestUri
                            }

                            # Is gathered WebRequest a "valid" URI, now?
                            if (Assert-PossibleReleaseNotesURI -URI $_uri) {
                                # Set variables for final Invoke-WebRequest to resolve the plain text release notes
                                $paramInvokeWebRequest.uri = $_uri -replace "/blob/", "/raw/"

                                # Gather release notes from web
                                $webData = Invoke-WebRequest @paramInvokeWebRequest

                                # set web content as notes
                                $item.Notes = $webData.Content

                            } else {
                                # Set unable-message
                                $item.Notes = $msgUnableToGather

                            }
                        }
                    }
                }

                # Output result item
                $item
            }
        }
    }

    end {
    }
}
