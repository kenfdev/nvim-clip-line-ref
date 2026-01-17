---
name: next-issue
description: Unified workflow for implementing and reviewing beads issues. Use when user says "next-issue", "/next-issue", or wants to work on the next available issue. Automatically handles both implementation and review phases based on issue state.
---

# Next Issue Skill

A state-machine workflow that combines implementation and review into a single command.

## Workflow Overview

```
/next-issue
    │
    ▼
┌─────────────────────────────────────┐
│ Check for "###NEEDS REVIEW###"      │
│ in any in_progress issue title      │
└─────────────────────────────────────┘
    │                    │
    │ Found              │ Not Found
    ▼                    ▼
┌──────────────┐    ┌──────────────────┐
│ REVIEW MODE  │    │ IMPLEMENT MODE   │
└──────────────┘    └──────────────────┘
```

## Step 1: Check for Issues Needing Review

```bash
bd list --status in_progress
```

Scan the output for any issue with `###NEEDS REVIEW###` in the title.

- **If found**: Go to **Review Mode**
- **If not found**: Go to **Implement Mode**

---

## Review Mode

### 1. Get issue details

```bash
bd show <id>
```

### 2. Verify the implementation

- Check that code matches issue requirements
- Run all tests:
  ```bash
  nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}" -c "qa"
  ```
- Review code quality and adherence to spec (`docs/spec.md`)

### 3. Decision

**If implementation is satisfactory:**

```bash
# Remove the review marker from title and close
bd update <id> --title "<original title without ###NEEDS REVIEW### prefix>"
bd close <id>
bd sync
git push
```

Tell user: "Issue `<id>` has been reviewed and closed."

**If implementation needs work:**

```bash
# Remove the review marker from title
bd update <id> --title "<original title without ###NEEDS REVIEW### prefix>"

# Add feedback to description
bd update <id> --description "<original description>

## Review Feedback
- [ ] Issue 1 that needs to be fixed
- [ ] Issue 2 that needs to be fixed"
```

Tell user: "The implementation needs additional work. Feedback has been added to the issue. Run `/next-issue` again to continue working on it."

**STOP after review mode completes.**

---

## Implement Mode

### 1. Find next issue

```bash
bd ready
```

If multiple issues available, pick the first one (highest priority).

### 2. Claim the issue

```bash
bd show <id>
bd update <id> --status in_progress
```

### 3. Implement the solution

- Read the spec (`docs/spec.md`) if needed for context
- Write code following the project structure
- Run tests:
  ```bash
  nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}" -c "qa"
  ```

### 4. Commit changes

```bash
git add <files>
git commit -m "<type>: <description> (#<id>)"
```

### 5. Mark for review

Get the current title and prepend the review marker:

```bash
bd update <id> --title "###NEEDS REVIEW### <current title>"
```

Tell user: "Implementation complete. Issue marked for review. Run `/next-issue` again to review and close."

**STOP after marking for review.**

---

## Important Rules

- NEVER run `bd close` in implement mode
- ONLY run `bd close` after successful review
- ALWAYS run tests before committing and before closing
- ALWAYS commit changes before marking for review
- The `###NEEDS REVIEW###` marker goes at the START of the title
- When removing the marker, restore the original title exactly
