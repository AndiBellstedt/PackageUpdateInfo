# Changelog
# 1.1.1.0
- Fix: Command Get-PackageUpdateInfo
    - Fix Issure #11 - error on command, when more than 63 modules are installed. The command Find-Module only accept a maximum number of 63 strings in Name command. Workarround with a fearch-each loop arround this one

# 1.1.0.0
- New: command Get-PackageUpdateInfo
    - Possibility to push ToastNotification for update infos with BurnToast module by specifing '-ShowToastNotification' switch
- New: Dependancy to module 'BurntToast'
- Udp: Add Description info on PackUpdate.Info objects
- Fix: command Get-PackageUpdateInfo
    - In 1.0.2.0 ReleaseNotes and PublishDate of all modules were put into every PackageUpdate.Info. Used wrong variable. fixed.
    - minor change in debug output on version comparision

# 1.0.2.0
- New: Add changelog ;-)
- Upd: Command Get-PackageUpdateInfo
    - add properties on output object
        - ProjectUri
        - IconUri
        - ReleaseNotes
        - Author
        - PublishedDate
- Upd: Reformat code to meet codestyle OTBS - K&R(One True Brace Style variant)

# 1.0.1.0
- Initial realse