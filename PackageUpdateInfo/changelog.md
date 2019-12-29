# Changelog
# 1.2.0.0
- New: Enabling CORE and cross-platform compatibility
    - Doing code refactoring to bring PackageUpdateInfo into PowerShell version 6 & 7 (CORE)
    - Module now also runs on linux systems
- Upd: Remove dependency on module BurntToast
    - For now, BurntToast is a optional module in PackageUpdateInfo
    - Toast notifications are available on Windows 10 in 'Windows PowerShell' and 'PowerShell' (Core)
- New: Add command *Show-PackageUpdateReleaseNote*
    - Possibility to get release notes from websites and display it on the console
- New: Add command *Get-PackageUpdateSetting*
    - Query the basic settings for check and report on up-to-dateness information on installed modules. This is how *Get-PackageUpdateInfo* will check on modules.
    - There is a 'UpdateCheckInterval' to set, how often *Get-PackageUpdateInfo* seeks out for query updates on modules.\
    Default is once per hour (01:00:00)
    - There is a 'DefaultRule' for general checking on
        - which module to include/exclude in checking
        - which part of the version number has to change to report as 'update-needed' (major, minor, build, revision)
- New: Add command *Set-PackageUpdateSetting*
    - The command configures basic settings for check and report on up-to-dateness information on installed modules. (look previous bullet point)
- New: Add command *Add-PackageUpdateRule*
    - This command allows to declare how a modules is handled in reporting for special.
    - For example, you can configure PackageUpdateINfo to suppress revision updates on a frequent updated module, so that only build, minor or major updates are reportet as "update needed".
- New: Add command *Get-PackageUpdateRul*
    - This command get the existing custom rule(s) how modules are handled in reporting.
- New: Add command *Set-PackageUpdateRule*
    - This command allows to edit existing rules on how a modules is handled in reporting.
- New: Add command *Remove-PackageUpdateRule*
    - This command remove existing custom rule(s) on how a modules is handled in reporting.

# 1.1.1.0
- Fix: Command *Get-PackageUpdateInfo*
    - Fix Issure #11 - error on command, when more than 63 modules are installed. The command *Find-Module* only accept a maximum number of 63 strings in Name command. Workarround with a fearch-each loop arround this one

# 1.1.0.0
- New: command *Get-PackageUpdateInfo*
    - Possibility to push ToastNotification for update infos with BurnToast module by specifing '-ShowToastNotification' switch
- New: Dependancy to module *BurntToast*
- Udp: Add Description info on PackUpdate.Info objects
- Fix: command *Get-PackageUpdateInfo*
    - In 1.0.2.0 ReleaseNotes and PublishDate of all modules were put into every PackageUpdate.Info. Used wrong variable. fixed.
    - minor change in debug output on version comparision

# 1.0.2.0
- New: Add changelog ;-)
- Upd: Command *Get-PackageUpdateInfo*
    - add properties on output object
        - ProjectUri
        - IconUri
        - ReleaseNotes
        - Author
        - PublishedDate
- Upd: Reformat code to meet codestyle OTBS - K&R(One True Brace Style variant)

# 1.0.1.0
- Initial realse