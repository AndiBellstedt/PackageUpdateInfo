---
name: create-comment-based-help
description: 'Write comprehensive comment-based help for a PowerShell script or function while following repository PowerShell instructions and preserving behavior.'
agent: agent
argument-hint: 'Provide the target .ps1/.psm1 file path and optional focus areas (for example: examples, notes metadata, parameter depth).'
model: GPT-5 mini (copilot)
---

# Write PowerShell Comment-Based Help

Create or improve the comment-based help for a PowerShell script or function using this input:

`${input:targetPath:Target PowerShell file path, for example: .github/scripts/contentgeneration/Invoke-ContentGeneration.ps1}`

Optional focus:

`${input:focus:Optional focus, for example: add 3 practical examples and detailed .PARAMETER entries}`

## Mission

Produce complete, accurate, and maintainable comment-based help that matches repository standards and does not change runtime behavior.
Remember your PowerShell instructions and repository-specific documentation guidelines. Focus on clarity, relevance, and correctness of the help content.

## Required Workflow

1. Open the target file and identify whether help is script-level or function-level.
2. Read and apply all relevant instruction files, especially PowerShell, documentation, and repository-specific instructions.
3. Infer intent from implementation before writing help:
    - summarize what the script/function does
    - list parameters, defaults, and constraints
    - identify side effects, dependencies, and expected outputs
5. Keep help specific to actual behavior in code. Do not invent parameters, outputs, or workflows.
6. Preserve script/function behavior and structure. Only edit documentation.
7. Run diagnostics for the changed file and fix documentation-related issues if introduced.

## Output Requirements

1. Use the standard `<# ... #>` comment-based help format with the common sections.
2. Do indempted formatting for readability and consistency with the PowerShel specific indemption style from hte current code settings. 
3. Keep prose clear and concise, focused on why/how to use the code.
4. Include repository-appropriate examples with named parameters.
5. Ensure examples are realistic for this codebase context.
6. Avoid redundant comments that only restate obvious code.

## Completion Check

Before finishing, confirm:

1. Which file was updated.
2. Whether help is script-level or function-level.
3. Which sections were added or revised.
4. That behavior was not changed.
5. That diagnostics were checked.
