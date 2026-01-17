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
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Check buftype - special buffers have non-empty buftype
  local buftype = vim.bo[bufnr].buftype
  if buftype ~= "" then
    -- terminal, quickfix, help, nofile, acwrite, prompt, etc.
    return true, buftype
  end

  -- Check if buffer has a valid file name
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  if bufname == "" then
    return true, "noname"
  end

  return false, nil
end

function M.get_line_range()
  local mode = vim.fn.mode()

  -- Normal mode: cursor line
  if mode == "n" then
    local line = vim.api.nvim_win_get_cursor(0)[1]
    return line, line
  end

  -- Visual modes: use '< and '> marks for range
  -- v = character-wise, V = line-wise, <C-v> (^V) = block-wise
  if mode == "v" or mode == "V" or mode == "\22" then
    local start_line = vim.fn.line("v")
    local end_line = vim.fn.line(".")

    -- Ensure start <= end
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end

    return start_line, end_line
  end

  return nil, nil
end

function M.notify(msg, level)
  level = level or vim.log.levels.INFO
  vim.notify(msg, level)
end

return M
