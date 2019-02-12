@{
    # Script module or binary module file associated with this manifest
    ModuleToProcess = 'PackageUpdateInfo.psm1'

    # Version number of this module.
    ModuleVersion = '1.1.1.0'

    # ID used to uniquely identify this module
    GUID = '1f216c97-d110-4d88-bc30-ec850757a256'

    # Author of this module
    Author = 'Andreas Bellstedt'

    # Company or vendor of this module
    CompanyName = ' '

    # Copyright statement for this module
    Copyright = 'Copyright (c) 2018 Andreas Bellstedt'

    # Description of the functionality provided by this module
    Description = 'Module to version check all installed modules. Helps to stay up-to-date with further developing on modules in the community'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules = @(
        @{ ModuleName='BurntToast'; ModuleVersion='0.6.3' }
    )

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies = @('bin\PackageUpdateInfo.dll')

    # Type files (.ps1xml) to be loaded when importing this module
    # Expensive for import time, no more than one should be used.
    TypesToProcess = @('xml\PackageUpdateInfo.Types.ps1xml')

    # Format files (.ps1xml) to be loaded when importing this module.
    # Expensive for import time, no more than one should be used.
    FormatsToProcess = @('xml\PackageUpdateInfo.Format.ps1xml')

    # Functions to export from this module
    FunctionsToExport = @(
        'Get-PackageUpdateInfo',
        'Export-PackageUpdateInfo',
        'Import-PackageUpdateInfo'
    )

    # Cmdlets to export from this module
    CmdletsToExport = ''

    # Variables to export from this module
    VariablesToExport = ''

    # Aliases to export from this module
    AliasesToExport = @(
        'gpui',
        'epui',
        'ipui'
    )

    # List of all files packaged with this module
    FileList = @()

    # Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        #Support for PowerShellGet galleries.
        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('ModuleUpdateInfo', 'ModuleUpdate', 'ModuleUpdater', 'PSGallery', 'Updater', 'Updates', 'Update', 'Package', 'Packages', 'UpdateManagement', "UpdateMgmt", 'UpdMgmt')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/AndiBellstedt/PackageUpdateInfo/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/AndiBellstedt/PackageUpdateInfo'

            # A URL to an icon representing this module.
            IconUri = 'https://github.com/AndiBellstedt/PackageUpdateInfo/raw/Development/assets/PackageUpdateInfo_128x128.png'

            # ReleaseNotes of this module
            ReleaseNotes = 'https://github.com/AndiBellstedt/PackageUpdateInfo/blob/master/PackageUpdateInfo/changelog.md'

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}