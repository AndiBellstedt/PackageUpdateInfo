---
name: create-a-pr
description: Create GitHub PRs with proper structure and error handling.
agent: agent
model: ['GPT-5 mini', 'Claude Haiku 4.5', 'Raptor mini (Preview) (copilot)', ]
tools: github/*, search/codebase, read
---

**Step 1: Determine the target branch**

Always ask the user to confirm the target branch if not explicitly stated.

**Step 2: Determine the source branch**

Use the current workspace branch as the source. Run:

```powershell
git branch --show-current
```

If the command returns an empty string or an error, inform the user: "I could not detect the current branch. Please specify the source branch you want to use for this PR."

**Step 3: Validate branch pair**

Stop if source and target branches are identical. Inform user: "Source and target branches are identical. Specify a different target branch."

**Step 4: Gather PR details**

If a PR template exists, use it. Otherwise, ask these questions in one message:

1. What is the purpose of this PR?
2. What changes were made and why?
3. Are there related issues or pull requests?
4. How was this tested?
5. Are there screenshots or additional context to include?

Structure the PR description with: "Description", "Summary of changes", "Related Issues", "Testing", and "Screenshots" (if applicable).

**Step 5: Check for existing PRs**

Check for an existing open PR for this branch pair. If found, show the link and ask whether to update it or create a new one.

**Step 6: Create the PR**

1. Attempt to create the PR using the GitHub MCP Server.
2. If the GitHub MCP Server tool is not available in your current tool list, fall back to the GitHub CLI command `gh pr create`.
3. Do not use the CLI if the MCP Server is available.

On failure, report the error and suggest: check authentication/permissions, verify branch is pushed to remote, confirm write access.

**Step 7: Confirm successful creation**

Provide the user with a PR summary and link to the PR on GitHub.