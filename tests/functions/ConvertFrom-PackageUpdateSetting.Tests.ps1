BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
    . (Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\internal\functions\Set-PackageUpdateSetting\ConvertFrom-PackageUpdateSetting.ps1')
}

Describe 'ConvertFrom-PackageUpdateSetting - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name ConvertFrom-PackageUpdateSetting
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'InputObject'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }
}

Describe 'ConvertFrom-PackageUpdateSetting - Functionality' {
    It 'returns a settings object from a hashtable input' {
        $source = @{
            DefaultRule         = @{
                IncludeModuleForChecking  = @('*')
                ExcludeModuleFromChecking = @()
                ReportChangeOnMajor       = $true
                ReportChangeOnMinor       = $true
                ReportChangeOnBuild       = $true
                ReportChangeOnRevision    = $true
            }
            CustomRule          = @(@{ Id = 5; IncludeModuleForChecking = @('Pester') })
            UpdateCheckInterval = [timespan]'01:00:00'
        }

        $result = ConvertFrom-PackageUpdateSetting -InputObject $source
        $result.DefaultRule.IncludeModuleForChecking | Should -Contain '*'
        $result.CustomRule.Id | Should -Contain 5
    }
}
