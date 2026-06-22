BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Remove-PackageUpdateRule - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Remove-PackageUpdateRule -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'Id',
            'InputObject',
            'Force',
            'PassThru',
            'SettingObject'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }

    It 'uses the expected parameter types for object removal' {
        $command.Parameters['Id'].ParameterType.FullName | Should -Be 'System.Int32[]'
        $command.Parameters['Force'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
    }
}

Describe 'Remove-PackageUpdateRule - Functionality' {
    BeforeEach {
        $script:settingsPath = Join-Path $TestDrive 'PackageUpdateSetting.json'
        $null = Set-PackageUpdateSetting -Reset -Path $script:settingsPath -PassThru | Out-Null
        $null = Add-PackageUpdateRule -SettingObject (Get-PackageUpdateSetting -Path $script:settingsPath) -Id 7 -IncludeModuleForChecking 'Pester' -PassThru | Out-Null
    }

    It 'removes a rule from the settings object when the matching Id is supplied' {
        $settings = Get-PackageUpdateSetting -Path $script:settingsPath
        $null = Remove-PackageUpdateRule -Id 7 -SettingObject $settings -Force

        $updatedSettings = Get-PackageUpdateSetting -Path $script:settingsPath
        ($updatedSettings.CustomRule | Measure-Object).Count | Should -Be 0
    }
}
