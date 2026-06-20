# Changelog

## 1.2.6.0

### Changed
- **Fix** Removed unintended dependency to PSFramework module in the PackageUpdateInfo.psm1 file. This was a leftover from refactoring a while ago. This module is explicitly intended to run without PSFramework. (even I very appreciate PSFramework and use it in many of my projects)



## 1.2.5.0

### Changed
- Command *Get-PackageUpdateInfo*
  - **Fix** Issue [#33](https://github.com/AndiBellstedt/PackageUpdateInfo/issues/33) - Command ignores ExcludeModuleFromChecking
  - Optimize filtering for module checking against galleries
  - Optimize filtering to fit requirement on issue [#33](https://github.com/AndiBellstedt/PackageUpdateInfo/issues/33)
- Command *Set-PackageUpdateSetting*
    - Add examples in the documentation. 
    **Please read the examples** before putting anything on the exclusion list



## 1.2.4.0

### Changed
- **Fix** Issue [#24](https://github.com/AndiBellstedt/PackageUpdateInfo/issues/24) - Module version number 1.9 is higher than 1.10. 
  The online gallery probably delivers version information not as a 'version' type, but as a string.



## 1.2.3.0

### Changed
- **Fix** Issue [#24](https://github.com/AndiBellstedt/PackageUpdateInfo/issues/24) - Problem on running PSEdition core & desktop in parallel
    - Export/Import commands now writes version specific files by default (e.g. PackageUpdateInfo_Desktop_5.xml)
- **Fix** Issue [#25](https://github.com/AndiBellstedt/PackageUpdateInfo/issues/25) - *Export-PackageUpdateInfo* -PassThru
    - fix output issue and date conversion bug


## 1.2.2.0

### Changed
- Command *Add-PackageUpdateRule*
    - Parameter PassThru now actually works as intended.
- **Fix** Fixing some typos
- **Fix** Remove files and command depend on PSFramework
- Add plattform and statistic information to readme file



## 1.2.1.0

### Changed
- **Fix** Ugly error messages, if no configuration file existis due to fresh system installation.
    - Implementented check and warning messages on this behaviour
    - Add init routine in module loading, if no default config file is present
- Command *Get-PackageUpdateInfo*
  - Try to supress verbose messesages on module up-to-dateness checking



## 1.2.0.0

### Added
- Enabling CORE and cross-platform compatibility
  - Doing code refactoring to bring PackageUpdateInfo into PowerShell version 6 & 7 (CORE)
  - Module now also runs on linux systems
- Add command *Show-PackageUpdateReleaseNote*
  - Possibility to get release notes from websites and display it on the console
- Add command *Get-PackageUpdateSetting*
  - Query the basic settings for check and report on up-to-dateness information on installed modules. This is how *Get-PackageUpdateInfo* will check on modules.
  - There is a 'UpdateCheckInterval' to set, how often *Get-PackageUpdateInfo* seeks out for query updates on modules. Default is once per hour (01:00:00)
  - There is a 'DefaultRule' for general checking on
    - which module to include/exclude in checking
    - which part of the version number has to change to report as 'update-needed' (major, minor, build, revision)
- Add command *Set-PackageUpdateSetting*
  - The command configures basic settings for check and report on up-to-dateness information on installed modules. (look previous bullet point)
- Add command *Add-PackageUpdateRule*
  - This command allows to declare how a modules is handled in reporting for special.
  - For example, you can configure PackageUpdateINfo to suppress revision updates on a frequent updated module, so that only build, minor or major updates are reportet as "update needed".
- Add command *Get-PackageUpdateRul*
  - This command get the existing custom rule(s) how modules are handled in reporting.
- Add command *Set-PackageUpdateRule*
    - This command allows to edit existing rules on how a modules is handled in reporting.
- Add command *Remove-PackageUpdateRule*
  - This command remove existing custom rule(s) on how a modules is handled in reporting.

### Changed
- Remove dependency on module BurntToast
  - For now, BurntToast is a optional module in PackageUpdateInfo
  - Toast notifications are available on Windows 10 in 'Windows PowerShell' and 'PowerShell' (Core)



## 1.1.1.0

### Changed
- Command *Get-PackageUpdateInfo*
    - **Fix** Issue [#11](https://github.com/AndiBellstedt/PackageUpdateInfo/issues/11) - error on command, when more than 63 modules are installed. The command *Find-Module* only accept a maximum number of 63 strings in Name command. Workarround with a fearch-each loop arround this one



## 1.1.0.0

### Added
- Module dependancy to the module *BurntToast*
- Command *Get-PackageUpdateInfo*
  - Possibility to push ToastNotification for update infos with BurnToast module by specifing '-ShowToastNotification' switch

### Changed
- Add Description info on PackUpdate.Info objects
- Command *Get-PackageUpdateInfo*
  - **Fix** In 1.0.2.0 ReleaseNotes and PublishDate of all modules were put into every PackageUpdate.Info. Used wrong variable. fixed.
  - Minor change in debug output on version comparision



## 1.0.2.0

### Added
- Add the changelog itself 😉

### Changed
- Command *Get-PackageUpdateInfo*
    - add properties on output object
        - ProjectUri
        - IconUri
        - ReleaseNotes
        - Author
        - PublishedDate
- Reformat code to meet codestyle OTBS - K&R(One True Brace Style variant)



## 1.0.1.0

### Added
- Initial release