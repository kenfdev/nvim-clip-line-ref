# clip-line-ref

A Neovim plugin to copy file path and line number reference to the system clipboard.

![Demo](assets/nvim.gif)

## Features

- Copy current line reference in normal mode
- Copy line range reference in visual mode
- Paths relative to git root (submodule-aware)
- System clipboard integration

## Requirements

- Neovim 0.8+

## Installation

### lazy.nvim

```lua
{
  "kenfdev/nvim-clip-line-ref",
  config = function()
    require("clip-line-ref").setup()
  end,
}
```

### packer.nvim

```lua
use {
  "kenfdev/nvim-clip-line-ref",
  config = function()
    require("clip-line-ref").setup()
  end,
}
```

## Configuration

```lua
require("clip-line-ref").setup({
  -- Use git root for relative paths (default: true)
  -- Set to false to use absolute paths instead
  use_git_root = true,
})
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:ClipLineRef` | Copy line reference (works in normal and visual mode) |

### Default Keymaps

| Mode | Key | Action |
|------|-----|--------|
| Normal | `<leader>yl` | Copy current line reference |
| Visual | `<leader>yl` | Copy selected range reference |

### Output Format

Single line:
```
src/main.lua L42
```

Line range:
```
src/main.lua L13-L17
```

## API

```lua
local clip = require("clip-line-ref")

-- Copy current line or visual selection to clipboard
clip.copy()

-- Get the formatted reference string without copying
-- Returns: string or nil (if in special buffer)
clip.get_reference()
```

## License

MIT
