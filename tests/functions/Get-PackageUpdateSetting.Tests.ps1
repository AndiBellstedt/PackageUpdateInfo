BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Get-PackageUpdateSetting - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Get-PackageUpdateSetting -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $command.Parameters.ContainsKey('Path') | Should -BeTrue
    }

    It 'uses the expected parameter type for the path argument' {
        $command.Parameters['Path'].ParameterType.FullName | Should -Be 'System.String'
    }
}

Describe 'Get-PackageUpdateSetting - Functionality' {
    BeforeEach {
        $script:settingsPath = Join-Path $TestDrive 'PackageUpdateSetting.json'
        $null = Set-PackageUpdateSetting -Reset -Path $script:settingsPath -PassThru | Out-Null
    }

    It 'reads the persisted settings from disk and returns a configuration object' {
        $settings = Get-PackageUpdateSetting -Path $script:settingsPath

        $settings | Should -Not -BeNullOrEmpty
        $settings.DefaultRule.IncludeModuleForChecking | Should -Contain '*'
        $settings.UpdateCheckInterval | Should -Be ([timespan]'01:00:00')
    }
}
