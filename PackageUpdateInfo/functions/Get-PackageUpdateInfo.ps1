function Get-PackageUpdateInfo {
    <#
    .SYNOPSIS
        Get info about up-to-dateness for installed modules

    .DESCRIPTION
        Get-PackageUpdateInfo query locally installed modules and compare them against the online versions for up-to-dateness

    .PARAMETER Name
        The name of the module to check

    .PARAMETER Repository
        The repository to check

    .PARAMETER ShowOnlyNeededUpdate
        This switch suppresses up-to-date modules from the output.

    .PARAMETER ShowToastNotification
        This switch invokes nice Windows-Toast-Notifications with release note information on modules with update needed.

    .PARAMETER CurrentUser
        Only look for modules in the current user profile.
        This is helpfully if you're running without admin right, which you should always do as your default work preference.

    .PARAMETER AllUsers
        Only look for modules in the AllUsers/system directories.
        Keep in mind, that admin rights are required to update those modules.

    .PARAMETER Force
        Force to query info about up-to-dateness for installed modules, even if the UpdateCheckInterval
        from last check is not expired.

    .EXAMPLE
        PS C:\> Get-PackageUpdateInfo

        Outputs update information for all modules (currentUser and AllUsers).
        Output can look like:

        Name       Repository VersionInstalled VersionOnline NeedUpdate Path
        ----       ---------- ---------------- ------------- ---------- ----
        PSReadline PSGallery  1.2              1.2           False      C:\Program Files\WindowsPowerShell\Modules\PSReadline
        Pester     PSGallery  4.4.0            4.4.2         True       C:\Program Files\WindowsPowerShell\Modules\Pester

    .EXAMPLE
        PS C:\> Get-PackageUpdateInfo -ShowOnlyNeededUpdate

        This will filter output to show only modules where NeedUpdate is True
        Output can look like:

        Name       Repository VersionInstalled VersionOnline NeedUpdate Path
        ----       ---------- ---------------- ------------- ---------- ----
        Pester     PSGallery  4.4.0            4.4.2         True       C:\Program Files\WindowsPowerShell\Modules\Pester

    .EXAMPLE
        PS C:\> "Pester", "PSReadline" | Get-PackageUpdateInfo

        Pipeline is supported. This returns the infos only for the two modules "Pester", "PSReadline"

        This also can be done with Get-Module cmdlet:
        Get-Module "Pester", "PSReadline" | Get-PackageUpdateInfo

    #>
    [CmdletBinding( DefaultParameterSetName = 'DefaultSet1',
        SupportsShouldProcess = $false,
        ConfirmImpact = 'Low')]
    [Alias('gpui')]
    [OutputType([PackageUpdate.Info])]
    Param (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $Name,

        [string[]]
        $Repository,

        [switch]
        $ShowOnlyNeededUpdate,

        [switch]
        [Alias('ToastNotification', 'Notify')]
        $ShowToastNotification,

        [Parameter(ParameterSetName = 'CurrentUser')]
        [switch]
        $CurrentUser,

        [Parameter(ParameterSetName = 'AllUsers')]
        [switch]
        $AllUsers,

        [switch]
        $Force
    )

    begin {
        if ($ShowToastNotification -and (-not $script:EnableToastNotification)) {
            Write-Verbose -Message "System is not able to do Toast Notifications" -Verbose
        }

        # Doing checks if the update check against the modules is done
        $moduleSetting = Get-PackageUpdateSetting
        if (-not $Force) {
            if ($moduleSetting.LastCheck -gt $moduleSetting.LastSuccessfulCheck) {
                $effectiveCheckDate = $moduleSetting.LastCheck
            } else {
                $effectiveCheckDate = $moduleSetting.LastSuccessfulCheck
            }

            if ( ($effectiveCheckDate + $moduleSetting.UpdateCheckInterval) -ge (Get-Date) ) {
                Write-Warning -Message "Skip checking for updates on modules, due to last check happens at $($effectiveCheckDate.ToShortTimeString()) and minimum UpdateCheckInterval is set to $($moduleSetting.UpdateCheckInterval)"
                break
            }
        } else {
            Write-Verbose -Message "Force parameter specified. Bypassing checking on UpdateCheckInterval and enforcing up-to-dateness check on modules"
        }
        Set-PackageUpdateSetting -LastCheck (Get-Date)

        # Get the necessary repositories
        $getPSRepositoryParams = @{ }
        if ($Repository) { $getPSRepositoryParams.Add("Name", $Repository) }
        $psRepositories = Get-PSRepository @getPSRepositoryParams -ErrorAction Stop

    }

    process {
        if (-not $Name) { $Name = "*" }
        foreach ($nameItem in $Name) {
            # Get local module(s)
            Write-Verbose "Get local module(s): $($nameItem)"
            $getModuleParams = @{
                ListAvailable = $true
                Name          = $nameItem
                Verbose       = $false
            }
            $modulesLocal = Get-Module @getModuleParams | Where-Object RepositorySourceLocation | Sort-Object Name, Version -Descending | Group-Object Name | ForEach-Object { $_.group[0] }

            # Filtering out if switches are specified
            Write-Verbose "Do the filtering..."
            if ($CurrentUser) {
                $modulesLocal = foreach ($path in $CurrentUserModulePath) { $modulesLocal | Where-Object path -Like "$($path)*" }
            }
            if ($AllUsers) {
                $modulesLocal = foreach ($path in $AllUsersModulePath) { $modulesLocal | Where-Object path -Like "$($path)*" }
            }
            if ($Repository) {
                $modulesLocal = foreach ($psRepository in $psRepositories) { $modulesLocal | Where-Object RepositorySourceLocation -like "$($psRepository.SourceLocation)*" }
            }

            # Get available modules from online repositories
            Write-Verbose "Get available modules from online repositories"
            $modulesOnline = foreach ($moduleLocalName in $modulesLocal.Name) {
                $findModuleParams = @{
                    "Name" = $moduleLocalName
                    "Verbose" = $false
                }
                if ($Repository) { $findModuleParams["Repository"] = $Repository }
                Find-Module @findModuleParams
            }

            # Compare the version and create output
            Write-Verbose "Compare the version and create output"
            foreach ($moduleOnline in $modulesOnline) {
                $moduleLocal = $modulesLocal | Where-Object Name -like $moduleOnline.Name

                if ($moduleOnline.version -gt $moduleLocal.version) {
                    Write-Verbose "Update available for module '$($moduleOnline.Name)': local v$($moduleLocal.version) --> v$($moduleOnline.version) online"
                    $UpdateAvailable = Test-UpdateIsNeeded -ModuleLocal $moduleLocal -ModuleOnline $moduleOnline
                    #$UpdateAvailable = $true
                } elseif ($moduleOnline.version -lt $moduleLocal.version) {
                    Write-Warning "Local version for module '$($moduleOnline.Name)' is higher than online version: local v$($moduleLocal.version) <-- v$($moduleOnline.version) online"
                    $UpdateAvailable = $false
                } else {
                    Write-Verbose "The module '$($moduleOnline.Name)' is up to date (Version $($moduleLocal.version))"
                    $UpdateAvailable = $false
                }

                if ($ShowOnlyNeededUpdate -and (-not $UpdateAvailable)) { continue }

                $outputHash = [ordered]@{
                    Name             = $moduleLocal.Name
                    Repository       = ($psRepositories | Where-Object SourceLocation -like "$($moduleLocal.RepositorySourceLocation.ToString().Trim('/'))*").Name
                    VersionInstalled = $moduleLocal.version
                    VersionOnline    = $moduleOnline.version
                    NeedUpdate       = $UpdateAvailable
                    Path             = $moduleLocal.ModuleBase.Replace($moduleLocal.Version, '').trim('\')
                    ProjectUri       = $moduleOnline.ProjectUri
                    IconUri          = $moduleOnline.IconUri
                    ReleaseNotes     = $moduleOnline.ReleaseNotes
                    Author           = $moduleOnline.Author
                    PublishedDate    = $moduleOnline.PublishedDate
                    Description      = $moduleOnline.Description
                }
                $PackageUpdateInfo = New-Object -TypeName PackageUpdate.Info -Property $outputHash

                if ($script:EnableToastNotification -and $ShowToastNotification -and $PackageUpdateInfo.NeedUpdate) {
                    Show-ToastNotification -PackageUpdateInfo $PackageUpdateInfo
                }

                $PackageUpdateInfo
            }
        }
    }

    end {
        Set-PackageUpdateSetting -LastSuccessfulCheck (Get-Date)
    }
}
