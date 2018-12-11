# PackageUpdatesInfo
The PackageUpdatesInfo module helps you staying up to date with you installed modules. It checks all your local installed powershell modules and output a table with module names and version information.

## Installation
Install the module from the PowerShell Gallery (systemwide):

    Install-Module PackageUpdateInfo

or install it only for your user:

    Install-Module PackageUpdateInfo -Scope CurrentUser

## Interactive usage
For interactive usage and check all your modules, just run:

    Get-PackageUpdateInfo

This will query all your installed modules and display a overview table which module will need an update and which one is up-to-date.


## Practical usage
Because of -possibly- forgotting to run the command frequently, like once a day or one a week, and of poor performance with a lot of installed moduels, I suggest to automate this one.
So it is possible to **export** and **import** the Update-Information.

    Get-PackageUpdateInfo | Export-PackageUpdateInfo
    Import-PackageUpdateInfo

So with this, it is possible to "offload" the update checking to a Job, a scheduled task or the computer startup and show the information quickly with the **Import-PackageUpdateInfo** command.

I'll suggest to put these lines to you PowerShell profile:

    Start-Job -ScriptBlock { Get-PackageUpdateInfo -ShowOnlyNeededUpdate | Export-PackageUpdateInfo } | Out-Null

    Import-PackageUpdateInfo

This will start the update checking as a background job and show's you quickly the information from the last job run on every startup of the powershell.

## References
The following modules and code snipets inspired me. My goal was to do a short module with rich, powershell styled output and powershell styled functionality.

* The module is inspired by Jan De Dobbeleer
https://github.com/JanDeDobbeleer/Get-PackageUpdates
* Inspired by and partially stolen from http://jdhitsolutions.com/blog/powershell/5441/check-for-module-updates/
