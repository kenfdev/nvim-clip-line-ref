-- clip-line-ref: Core logic
-- Path resolution and reference formatting

local utils = require("clip-line-ref.utils")

local M = {}

function M.format_reference(path, start_line, end_line)
  if not path or not start_line then
    return nil
  end

  -- Default end_line to start_line if not provided
  end_line = end_line or start_line

  -- Single line: "{path} L{line}"
  if start_line == end_line then
    return string.format("%s L%d", path, start_line)
  end

  -- Range: "{path} L{start}-L{end}"
  return string.format("%s L%d-L%d", path, start_line, end_line)
end

function M.resolve_path(bufnr, use_git_root)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- Get the absolute path of the buffer
  local abs_path = vim.api.nvim_buf_get_name(bufnr)
  if abs_path == "" then
    return nil
  end

  -- If use_git_root is false, return absolute path
  if use_git_root == false then
    return abs_path
  end

  -- Default: use git root for relative path
  local git_root = utils.get_git_root(abs_path)

  -- Make path relative to git root (or cwd if not in git repo)
  -- Ensure git_root ends without trailing slash for consistent behavior
  git_root = git_root:gsub("/$", "")

  -- Check if abs_path starts with git_root
  if abs_path:sub(1, #git_root) == git_root then
    -- Remove the git_root prefix and leading slash
    local relative = abs_path:sub(#git_root + 1)
    if relative:sub(1, 1) == "/" then
      relative = relative:sub(2)
    end
    return relative
  end

  -- Fallback: return absolute path if not under git root
  return abs_path
end

return M
