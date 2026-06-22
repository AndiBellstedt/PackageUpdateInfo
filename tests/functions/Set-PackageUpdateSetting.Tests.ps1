BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Set-PackageUpdateSetting - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Set-PackageUpdateSetting -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'ExcludeModuleFromChecking',
            'IncludeModuleForChecking',
            'ReportChangeOnMajor',
            'ReportChangeOnMinor',
            'ReportChangeOnBuild',
            'ReportChangeOnRevision',
            'UpdateCheckInterval',
            'LastCheck',
            'LastSuccessfulCheck',
            'InputObject',
            'Reset',
            'Path',
            'PassThru'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }

    It 'uses the expected parameter types for the core settings' {
        $command.Parameters['Reset'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
        $command.Parameters['PassThru'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
        $command.Parameters['UpdateCheckInterval'].ParameterType.FullName | Should -Be 'System.TimeSpan'
    }
}

Describe 'Set-PackageUpdateSetting - Functionality' {
    BeforeEach {
        $script:settingsPath = Join-Path $TestDrive 'PackageUpdateSetting.json'
    }

    It 'creates a default settings file when reset is requested' {
        $settings = Set-PackageUpdateSetting -Reset -Path $script:settingsPath -PassThru

        $settings | Should -Not -BeNullOrEmpty
        $settings.Path | Should -Be $script:settingsPath
        Test-Path -Path $script:settingsPath | Should -BeTrue
    }

    It 'updates the include filter and persists it to disk' {
        $null = Set-PackageUpdateSetting -Reset -Path $script:settingsPath -PassThru | Out-Null
        $null = Set-PackageUpdateSetting -Path $script:settingsPath -IncludeModuleForChecking 'Pester' -PassThru | Out-Null

        $settings = Get-PackageUpdateSetting -Path $script:settingsPath
        $settings.DefaultRule.IncludeModuleForChecking | Should -Contain 'Pester'
    }
}
