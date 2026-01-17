-- clip-line-ref: Utility functions
-- Git root detection, buffer helpers

local M = {}

-- Cache for git root per buffer
local git_root_cache = {}

function M.get_git_root(filepath)
  if not filepath or filepath == "" then
    return vim.fn.getcwd()
  end

  -- Check cache first (keyed by filepath)
  if git_root_cache[filepath] then
    return git_root_cache[filepath]
  end

  -- Get the directory of the file
  local dir = vim.fn.fnamemodify(filepath, ":h")
  if dir == "" then
    dir = "."
  end

  -- Run git rev-parse --show-toplevel from the file's directory
  local cmd = string.format("cd %s && git rev-parse --show-toplevel 2>/dev/null", vim.fn.shellescape(dir))
  local handle = io.popen(cmd)
  if not handle then
    local fallback = vim.fn.getcwd()
    git_root_cache[filepath] = fallback
    return fallback
  end

  local result = handle:read("*a")
  local success = handle:close()

  if success and result and result ~= "" then
    -- Trim trailing newline
    local git_root = result:gsub("%s+$", "")
    git_root_cache[filepath] = git_root
    return git_root
  end

  -- Fallback to cwd if git command fails
  local fallback = vim.fn.getcwd()
  git_root_cache[filepath] = fallback
  return fallback
end

-- Clear cache for a specific buffer or all buffers
function M.clear_git_root_cache(filepath)
  if filepath then
    git_root_cache[filepath] = nil
  else
    git_root_cache = {}
  end
end

function M.is_special_buffer(bufnr)
  -- TODO: Implement special buffer detection
  -- Check for terminal, quickfix, help, nofile, etc.
  return false
end

function M.get_line_range()
  -- TODO: Implement mode detection and line range extraction
  -- Normal mode: cursor line
  -- Visual modes: selection range
  return nil, nil
end

return M
