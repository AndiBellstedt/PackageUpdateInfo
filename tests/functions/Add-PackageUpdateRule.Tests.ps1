BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Add-PackageUpdateRule - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Add-PackageUpdateRule -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'Id',
            'IncludeModuleForChecking',
            'ExcludeModuleFromChecking',
            'ReportChangeOnMajor',
            'ReportChangeOnMinor',
            'ReportChangeOnBuild',
            'ReportChangeOnRevision',
            'SettingObject',
            'PassThru'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }

    It 'uses the expected parameter types for the core options' {
        $command.Parameters['Id'].ParameterType.FullName | Should -Be 'System.Int32'
        $command.Parameters['IncludeModuleForChecking'].ParameterType.FullName | Should -Be 'System.String[]'
        $command.Parameters['ExcludeModuleFromChecking'].ParameterType.FullName | Should -Be 'System.String[]'
        $command.Parameters['PassThru'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
    }
}

Describe 'Add-PackageUpdateRule - Functionality' {
    BeforeEach {
        $script:settingsPath = Join-Path $TestDrive 'PackageUpdateSetting.json'
        $null = Set-PackageUpdateSetting -Reset -Path $script:settingsPath -PassThru | Out-Null
    }

    It 'adds a custom rule to the settings object and persists it' {
        $settings = Get-PackageUpdateSetting -Path $script:settingsPath
        $rule = Add-PackageUpdateRule -SettingObject $settings -Id 99 -IncludeModuleForChecking 'Pester' -ReportChangeOnMajor $true -ReportChangeOnMinor $false -ReportChangeOnBuild $false -ReportChangeOnRevision $false -PassThru

        $rule.Id | Should -Be 99
        $rule.IncludeModuleForChecking | Should -Contain 'Pester'
        $rule.ReportChangeOnMajor | Should -BeTrue
        $rule.ReportChangeOnMinor | Should -BeFalse

        $savedSettings = Get-PackageUpdateSetting -Path $script:settingsPath
        $savedSettings.CustomRule.Id | Should -Contain 99
    }
}
