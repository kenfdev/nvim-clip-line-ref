---
name: implement
description: Implement a beads issue. Use when user says "implement", "/implement", or "work on issue", or when user wants to start working on a beads issue. This skill handles the implementation phase ONLY - it does NOT close issues.
---

# Implement Skill

## Workflow

1. **Check for issue ID** - If not provided, run `bd ready` to show available work and ask user which issue to work on

2. **Claim the issue**
   ```bash
   bd show <id>                           # Review the issue details
   bd update <id> --status in_progress    # Mark as in progress
   ```

3. **Implement the solution**
   - Read the spec (`docs/spec.md`) if needed for context
   - Write code following the project structure
   - Run tests to verify the implementation:
     ```bash
     nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}" -c "qa"
     ```

4. **Commit the changes**
   - Stage and commit with a descriptive message referencing the issue ID
   - Example: `git commit -m "feat: implement format_reference function (#<id>)"`

5. **STOP HERE** - Do NOT run `bd close`
   - The implementation is complete but the issue remains `in_progress`
   - Advise the user to run `/review-changes` to verify and close the issue

## Important Rules

- NEVER run `bd close` - use `/review-changes` skill to close issues
- ALWAYS run tests before committing
- ALWAYS commit changes before finishing
- Leave the issue in `in_progress` status when done
