---
name: review-changes
description: Review an implemented issue and close it if the implementation is satisfactory. Use when user says "review-changes", "/review-changes", or "check implementation", or when user wants to verify and close a completed implementation.
---

# Review Changes Skill

## Workflow

1. **Identify issues to review**
   ```bash
   bd list --status in_progress    # Show issues that have been implemented
   ```
   If no issue ID provided, show the list and ask user which to review.

2. **Review the implementation**
   ```bash
   bd show <id>    # Get the issue details and requirements
   ```

3. **Verify the implementation**
   - Check that the code matches the issue requirements
   - Run all tests:
     ```bash
     nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}" -c "qa"
     ```
   - Review code quality and adherence to spec (`docs/spec.md`)

4. **Decision point**

   **If implementation is satisfactory:**
   ```bash
   bd close <id>    # Close the issue
   bd sync          # Sync with git
   git push         # Push all changes to remote
   ```

   **If implementation needs work:**
   - Document what needs to be fixed by updating the issue description:
     ```bash
     bd update <id> --description "Original description here

     ## Review Feedback
     - [ ] Issue 1 that needs to be fixed
     - [ ] Issue 2 that needs to be fixed"
     ```
   - Reset the issue status so `/implement` can pick it up again:
     ```bash
     bd update <id> --status open    # Reset to open for re-implementation
     ```
   - **Tell the user**: "The implementation needs additional work. I've updated the issue with the required changes and reset it to `open` status. Run `/implement <id>` to continue working on it."

5. **Final verification**
   ```bash
   git status    # Should show "up to date with origin"
   bd list       # Verify issue status is correct
   ```

## Important Rules

- ONLY close issues that pass review
- ALWAYS run tests before closing
- ALWAYS push to remote after closing
- If review fails, reset issue to `open` status and document the problems
- If review fails, ALWAYS advise the user to run `/implement <id>` to continue
- This is the ONLY skill that should run `bd close`
