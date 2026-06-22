BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Show-PackageUpdateReleaseNote - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Show-PackageUpdateReleaseNote -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'InputObject',
            'Module'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }

    It 'uses the expected parameter types for the supported inputs' {
        $command.Parameters['InputObject'].ParameterType.FullName | Should -Be 'PackageUpdate.Info[]'
        $command.Parameters['Module'].ParameterType.FullName | Should -Be 'System.Management.Automation.PSModuleInfo[]'
    }
}

Describe 'Show-PackageUpdateReleaseNote - Functionality' {
    BeforeEach {
        $script:info = [PackageUpdate.Info]@{
            Name          = 'Pester'
            VersionOnline = [version]'4.11.0'
            ReleaseNotes  = 'https://example.test/release'
        }
    }

    It 'returns a release-note object for a PackageUpdateInfo input' {
        $result = Show-PackageUpdateReleaseNote -InputObject $script:info -WhatIf

        $result | Should -BeNullOrEmpty
    }
}
