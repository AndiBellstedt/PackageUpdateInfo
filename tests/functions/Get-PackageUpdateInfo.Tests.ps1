BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Get-PackageUpdateInfo - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Get-PackageUpdateInfo -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'Name',
            'Repository',
            'ShowOnlyNeededUpdate',
            'ShowToastNotification',
            'CurrentUser',
            'AllUsers',
            'Force'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }

    It 'uses the expected parameter types for the switches' {
        $command.Parameters['ShowOnlyNeededUpdate'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
        $command.Parameters['CurrentUser'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
        $command.Parameters['Force'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
    }
}

Describe 'Get-PackageUpdateInfo - Functionality' {
    BeforeEach {
        $script:settingsPath = Join-Path $TestDrive 'PackageUpdateSetting.json'
        $null = Set-PackageUpdateSetting -Reset -Path $script:settingsPath -PassThru | Out-Null
        InModuleScope PackageUpdateInfo -ScriptBlock {
            param($path)
            $script:ModuleSettingPath = $path
        } -ArgumentList $script:settingsPath

        Mock -ModuleName PackageUpdateInfo Get-PSRepository {
            [pscustomobject]@{ Name = 'PSGallery'; SourceLocation = 'https://www.powershellgallery.com/api/v2' }
        }
        Mock -ModuleName PackageUpdateInfo Get-Module {
            [pscustomobject]@{ Name = 'Pester'; Version = [version]'4.10.0'; RepositorySourceLocation = 'https://www.powershellgallery.com/api/v2'; ModuleBase = 'C:\Modules\Pester\4.10.0' }
        }
        Mock -ModuleName PackageUpdateInfo Find-Module {
            [pscustomobject]@{ Name = 'Pester'; Version = [version]'4.11.0'; ProjectUri = 'https://example.test'; IconUri = 'https://example.test/icon'; ReleaseNotes = 'https://example.test/release'; Author = 'Test Author'; PublishedDate = '2024-01-01'; Description = 'Test description' }
        }
        Mock -ModuleName PackageUpdateInfo Get-PackageUpdateRule {
            [pscustomobject]@{ Id = 1; ExcludeModuleFromChecking = @(''); IncludeModuleForChecking = @('*'); ReportChangeOnMajor = $true; ReportChangeOnMinor = $true; ReportChangeOnBuild = $true; ReportChangeOnRevision = $true }
        }
    }

    It 'returns update information for a module that has a newer online version' {
        $result = Get-PackageUpdateInfo -Name 'Pester' -Force

        $result | Should -Not -BeNullOrEmpty
        $result.Name | Should -Be 'Pester'
        $result.NeedUpdate | Should -BeTrue
        $result.VersionInstalled | Should -Be ([version]'4.10.0')
        $result.VersionOnline | Should -Be ([version]'4.11.0')
    }
}
