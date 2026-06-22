BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
    . (Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\internal\functions\Set-PackageUpdateSetting\ConvertTo-PackageUpdateSetting.ps1')
}

Describe 'ConvertTo-PackageUpdateSetting - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name ConvertTo-PackageUpdateSetting
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

Describe 'ConvertTo-PackageUpdateSetting - Functionality' {
    It 'serializes a settings object to a hashtable' {
        $source = [pscustomobject]@{
            DefaultRule         = [pscustomobject]@{ IncludeModuleForChecking = @('*'); ExcludeModuleFromChecking = @(); ReportChangeOnMajor = $true; ReportChangeOnMinor = $true; ReportChangeOnBuild = $true; ReportChangeOnRevision = $true }
            CustomRule          = @([pscustomobject]@{ Id = 5; IncludeModuleForChecking = @('Pester') })
            UpdateCheckInterval = [timespan]'01:00:00'
        }

        $result = ConvertTo-PackageUpdateSetting -InputObject $source
        $result.DefaultRule.IncludeModuleForChecking | Should -Contain '*'
        $result.CustomRule[0].Id | Should -Be 5
    }
}
