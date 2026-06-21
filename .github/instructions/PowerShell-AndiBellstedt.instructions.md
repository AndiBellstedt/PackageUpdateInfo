---
applyTo: '**/*.ps1, **/*.psm1, **/*.psd1, **/*.ps1xml, **/*.pssc, **/*.psrc, **/*.ps1help'
---

# PowerShell general Project coding standards

- This document defines general coding standards for PowerShell scripts and modules
- These standards overrule the PowerShell cmdlet development guidelines in [powershell.instructions.md](./powershell.instructions.md). In case of a conflict between the standards in this document and the ones in powershell.instructions.md, the standards in **this document take precedence**. Specific overrides:
  - **Error handling**: Use `Write-Error` and `Throw` — not `$PSCmdlet.WriteError()` or `$PSCmdlet.ThrowTerminatingError()` as promoted by `powershell.instructions.md`. When PSFramework is available, use `Write-PSFMessage` and `Stop-PSFFunction` per the Error Handling section below.
  - **Logging**: Use PSFramework `Write-PSFMessage` when available; fall back to `Write-Verbose`/`Write-Debug`/`Write-Warning`. Do not use `Write-Verbose` alone for all logging as `powershell.instructions.md` suggests.
  - **ErrorRecord construction**: Do not construct `[System.Management.Automation.ErrorRecord]` objects manually as `powershell.instructions.md` demonstrates. Use `Write-Error`/`Throw` or PSFramework equivalents.
  - **`$PSCmdlet.ShouldContinue()`**: Do not use this pattern unless explicitly required. `$PSCmdlet.ShouldProcess()` is sufficient.

- Even when PowerShell 7 is used, the code should be compatible with Windows PowerShell 5.1, unless explicitly stated otherwise
  When the project is a module, use the module manifest to find the desired PowerShell version compatibility. If the manifest does not specify a compatible PowerShell version, assume that the code should be compatible with both PowerShell 7 and Windows PowerShell 5.1, and follow the standards accordingly.
- These standards should be followed by all team members to ensure consistency and maintainability of the code
- You need to check if PSFramework is used in the project. There are scenario-based standards for both cases (with and without PSFramework), so you need to adapt your code accordingly. If you are unsure whether PSFramework is used, check the project files for any references to PSFramework (e.g., in module manifests, import statements, or documentation). If you cannot find any references, it is safe to assume that PSFramework is not used and follow the standards for that case.

## Naming Conventions
- Use PascalCase for function names, aliases, cmdlets, and function parameters (declared in param block)
- Use camelCase for local variables declared within function bodies
- Do not use positional parameters when calling functions or cmdlets; always use named parameters
- Use ALL_CAPS for constants
- Prefix private class members with underscore (_)
- Use singular nouns for function names (e.g., `Get-User`, not `Get-Users`)
- Avoid pluralization for variable names, use singular names with addition of 'List' in case of array (e.g., `$userList`, not `$users`)
- Avoid using abbreviations or acronyms
- Be consistent with naming across the codebase
- Use meaningful names that convey intent
- Avoid using numbers or other non-descriptive characters in names
- Avoid using generic names like "Data" or "Info"
- Stick to common terminology and naming patterns used in the PowerShell community
- Stick to established naming conventions for cmdlets and functions
- Stick to PowerShell's verb-noun format for function names (e.g., `Get-User`)
- Stick to common parameter naming conventions (e.g., `-ComputerName`, not `-Computer`)
- Use parameter aliases when a parameter accepts equivalent inputs that callers may refer to by different names (e.g., `[Alias("HostName", "Server")]` for a `-ComputerName` parameter), so the function is callable using either name.


## Error Handling
- try/catch blocks should only be used around commands or functions that are known to throw terminating errors natively, or that are called with `-ErrorAction Stop` to convert non-terminating errors into terminating ones.
- Use `Throw` to raise terminating errors
- Always log errors with contextual information

**Error Handling Strategy (by scenario):**

| Scenario | Without PSFramework | With PSFramework |
|----------|---------------------|------------------|
| Non-terminating error/warning | Use `Write-Warning` or `Write-Error` | Use `Write-PSFMessage -Level Warning` or `-Level Error` with `-PSCmdlet $PSCmdlet` |
| Terminating error | Use `Throw` | Use `Stop-PSFFunction` with `-EnableException $true` and `-PSCmdlet $PSCmdlet` |

- When PSFramework is not available, use `Write-Warning` for warnings and `Write-Error` for non-terminating errors. Always include contextual information (e.g., IDs or names) in the message string.


## Logging
- Use PSFramework (e.g., `Write-PSFMessage`) for all log messages if available
  - Use appropriate log levels existing in PSFramework (e.g. System, Verbose, Important, Warning, Error) to categorize log messages
- When PSFramework is not available, use `Write-Verbose`, `Write-Debug` for informational and debug messages and `Write-Warning` for warnings. Avoid using `Write-Host` for logging purposes.
- Include contextual information (e.g., IDs or Names) in log messages
- Logging of sensitive information (e.g., passwords, private data, tokens, hashes) must be avoided


## Code Structure
### Coding standards - General
- Organize code into modules and functions for better readability and maintainability
- Use consistent indentation and formatting throughout the codebase
- Group related functions and variables together
- Keep related code in the same file or module
- Do not create nested or helper modules within a project whose primary purpose is the development of a single module. Keep all functionality within the module being developed.
- Avoid circular dependencies between modules
- Avoid creating variables that hold scriptblock values (e.g., `$doWork = { ... }`). When logic would be placed in a scriptblock variable, define a named function or nested function instead. Functions always take precedence over scriptblock variables when feasible.
- Use semantic versioning for modules and functions
- Do not use abbreviations for functions, cmdlets, or parameters; always use full names.
- Prefer double quotes over single quotes
- Use splatting for functions with many parameters
- Avoid the "return" statement if not required; let functions return implicitly via the pipeline. However, use `return` in `process` blocks to short-circuit execution when necessary for pipeline-aware functions.
- Avoid using the format operator (-f)
- When using object properties, method calls, or expressions inside strings, always use the subexpression operator `$()`, e.g., `"The count is $($list.Count)"`. This applies to simple scalar variables as well. (e.g., `"Hello $($Name)"`)
- Avoid "Write-Host" unless your are explicitly told to do so or your are developing scripts for a CI/CD pipeline where "Write-Host" is the only way to output information to the console. In all other cases, use the appropriate logging cmdlets (e.g., `Write-Verbose`, `Write-Information`, `Write-Warning`, `Write-Error`) or PSFramework's `Write-PSFMessage` for logging purposes.

### Coding standards - functions
- Each function should be an advanced function with a CmdletBinding() attribute
- Each function should include begin, process and end blocks
- Always use Cmdlets with named parameters, never use positional parameters when calling other functions or cmdlets
- Advanced functions (cmdlets) should define positional parameters (`Position` attribute) for the most important and most commonly used parameters when it makes sense; callers must always invoke them using named parameter syntax
- Advanced functions (cmdlets) should provide PipeliningByPropertyname for all parameters where it makes sense
- Advanced functions (cmdlets) should provide PipeliningByValue for those parameter that matters most, where it makes sense
- Advanced functions (cmdlets) should also support providing arrays as parameter input, that may be processed with a loop
- Advanced functions (cmdlets) should utilize the input processing methods (begin,process,end) to also support pipelining and arrays as parameter input
- When a function modifies state (creates, updates, or deletes resources), add `SupportsShouldProcess = $true` to `[CmdletBinding()]` and wrap the modifying code with `if ($PSCmdlet.ShouldProcess("<target>", "<operation>")) { ... }`

**Parameter Attribution Formatting:**
- If `[Parameter()]` has exactly 1 or 2 attributes, keep it on one line
- If `[Parameter()]` has 3 or more attributes, expand to multi-line format with each attribute on its own line

  - Use this format for parameters with 1 or 2 attributes
    ```powershell
    [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
    ```
  - use this format for parameters with 3 or more attributes
    ```powershell
    [Parameter(
      Mandatory = $true,
      ValueFromPipelineByPropertyName = $true,
      Position = 0
    )]
    ```
- A parameter block itself should always be on multiple lines, with each parameter in a separate line and indented with spaces
  - Use this format
    ```powershell
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]
    $Name
    ```
  - avoid this format
    ```powershell
    [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Name
    ```

**CmdletBinding Formatting:**
- The `[CmdletBinding()]` block should be on a single line if it contains only one keyword
- The `[CmdletBinding()]` block should be on multiple lines (one keyword per line) if it contains two or more keywords

  - Use this for a block with one keyword only
    ```powershell
    [CmdletBinding(ConfirmImpact = "Low")]
    ```
  - Use this for a block with multiple keywords in the cmdletbinding
    ```powershell
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = "Medium"
    )]
    ```
  - Avoid doing this
    ```powershell
    [CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact="Medium")]
    ```

### Coding standards - Help & Synopsis documentation
- Each function should have a complete and accurate comment-based help section
- The comment-based help section must use `<#` to open and `#>` to close the comment block. Do not use any other delimiter variants
- The comment-based help section should be fully indented with spaces to align with the function statement. In case the comment-based help is on script/module level, it should be aligned with the first line of the script/module
- The Comment-based help should be put directly in the corresponding function statement at the very beginning. Avoid or refactor comment-based help from above or below the function statement
- Each comment-based help section should follow the standard PowerShell help format
- Each comment-based help section should include examples (at least 1 example, more is better) and detailed parameter descriptions
- Each example within the comment-based help section should have "PS C:\> " in front of the example command, followed by an empty line and a explaintation about the example.
- Each comment-based help section for public functions or scripts should include a .NOTES section with the following sections: Version, Author, Date (last change of the file) and Keywords. Please note, that this does not apply to private functions
  - the text for each section should be indented and aligned
  - use this format:
    ```powershell
    .NOTES
        Version   : 1.0.0
        Author    : Andi Bellstedt, Your Name
        Date      : 2024-01-01
        Keywords  : keyword1, keyword2
    ```
- Each comment-based help section should end with an empty line
- Each comment-based help section should include a .LINK section with a link to the related repository

### Coding standards - comments and inline documentation
- Comments that are of an explanatory nature, should start  with a space after the # and with a capital letter. They should be full sentences.
  - Use this format
    ```powershell
    # This is a comment.
    ```
  - Avoid this format
    ```powershell
    #This is a comment.
    ```
- Always do inline documentation that explains the steps taken in the script or function.
- For scripts or functions exceeding 50 lines, use region blocks to sub-segment the code for better visibility
  - Region blocks use the standard PowerShell syntax: `#region` to open and `#endregion` to close.
  - The name must appear on both begin and end.
  - The begin block must start with `--` and the end block must not have `--`. This way, the name of the region is visually aligned in both the begin and end block, to improve readability. 
  - Single-level region blocks use this pattern:
    ```powershell
    #region -- Name of the block
    # code here
    #endregion Name of the block
    ```
  - Nested region blocks follow this pattern:
    ```powershell
    #region -- Name of the outer block

    #region -- -- Name of the inner block

    #endregion -- Name of the inner block

    #endregion Name of the outer block
    ```
    
    Follow this pattern for each level of nesting, adding an additional `--`.


## Best Practices
- In general: KISS (keep it simple and small)
- Keep functions small and focused on a single task
- Use comments and documentation to explain complex logic
- State the date in ISO 8601 format (YYYY-MM-DD)
- Write pester unit tests for critical functions and modules
- Regularly review and refactor code to improve readability and maintainability
- Use version control (e.g., Git) for all code changes
- Do code reviews before committing code to ensure adherence to coding standards and best practices
  - Create `#ToDo` for any issues found during code reviews that cannot be fixed immediately
  - State a date in the #ToDo comment, e.g., `#ToDo (2024-06-15) (Copilot, Andi Bellstedt): The issue`
  - State your name in the #ToDo comment within parentheses (if you are AI use 'Copilot' and 'Andi Bellstedt' as names)
  - Address all `#ToDo` in a timely manner
  - Remove `#ToDo` when they are addressed
- Use consistent coding style and formatting across the codebase
- You must not use 'exit' or 'exit 1' in scripts or functions, as this will terminate the entire PowerShell session. Instead, use 'throw' to raise an error or return an appropriate error code or message from the function or script.


## Project related standards
- For modules, always maintain a proper module manifest (.psd1) file with accurate metadata
- Ensure that the module manifest includes all required fields, such as ModuleVersion, Author, CompanyName, Copyright, Description, FunctionsToExport, CompatiblePSEditions and PrivateData with -at least- tags.
    - in case the project is in a GitHub repository, the PrivateData section must include a ProjectUri field with the URL to the repository
    - in case the project is in a GitHub repository, the PrivateData section must include a LicenseUri field with the URL to the license file in the repository
    - in case the project is in a GitHub repository, the PrivateData section must include a ReleaseNotes field with a link to the releases page of the repository
- In case there is a `changelog.md` file in the repository, it must be maintained with each release
    - The changelog must follow the "Keep a Changelog" format (fetch https://keepachangelog.com/en/1.0.0/ for more information)
    - Each release entry in the changelog must include the version number and a summary of changes made in that release
    - Get the information for the changelog from the commit messages as well as from the commit history with all the file changes
- Maintain a `README.md` file in the repository with accurate and up-to-date information about the project
    - The README must include at least the following sections: Project Title, Description, Installation Instructions, Usage Instructions
    - In case there is a assets folder with a logo file (e.g., png, jpg, svg), the logo should be included at the top of the README file. For example:
      ```markdown
      ![Project Logo](./assets/logo_128x128.png) Project Title
      ```
    - Next to the logo or porject title, the README must include badges as a table with two columns "Plattform" and "Information" with the following content:
        - PowerShell Gallery (if the module is published there), with version, platform and download count
        - GitHub Repository, with release version, License type, Build Status (e.g., from GitHub Actions), Code Coverage (e.g., from Codecov), open issues, last commit in "main"/"master"-branch and last commit in "development"-branch (if available)
        - When it is feasible, include other badges that provide useful information about the project
