# clip-line-ref

A Neovim plugin to copy file path and line number reference to the system clipboard.

## Overview

This plugin allows users to quickly copy a file path with line number reference to the clipboard. Useful for sharing code locations in documentation, pull requests, or team communication.

## Output Format

**Single line (cursor position or single-line selection):**
```
.devcontainer/devcontainer.json L13
```

**Range selection:**
```
.devcontainer/devcontainer.json L13-L17
```

The format is fixed as `{path} L{line}` or `{path} L{start}-L{end}`.

## Path Resolution

- **Default**: Path is relative to the nearest git root (submodule-aware)
- **Fallback**: If not in a git repository, path is relative to Neovim's current working directory
- **Configurable**: Can be set to always use absolute paths via `use_git_root = false`
- **Special characters**: Paths with spaces or special characters are output as-is (no escaping or quoting)

## Configuration

```lua
require('clip-line-ref').setup({
  -- Use git root for relative paths
  -- Set to false to use absolute paths instead
  use_git_root = true,  -- default
})
```

The `setup()` function must be called to initialize the plugin.

## Commands

### `:ClipLineRef`

Single command that works in both normal and visual modes:

- **Normal mode**: Copies current cursor line reference
- **Visual mode**: Copies selected line range reference (works with visual, visual line, and visual block modes)

For visual block selections, uses the first and last line of the selection (same as regular visual mode).

## Default Keymapping

| Mode   | Key          | Action                    |
|--------|--------------|---------------------------|
| Normal | `<leader>yl` | Copy current line ref     |
| Visual | `<leader>yl` | Copy selected range ref   |

The default keymap is always set. Users can override by mapping their own keys after plugin initialization.

## Clipboard

Copies to the system clipboard (`+` register) for easy pasting outside of Neovim.

## User Feedback

- **Success**: Echo the copied text in the command line (e.g., `Copied: src/main.lua L42`)
- **Special buffers**: Show warning message when attempting to copy from terminal, quickfix, help, or other special buffers
- **Unsaved changes**: Include indicator in the echo message when the file has unsaved modifications (line numbers may not match saved file)

## Special Buffer Handling

The plugin shows a warning and does not copy when used in:
- Terminal buffers
- Quickfix/location list windows
- Help buffers
- Scratch buffers without a file path
- Any buffer without a valid file name

## Compatibility

- **Minimum Neovim version**: 0.8+
- **Lazy loading**: Designed to work well with lazy.nvim and similar plugin managers

## Testing

Tests are written using plenary.nvim test framework.

## Project Structure

```
clip-line-ref/
├── lua/
│   └── clip-line-ref/
│       ├── init.lua        # Main module, setup(), public API
│       ├── core.lua        # Core logic (path resolution, formatting)
│       └── utils.lua       # Utility functions (git root detection, etc.)
├── plugin/
│   └── clip-line-ref.lua   # Plugin initialization, commands, keymaps
├── tests/
│   └── clip-line-ref/
│       └── core_spec.lua   # Plenary tests
├── docs/
│   └── spec.md             # This specification
└── README.md               # User documentation
```

## API

The plugin exposes the following Lua functions for programmatic use:

```lua
local clip = require('clip-line-ref')

-- Copy current line or visual selection to clipboard
clip.copy()

-- Get the formatted reference string without copying
-- Returns: string or nil (if in special buffer)
clip.get_reference()
```

## Implementation Notes

### Git Root Detection

1. Use `git rev-parse --show-toplevel` from the file's directory
2. For submodules, this returns the submodule root (nearest git root)
3. Cache the result per buffer to avoid repeated shell calls
4. Fall back to `vim.fn.getcwd()` if git command fails

### Mode Detection

Use `vim.fn.mode()` to detect current mode:
- `n`: Normal mode - use cursor line
- `v`, `V`, `<C-v>`: Visual modes - use `'<` and `'>` marks for range

### Unsaved Changes Detection

Check `vim.bo.modified` to determine if buffer has unsaved changes.

### Special Buffer Detection

Check `vim.bo.buftype` - special buffers have non-empty buftype (e.g., `terminal`, `quickfix`, `help`, `nofile`).
