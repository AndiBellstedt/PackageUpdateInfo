function Show-ToastNotification {
    <#
    .SYNOPSIS
        Create a new Toast Notification from a PackUpdateInfo object

    .DESCRIPTION
        Create a new Toast Notification from a PackUpdateInfo object
        Helper function used for internal commands.

    .PARAMETER PackageUpdateInfo
        The PackageUpdate.Info object to show in the toast notification

    .EXAMPLE
        PS C:\> Show-ToastNotification -PackageUpdateInfo $PackageUpdateInfo

        Show Toast Notification on modules with outstanding updates
    #>
    [CmdletBinding( DefaultParameterSetName = 'Default', SupportsShouldProcess = $false, ConfirmImpact = 'Low')]
    [Alias()]
    [OutputType([PackageUpdate.Info])]
    param (
        [Parameter(ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [PackageUpdate.Info[]]
        $PackageUpdateInfo
    )

    begin {
    }

    process {
        # general toast notification header
        $toastHeader = New-BTHeader -Id '001' -Title 'PackageUpdateInfo - Update available' -ActivationType Foreground

        # the text
        $toastText = @()
        $toastText += $PackageUpdateInfo.Repository + "\" + $PackageUpdateInfo.Name + " v" + $PackageUpdateInfo.VersionOnline
        $toastText += "Published: " + $PackageUpdateInfo.PublishedDate.ToString() + "`n" + "Installed version: v" + $PackageUpdateInfo.VersionInstalled + "$(if (-not $PackageUpdateInfo.HasReleaseNotes) { "`n(No release notes available)" })"
        if ($PackageUpdateInfo.IsCurrentUserPath) {
            $toastText += "This is a user specific module."
        } else {
            $toastText += "This is machine wide module."
        }

        # the logo
        if ($PackageUpdateInfo.IconUri) {
            $iconPath = Join-Path -Path $script:ModuleTempPath -ChildPath $PackageUpdateInfo.IconUri.Segments[-1]
            if (Test-Path -Path $iconPath) { Remove-Item -Path $iconPath -Force -ErrorAction:SilentlyContinue }

            try {
                Invoke-WebRequest -Uri $PackageUpdateInfo.IconUri -OutFile $iconPath -SkipCertificateCheck -SkipHeaderValidation -ErrorAction Stop
                $toastLogo = $iconPath
            } catch {
                Write-Verbose -Message "Warning! Unable to get icon from '$($PackageUpdateInfo.IconUri)' for module '$($PackageUpdateInfo.Name)'"
                $toastLogo = $script:ModuleIconPath
            }
        } else {
            $toastLogo = $script:ModuleIconPath
        }

        # the buttons
        $toastButton = @()
        #$toastButton += New-BTButton -Content 'Install' -Arguments "C:\Windows\notepad.exe"
        if ($PackageUpdateInfo.HasReleaseNotes) {
            if ($PackageUpdateInfo.ReleaseNotesIsUri) {
                $toastButtonArgument = $PackageUpdateInfo.ReleaseNotes
            } else {
                $toastButtonArgument = "$($script:ModuleTempPath)\$($PackageUpdateInfo.Name)_v$($PackageUpdateInfo.VersionOnline)_$(Get-Date -Format 'yyyyMMddHHmmssfff').txt"
                Set-Content -Path $toastButtonArgument -Value $PackageUpdateInfo.ReleaseNotes -Force -Encoding Default
            }
            $toastButton += New-BTButton -Content 'Release notes' -Arguments $toastButtonArgument
        }
        $toastButton += New-BTButton -Dismiss

        # create the toast notification
        $notificationParams = @{
            Header  = $toastHeader
            Text    = $toastText
            AppLogo = $toastLogo
            Button  = $toastButton
        }
        New-BurntToastNotification @notificationParams
    }

    end {
    }
}