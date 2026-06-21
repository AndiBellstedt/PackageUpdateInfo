BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Get-PackageUpdateRule - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Get-PackageUpdateRule -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'Id',
            'IncludeModuleForChecking',
            'ExcludeModuleFromChecking',
            'IncludeDefaultRule',
            'SettingObject'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }

    It 'uses the expected parameter types for rule filtering' {
        $command.Parameters['Id'].ParameterType.FullName | Should -Be 'System.Int32[]'
        $command.Parameters['IncludeDefaultRule'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
    }
}

Describe 'Get-PackageUpdateRule - Functionality' {
    BeforeEach {
        $script:settingsPath = Join-Path $TestDrive 'PackageUpdateSetting.json'
        $null = Set-PackageUpdateSetting -Reset -Path $script:settingsPath -PassThru | Out-Null
        $null = Add-PackageUpdateRule -SettingObject (Get-PackageUpdateSetting -Path $script:settingsPath) -Id 17 -IncludeModuleForChecking 'Pester' -PassThru | Out-Null
    }

    It 'returns the configured custom rules and the default rule when requested' {
        $rules = Get-PackageUpdateRule -SettingObject (Get-PackageUpdateSetting -Path $script:settingsPath) -IncludeDefaultRule

        $rules.Count | Should -BeGreaterThan 1
        ($rules | Where-Object Id -eq 17).IncludeModuleForChecking | Should -Contain 'Pester'
        ($rules | Where-Object Id -eq 0).IncludeModuleForChecking | Should -Contain '*'
    }
}
