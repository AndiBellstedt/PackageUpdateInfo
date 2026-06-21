BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
}

Describe 'Export-PackageUpdateInfo - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Export-PackageUpdateInfo -Module PackageUpdateInfo
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'InputObject',
            'Path',
            'OutputFormat',
            'Encoding',
            'Force',
            'Append',
            'IncludeTimeStamp',
            'PassThru'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }

    It 'uses the expected parameter types for file export options' {
        $command.Parameters['InputObject'].ParameterType.FullName | Should -Be 'PackageUpdate.Info[]'
        $command.Parameters['OutputFormat'].ParameterType.FullName | Should -Be 'System.String'
        $command.Parameters['Force'].ParameterType.FullName | Should -Be 'System.Management.Automation.SwitchParameter'
    }
}

Describe 'Export-PackageUpdateInfo - Functionality' {
    BeforeEach {
        $script:exportPath = Join-Path $TestDrive 'updates.xml'
        $script:inputObject = [PackageUpdate.Info]@{
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
    }

    It 'exports PackageUpdateInfo objects to XML and returns them when requested' {
        $result = Export-PackageUpdateInfo -InputObject $script:inputObject -Path $script:exportPath -PassThru

        $result | Should -Not -BeNullOrEmpty
        Test-Path -Path $script:exportPath | Should -BeTrue
        (Import-Clixml -Path $script:exportPath).Name | Should -Contain 'Pester'
    }
}
