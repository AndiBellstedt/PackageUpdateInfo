function Show-ToastNotification {
    <#
    .SYNOPSIS
        Create a new Toast Notification from a PackageUpdate.Info object

    .DESCRIPTION
        Helper function used for internal commands.
        This function takes a PackageUpdate.Info object and creates a toast notification using the BurntToast module.
        The notification includes the package name, version, published date, installed version, and an optional icon.
        If release notes are available, a button is added to the notification to view them. The function handles both
        user-specific and machine-wide modules and ensures that the appropriate icon is displayed.
        The toast notification is created with a header, text, and buttons based on the provided PackageUpdate.Info object.

    .PARAMETER PackageUpdateInfo
        The PackageUpdate.Info object to show in the toast notification

    .EXAMPLE
        PS C:\> Show-ToastNotification -PackageUpdateInfo $PackageUpdateInfo

        Show Toast Notification on modules with outstanding updates

    .OUTPUTS
        [PackageUpdate.Info] - The PackageUpdate.Info object that was used to create the toast notification

    .NOTES
        Version  : 1.0.0.0
        Author   : Andreas Bellstedt
        Date     : 2019-02-19
        Keywords : PackageUpdateInfo, ToastNotification, BurntToast

    .LINK
        https://github.com/AndiBellstedt/PackageUpdateInfo

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

    begin {}

    process {

        # General toast notification header
        $toastHeader = New-BTHeader -Id '001' -Title 'PackageUpdateInfo - Update available' -ActivationType Foreground

        # The text
        $toastText = @()
        $toastText += $PackageUpdateInfo.Repository + "\" + $PackageUpdateInfo.Name + " v" + $PackageUpdateInfo.VersionOnline
        $toastText += "Published: " + $PackageUpdateInfo.PublishedDate.ToString() + "`n" + "Installed version: v" + $PackageUpdateInfo.VersionInstalled + "$(if (-not $PackageUpdateInfo.HasReleaseNotes) { "`n(No release notes available)" })"
        if ($PackageUpdateInfo.IsCurrentUserPath) {
            $toastText += "This is a user specific module."
        } else {
            $toastText += "This is machine wide module."
        }

        # The logo
        if ($PackageUpdateInfo.IconUri) {
            $iconPath = Join-Path -Path $script:ModuleTempPath -ChildPath $PackageUpdateInfo.IconUri.Segments[-1]
            if (Test-Path -Path $iconPath) { Remove-Item -Path $iconPath -Force -ErrorAction:SilentlyContinue }

            try {
                Invoke-WebRequest -Uri $PackageUpdateInfo.IconUri -OutFile $iconPath -SkipCertificateCheck -SkipHeaderValidation -UseBasicParsing -ErrorAction Stop
                $toastLogo = $iconPath
            } catch {
                Write-Verbose -Message "Warning! Unable to get icon from '$($PackageUpdateInfo.IconUri)' for module '$($PackageUpdateInfo.Name)'"
                $toastLogo = $script:ModuleIconPath
            }
        } else {
            $toastLogo = $script:ModuleIconPath
        }

        # The buttons
        $toastButton = @()

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

        # Create the toast notification
        $notificationParams = @{
            Header  = $toastHeader
            Text    = $toastText
            AppLogo = $toastLogo
            Button  = $toastButton
        }

        New-BurntToastNotification @notificationParams

    }

    end {}
}