BeforeAll {
    $moduleManifest = Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\PackageUpdateInfo.psd1'
    Import-Module $moduleManifest -Force
    . (Join-Path $PSScriptRoot '..\..\PackageUpdateInfo\internal\functions\Show-PackageUpdateReleaseNotes\Assert-PossibleReleaseNotesURI.ps1')
}

Describe 'Assert-PossibleReleaseNotesURI - Parameter Contract' {
    BeforeAll {
        $command = Get-Command -Name Assert-PossibleReleaseNotesURI
    }

    It 'exposes the expected parameters' {
        $expectedParameters = @(
            'URI'
        )

        foreach ($parameterName in $expectedParameters) {
            $command.Parameters.ContainsKey($parameterName) | Should -BeTrue -Because "$parameterName should exist"
        }
    }
}

Describe 'Assert-PossibleReleaseNotesURI - Functionality' {
    It 'accepts a valid release notes URI' {
        $result = Assert-PossibleReleaseNotesURI -URI 'https://github.com/owner/repo'

        $result | Should -BeTrue
    }

    It 'rejects a malformed URI' {
        $result = Assert-PossibleReleaseNotesURI -URI 'not-a-uri'

        $result | Should -BeFalse
    }
}
