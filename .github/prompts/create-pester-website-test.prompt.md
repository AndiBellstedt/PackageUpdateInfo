---
name: create-pester-website-test
description: 'Scaffold a new website-specific Pester test file from one sentence. Creates a repository-pattern test script under .github/tests/website using discovery-first structure, helper reuse, and aggregated violation assertions.'
agent: agent
argument-hint: 'Describe the website validation rule in one sentence.'
---

# Create Website Pester Test

Create or update a website-specific Pester test script from this single input:

`${input:ruleDescription:One-sentence rule, for example: Ensure all markdown files have non-empty description front matter.}`

## Mission

Generate a production-ready scaffold for this repository that follows existing
website test conventions in `.github/tests/website/`.

## Required Workflow

1. Parse the one-sentence rule and infer:
   - validation scope (content, links, localization, assets, structure, or
     theme-specific)
   - likely source files to gather in `BeforeDiscovery`
   - whether the check is theme-agnostic or theme-specific
2. Before writing anything, check and respect all custom PowerShell instructions that apply to `.ps1` files in this repository.
3. List and review existing website test files under `.github/tests/website/`.
   - Read each candidate file's top comment block, `Describe` titles, and existing `It` blocks to understand meaning and intent.
4. Decide integration target with this priority order:
   - First priority: integrate the requested rule into an existing matching file.
   - Only if no reasonable file exists: create a new file.
5. If a new file is required, choose an output file path under `.github/tests/website/`:
   - theme-agnostic: `website.content.<Area>.Tests.ps1`
   - theme-specific: `website.content.<Area>.Theme_<ThemeName>.Tests.ps1`
6. Implement the test using the repository layout:
   - top comment block with intent and scope
   - `BeforeDiscovery` with regions:
     - `Initialization`
     - `Behavior variables`
     - `Content gathering`
   - `BeforeAll` with initialization
   - one `Describe` block and one or more focused `It` blocks
7. Search and reuse helpers by default:
   - Before writing helper logic, search for existing helper functions and reuse them when possible.
   - Search in this order and utilize matching helpers first:
     - `.github/tests/website/helperfunctions.ps1`
     - `.github/scripts/common.ps1`
     - `.github/scripts/translation/helperfunctions.ps1`
   - dot-source required helper files in the test script.
   - load additional shared helpers only when necessary.
8. Keep discovery limited to file collection and simple lookup data:
   - Do not put complex parsing, calculations, or comparisons in `BeforeDiscovery`.
   - If a validation needs reusable or non-trivial logic, put it into `.github/tests/website/helperfunctions.ps1` as a PowerShell function.
   - For a one-off rule, compute directly in the `It` block instead of `BeforeDiscovery`.
9. Build assertion diagnostics using aggregated violations:
   - collect violations in
     `[System.Collections.Generic.List[string]]::new()`
   - use normalized relative paths with `/`
   - assert once per rule with `Should -Be 0 -Because <details>`
   - Use early `return` (not `Set-ItResult -Skipped`) when the input collection is empty.
   - Set `$violationMessage` only when violations exist; omit the else-branch.

## Output Requirements

1. Prefer updating one existing matching `*.Tests.ps1` file.
2. Create a new file only when no reasonable existing file matches the requested validation intent.
3. Match style and structure used by existing files in
   `.github/tests/website/`.
4. Include short, high-signal comments that explain non-obvious intent only.
5. Do not duplicate existing helper logic.
6. State which helper search was performed across:
   - `.github/tests/website/helperfunctions.ps1`
   - `.github/scripts/common.ps1`
   - `.github/scripts/translation/helperfunctions.ps1`
7. Prefer PowerShell-style helper functions in `.github/tests/website/helperfunctions.ps1` for reusable or complex calculation logic.

## Completion Check

After creation, confirm:

1. which existing files were reviewed
2. why the selected existing file was used, or why no reasonable existing file fit
3. the final changed file path
4. which existing helper functions are expected to be reused
5. which helper files were searched for reusable logic
