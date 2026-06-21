BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
    . (Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\internal\functions\Get-PackageUpdateInfo\Get-VersionDifference.ps1')
    . (Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\internal\functions\Get-PackageUpdateInfo\Test-UpdateIsNeeded.ps1')
}

Describe 'Test-UpdateIsNeeded - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Test-UpdateIsNeeded
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'ModuleLocal',
            'ModuleOnline'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }
}

Describe 'Test-UpdateIsNeeded - Functionality' {
    BeforeEach {
        Mock Get-PackageUpdateRule {
            [pscustomobject]@{ Id = 1; ExcludeModuleFromChecking = @(''); IncludeModuleForChecking = @('*'); ReportChangeOnMajor = $true; ReportChangeOnMinor = $true; ReportChangeOnBuild = $true; ReportChangeOnRevision = $true }
        }
    }

    It 'returns true when the online version is newer than the installed version' {
        $local = [pscustomobject]@{ Name = 'Pester'; Version = [version]'4.10.0' }
        $online = [pscustomobject]@{ Name = 'Pester'; Version = [version]'4.11.0' }

        $result = Test-UpdateIsNeeded -ModuleLocal $local -ModuleOnline $online

        $result | Should -BeTrue
    }

    It 'returns false when the installed version is newer or the same' {
        $local = [pscustomobject]@{ Name = 'Pester'; Version = [version]'4.11.0' }
        $online = [pscustomobject]@{ Name = 'Pester'; Version = [version]'4.11.0' }

        $result = Test-UpdateIsNeeded -ModuleLocal $local -ModuleOnline $online

        $result | Should -BeFalse
    }
}
