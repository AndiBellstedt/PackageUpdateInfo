BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
    . (Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\internal\functions\Get-PackageUpdateInfo\Get-VersionDifference.ps1')
}

Describe 'Get-VersionDifference - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Get-VersionDifference
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'LowerVersion',
            'HigherVersion'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }
}

Describe 'Get-VersionDifference - Functionality' {
    It 'subtracts the lower version from the higher version and returns the difference' {
        $result = Get-VersionDifference -LowerVersion '1.2.3.4' -HigherVersion '2.3.4.5'

        $result | Should -Be ([version]'1.1.1.1')
    }
}
