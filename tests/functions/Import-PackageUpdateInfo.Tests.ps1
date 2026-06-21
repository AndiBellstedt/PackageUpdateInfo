BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Import-PackageUpdateInfo - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Import-PackageUpdateInfo -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'Path',
            'ShowToastNotification',
            'InputFormat',
            'Encoding'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }

    It 'uses the expected parameter types for import options' {
        $command.Parameters['ShowToastNotification'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
        $command.Parameters['InputFormat'].ParameterType.FullName | Should -Be 'System.String'
    }
}

Describe 'Import-PackageUpdateInfo - Functionality' {
    BeforeEach {
        $script:importPath = Join-Path $TestDrive 'updates.xml'
        $sampleObject = [PackageUpdate.Info]@{
            Name             = 'Pester'
            Repository       = 'PSGallery'
            VersionInstalled = [version]'4.10.0'
            VersionOnline    = [version]'4.11.0'
            NeedUpdate       = $true
            Path             = 'C:\Modules\Pester'
            ProjectUri       = 'https://example.test'
            IconUri          = 'https://example.test/icon'
            ReleaseNotes     = 'https://example.test/release'
            Author           = 'Test Author'
            PublishedDate    = [datetime]'2024-01-01'
            Description      = 'Test description'
        }
        $sampleObject | Export-Clixml -Path $script:importPath
    }

    It 'imports the exported data and returns PackageUpdateInfo objects' {
        $result = Import-PackageUpdateInfo -Path $script:importPath

        $result | Should -Not -BeNullOrEmpty
        $result.Name | Should -Contain 'Pester'
    }
}
