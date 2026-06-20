# PackageUpdateInfo - AI Agent Guide


## Project Overview
PowerShell module that provides cmdlets for retrieving and managing update information for PowerShell modules. It includes features such as checking for available updates, displaying update details, and configuring update settings.



## Architecture

### Repository Structure
```
Root/
├── .github/                # GitHub- and AI-Agent specific files
│   ├── agents/             # AI agent configuration files (e.g. for Copilot, CodeWhisperer)
│   ├── diagrams/           # Architecture and design diagrams
│   ├── instructions/       # Instructions for AI agents (e.g. PowerShell coding standards, github-actions standards, security standards, etc.)
│   ├── planning/            # Project planning documents (roadmap, milestones, etc.)
│   ├── prompts/             # Reusable prompt templates for AI agents
│   ├── skills/              # Custom skills for AI agents (e.g. code analysis, test generation, etc.)
│   └── workflows/           # GitHub Actions workflow definitions
├── assets/                 # repo specific assets for documentation and repo itself (icons, images, etc.)
├── build/                  # Build scripts and configuration
├── PackageUpdateInfo/      # PowerShell module source code. (See section Module Structure)
├── tests/                  # Pester tests
├── config.psd1             # Configuration file for build and release settings
├── install.ps1             # Optional installation script for local development.
├── LICENSE.md              # License file (MIT License)
├── README.md               # Project overview and documentation
└── SECURITY.md             # Security policy and contact information
```


### Module Structure
```
PackageUpdateInfo/
├── assets/                 # Module specific assets (icons, images, etc.)
├── bin/                    # Compiled module output (after build)
├── en-us/                  # localized about file (txt) for the module (English)
├── functions/              # Public exported functions (1 function per file)
├── internal/
│   ├── functions/          # Private helper functions (not exported)
│   └── scripts/            # Module initialization scripts (run once on import)
├── xml/                    # XML files for help or other structured data
├── changelog.md            # Changelog for the module with version specific entries
├── PackageUpdateInfo.psd1  # Module manifest
└── PackageUpdateInfo.psm1  # Module script (do not touch, template with auto-sourcing logic)
```

**Important**: Do not confuse the `assets/` directory at the root level (for repo documentation) with the `assets/` directory inside the module (for module-specific icons and images). If any logic inside the module source folder needs to reference the module assets, use `PackageUpdateInfo/assets/` folder.

**Critical**: The `.psm1` file automatically dot-sources all scripts in order: internal functions → public functions → internal scripts. Never manually add imports.


### Build System
Located in `build/` directory, uses PSFramework.NuGet tooling:

1. **Prerequisites**: `.\build\prerequisites.ps1` - Installs dependencies (Pester, PSScriptAnalyzer, PSModuleDevelopment)
2. **Validate**: `.\build\validate.ps1` - Runs Pester tests via `tests\pester.ps1`
3. **Build**: `.\build\build.ps1` - Compiles module into `publish/` directory, handles auto-versioning and function exports
4. **Publish**: `.\build\publish.ps1` - Publishes to PSGallery (requires `-ApiKey`)
5. **Release**: `.\build\release.ps1` - Creates GitHub release



## Development Workflows

### Testing
Run from `tests/` directory:
```powershell
.\pester.ps1                        # Run all tests
.\pester.ps1 -Output Detailed       # Verbose output
.\pester.ps1 -TestFunctions $false  # Skip function-specific tests
```

Tests organized as:
- `tests/general/` - Manifest validation, PSScriptAnalyzer, file integrity, help completeness
- `tests/functions/` - Per-function tests (when created)

**Testing Pattern**: 
- Uses Pester 5.x with `[PesterConfiguration]`, outputs JUnit XML to `TestResults/`.
- Create and maintain tests for each function in `tests/functions/` with the same name as the function file (e.g. `Get-PackageUpdateInfo.Tests.ps1` for `Get-PackageUpdateInfo.ps1`).
- Each function specific test file has to contain at least two describe blocks: 
  - A Describe block with "%functionname% - Parameter Contract" that validate the defined parameter names and types (principal of parameter contract)
  - A Describe block with "%functionname% - Functionality" that tests the actual functionality of the function. (unit tests, integration tests, etc.)


### CI/CD Pipelines
- **build.yml**: Runs on push to main/master - validates (PS 5.1 + 7), builds, publishes to PSGallery, creates GitHub release
- **validate.yml**: Runs on all other branches and PRs - validates only, no publish

Both workflows run on `windows-latest` and test against PowerShell 5.1 (Desktop) and 7.x (Core).


### Version Management
Controlled by `config.psd1`:
```powershell
@{
    AutoVersion = $false       # If true, build.ps1 auto-increments version from PSGallery
    ExportFunctions = $false   # If true, build.ps1 auto-generates FunctionsToExport
    GithubRelease = $true      # Create GitHub release after publish
}
```

When `ExportFunctions = $false` (current), manually maintain `FunctionsToExport` in `.psd1` manifest. Manifest tests validate sync with `functions/*.ps1` files.



## PowerShell Coding Standards

**Critical** Respect the PowerShell coding standards inside the instructions folder for consistency across the codebase. This includes naming conventions, parameter design, error handling, and performance patterns.


## Module Manifest Best Practices

### Required Fields to Maintain
```powershell
ModuleVersion = '1.0.0'           # increment this before PR and release
Author = 'Andi Bellstedt'
Copyright = 'Copyright (c) YYYY Andi Bellstedt. All rights reserved.'
Description = 'Clear, concise summary'
PowerShellVersion = '5.1'          # Minimum supported version
CompatiblePSEditions = @('Desktop', 'Core')
FunctionsToExport = @('All functions in the functions folder')  # When ExportFunctions=$false
PrivateData.PSData.Tags = @('Clearn and concise tags that describe the module and its functionality.)')
```


### URI Configuration
```powershell
LicenseUri   = 'https://github.com/AndiBellstedt/PackageUpdateInfo/blob/master/LICENSE'
ProjectUri   = 'https://github.com/AndiBellstedt/PackageUpdateInfo'
IconUri      = 'https://github.com/AndiBellstedt/PackageUpdateInfo/raw/master/assets/icon/PackageUpdateInfo_128x128.png'
ReleaseNotes = 'https://github.com/AndiBellstedt/PackageUpdateInfo/blob/master/PackageUpdateInfo/changelog.md'
```



## Key Patterns & Conventions

### Pipeline Support
Functions should support:
```powershell
[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
[Alias('FullName', 'FilePath', 'InputPath', 'File', 'Path')]
[string[]]
$InputFile
```

This allows: `Get-ChildItem *.log | Convert-DNSDebugLogFile`

### Parameter Validation
Use attributes generously:
- `[ValidateSet()]` for enumerated choices
- `[ValidateLength()]` for string constraints
- `[Alias()]` for parameter name flexibility
- `[ValidateScript()]` for complex validation

### Explicit Output Determination
Track user intent vs. defaults (from `Convert-DNSDebugLogFile.ps1`):
```powershell
$explicitOutputFile = -not [string]::IsNullOrEmpty($OutputFile)
# Then adjust behavior based on pipeline context
```

## Common Tasks

### Adding a New Public Function
1. Create `PackageUpdateInfo/functions/New-Function.ps1` (one function per file)
2. Add comprehensive CBH with 5+ examples
3. If `ExportFunctions = $false`, manually add to `FunctionsToExport` in `.psd1`
4. Create `tests/functions/New-Function.Tests.ps1` with Pester 5.x tests
5. Run `.\tests\pester.ps1` to validate

### Adding Internal Helper Functions
1. Create in `PackageUpdateInfo/internal/functions/` (not exported)
2. Keep focused and reusable
3. Document purpose with inline comments

### Running Full Build Pipeline Locally
```powershell
.\build\prerequisites.ps1   # Install dependencies
.\build\validate.ps1        # Run tests
.\build\build.ps1           # Compile to publish/
# .\build\publish.ps1 -LocalRepo  # Create .nupkg without publishing
```

### Updating Dependencies
Add to `RequiredModules` in `.psd1`, then `prerequisites.ps1` auto-installs them.

## Project-Specific Context

**Problem Domain**: Windows DNS Server debug logs are human-readable text but not analytics-ready. This module transforms them into structured CSV for Excel, Power BI, SQL, etc.

**Performance Focus**: Designed for 100MB+ files using streaming I/O and string operations instead of regex.

**Single-Function Philosophy**: Module currently exports only `Convert-DNSDebugLogFile`. If adding features, consider if they should be separate parameters vs. new functions.

**Windows-Only**: DNS Server debug logs are Windows-specific. No cross-platform considerations needed for core functionality.



This file provides project-specific guidance for creating and maintaining PowerShell code in the PackageUpdateInfo repository. It supplements the general PowerShell instructions in `.github/instructions/powershell.instructions.md` with repo conventions for cmdlet design, module packaging, tests, and internal helpers.

## General Instructions

- Follow the existing module structure: exported functions in `PackageUpdateInfo/functions/`, reusable internals in `PackageUpdateInfo/internal/functions/`, and scripts in `PackageUpdateInfo/internal/scripts/`.
- Keep exported commands consistent with the manifest in `PackageUpdateInfo/PackageUpdateInfo.psd1` and the module file `PackageUpdateInfo/PackageUpdateInfo.psm1`.
- Preserve comment-based help for every exported function. Include `SYNOPSIS`, `DESCRIPTION`, `PARAMETER`, and `EXAMPLE` blocks.
- Use explicit full cmdlet names and parameter names; do not use aliases in module code.
- Prefer simple, descriptive names and avoid abbreviations unless they match existing aliases in this module.
- Use `Write-Verbose`, `Write-Warning`, `Write-Error`, and structured output instead of `Write-Host`.

## Cmdlet and Parameter Style

- Use Approved Verbs with singular nouns for exported commands.
- Use `PascalCase` for parameter names.
- Use `[switch]` for boolean options and never assign default values to switches.
- Use `ValueFromPipeline` or `ValueFromPipelineByPropertyName` for pipeline-aware cmdlets where appropriate.
- Use `SupportsShouldProcess = $true` for commands that change state, and call `$PSCmdlet.ShouldProcess()` before performing the operation.
- Use common parameter names such as `Path`, `Name`, `Force`, `PassThru`, `WhatIf`, and `Confirm`.

### Good Example
```powershell
function Set-PackageUpdateSetting {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param(
        [Alias('FullName', 'FilePath')]
        [string]
        $Path,

        [switch]
        $Reset,

        [switch]
        $PassThru
    )

    if ($PSCmdlet.ShouldProcess($Path, 'Reset PackageUpdateInfo behaviour')) {
        # Reset implementation
    }
}
```

### Bad Example
```powershell
function Set-PackageUpdateSetting {
    param(
        [bool]
        $Reset = $false,

        [alias('f')]
        [switch]
        $Force
    )

    Write-Host 'Resetting settings'
}
```

## Output and Pipeline

- Return rich objects rather than formatted strings.
- Use `PSCustomObject` for structured output and type names such as `[PackageUpdate.Configuration]` or `[PackageUpdate.Info]` when applicable.
- Stream output in the `process` block for pipeline-friendly commands.
- Use `-PassThru` on setter commands to return objects only when requested.

## Error Handling

- Use `try/catch` for error handling when calling external cmdlets or file operations.
- Prefer terminating error handling with `throw` or `$PSCmdlet.ThrowTerminatingError()` inside advanced functions.
- Use `Write-Error` or `$PSCmdlet.WriteError()` to report non-terminating failures.

## Internal Organization

- Keep reusable helpers under `PackageUpdateInfo/internal/functions/` with one logical operation per file.
- Keep helper scripts under `PackageUpdateInfo/internal/scripts/` and invoke them from module functions as needed.
- Add new command files under `PackageUpdateInfo/functions/` and name the file after the exported function.
- Keep tests in `PackageUpdateInfo/tests/` and add new Pester tests under `PackageUpdateInfo/tests/general/`.

## Testing and Validation

- Validate code with the repository’s Pester test suite and script analyzer rules.
- Use `PackageUpdateInfo/tests/pester.ps1` as the baseline entry point for test execution.
- Follow the existing Pester style: discovery-first setup, `BeforeDiscovery`, `Describe`, `Context`, and `It` blocks.
- Exclude known package-specific analyzer rules only when they are explicitly excluded by the repository test harness.

## Packaging and Manifest

- Keep the exported functions list in sync with `FunctionsToExport` in `PackageUpdateInfo/PackageUpdateInfo.psd1`.
- Keep aliases in sync with `AliasesToExport` when adding new command shortcuts.
- Update `PrivateData.PSData` metadata only when release notes, project URLs, or tags change.

## Project Conventions

- Use the module’s existing default values and feature patterns, such as update interval logic in `Get-PackageUpdateInfo` and `Set-PackageUpdateSetting`.
- Keep user-facing messages consistent with the current style: plain language and helpful guidance for automation scenarios.
- When adding new GUI/notification behavior, preserve separation between core logic and optional presentation helpers.

## Examples

### Exported Command
```powershell
function Get-PackageUpdateInfo {
    [CmdletBinding(DefaultParameterSetName = 'DefaultSet1')]
    [OutputType([PackageUpdate.Info])]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string[]]
        $Name,

        [switch]
        $ShowOnlyNeededUpdate,

        [switch]
        $ShowToastNotification
    )

    process {
        # Cmdlet logic here
    }
}
```

### Helper Function
```powershell
function Test-UpdateIsNeeded {
    param(
        [Parameter(Mandatory)]
        [psobject]
        $ModuleLocal,

        [Parameter(Mandatory)]
        [psobject]
        $ModuleOnline
    )

    # Return a boolean result, no side effects
}
```

## Validation

- Run `Invoke-Pester -Script .\PackageUpdateInfo\tests\pester.ps1` to verify behavior.
- Confirm new exported functions are added to `PackageUpdateInfo/PackageUpdateInfo.psd1`.
- Confirm comment-based help is present for exported functions.
- Confirm no aliases are used inside module implementation files.
