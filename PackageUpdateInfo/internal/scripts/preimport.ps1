# Place all code that should be run before functions are imported here


#region try to import module BurntToast, to enable Windows 10 Toast Notifications
$optionalModule = @{
    ModuleName    = 'BurntToast'
    ModuleVersion = '0.6.3'
}
$script:EnableToastNotification = $true

$moduleToLoad = Get-Module -Name $optionalModule.ModuleName -ListAvailable | Where-Object { $_.Version -ge [version]$optionalModule.ModuleVersion } | Sort-Object -Property Version | Select-Object -Last 1
if ($moduleToLoad) {
    try {
        $moduleToLoad | Import-Module -ErrorAction Stop
    } catch {
        Write-Warning "Fail to import optional module $($moduleToLoad.Name) ($($moduleToLoad.Version)). Unable to show Toast Notifications even when the module is present."
        $script:EnableToastNotification = $false
    }
} else {
    if (($PSVersionTable.PSEdition -like "Desktop") -or ($PSVersionTable.PSEdition -like "Core" -and $isWindows)) {
        if ((Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue).Version -ge [version]'10.0') {
            Write-Warning "Missing the optional module '$($optionalModule.ModuleName)'. Unable to show Toast Notifications."
            Write-Warning "It is recommended to install module $($optionalModule.ModuleName) (min. v$($optionalModule.ModuleVersion)) to enable the possibility to enable Windows 10 toast notication for PackageUpdateInfo."
            Write-Warning "( Install-Module -Name $($optionalModule.ModuleName) -MinimumVersion $($optionalModule.ModuleVersion) )"
        }
    }
    $script:EnableToastNotification = $false
}
#endregion try to import module BurntToast, to enable Windows 10 Toast Notifications