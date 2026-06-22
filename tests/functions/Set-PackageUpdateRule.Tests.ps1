BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Set-PackageUpdateRule - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Set-PackageUpdateRule -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'Id',
            'InputObject',
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

    It 'uses the expected parameter types for the reporting switches' {
        $command.Parameters['ReportChangeOnMajor'].ParameterType.FullName | Should -Be 'System.Boolean'
        $command.Parameters['PassThru'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
    }
}

Describe 'Set-PackageUpdateRule - Functionality' {
    BeforeEach {
        $script:settingsPath = Join-Path $TestDrive 'PackageUpdateSetting.json'
        $null = Set-PackageUpdateSetting -Reset -Path $script:settingsPath -PassThru | Out-Null
        $null = Add-PackageUpdateRule -SettingObject (Get-PackageUpdateSetting -Path $script:settingsPath) -Id 9 -IncludeModuleForChecking 'Pester' -PassThru | Out-Null
    }

    It 'updates an existing rule and persists the change' {
        $settings = Get-PackageUpdateSetting -Path $script:settingsPath
        $null = Set-PackageUpdateRule -Id 9 -SettingObject $settings -ExcludeModuleFromChecking 'PowerShellGet' -ReportChangeOnRevision $false -PassThru | Out-Null

        $updatedSettings = Get-PackageUpdateSetting -Path $script:settingsPath
        $updatedRule = $updatedSettings.CustomRule | Where-Object Id -eq 9

        $updatedRule | Should -Not -BeNullOrEmpty
        $updatedRule.ExcludeModuleFromChecking | Should -Contain 'PowerShellGet'
        $updatedRule.ReportChangeOnRevision | Should -BeFalse
    }
}
