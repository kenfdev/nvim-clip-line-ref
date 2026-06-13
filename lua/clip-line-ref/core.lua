-- clip-line-ref: Core logic
-- Path resolution and reference formatting

local utils = require("clip-line-ref.utils")

local M = {}

local function is_absolute(path)
  return path:sub(1, 1) == "/"
end

local function normalize_path(path)
  local absolute = is_absolute(path)
  local trailing_slash = path:sub(-1) == "/"
  local parts = {}

  for part in path:gmatch("[^/]+") do
    if part == ".." and #parts > 0 and parts[#parts] ~= ".." then
      table.remove(parts)
    elseif part ~= "." and part ~= "" then
      table.insert(parts, part)
    end
  end

  local normalized = table.concat(parts, "/")
  if absolute then
    normalized = "/" .. normalized
  end

  if normalized == "" then
    normalized = absolute and "/" or "."
  elseif trailing_slash and normalized ~= "/" then
    normalized = normalized .. "/"
  end

  return normalized
end

local function absolute_path(path)
  if is_absolute(path) then
    return normalize_path(path)
  end

  return normalize_path(vim.fn.getcwd() .. "/" .. path)
end

local function relative_to_root(path, root)
  root = normalize_path(root):gsub("/$", "")
  path = normalize_path(path)

  if path == root then
    return "."
  end

  if path:sub(1, #root + 1) == root .. "/" then
    return path:sub(#root + 2)
  end

  return nil
end

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

  -- Neovim canonicalizes symlinks in nvim_buf_get_name(), while bufname()
  -- preserves the path spelling the user opened.
  local opened_path = vim.fn.bufname(bufnr)
  local abs_path = vim.api.nvim_buf_get_name(bufnr)
  if opened_path == "" and abs_path == "" then
    return nil
  end
  if opened_path == "" then
    opened_path = abs_path
  end

  local opened_abs_path = absolute_path(opened_path)
  local canonical_abs_path = normalize_path(abs_path)

  -- If use_git_root is false, return absolute path
  if use_git_root == false then
    return opened_abs_path
  end

  -- If Neovim resolved a symlink, prefer the path spelling the user opened.
  if opened_abs_path ~= canonical_abs_path then
    if is_absolute(opened_path) then
      return opened_abs_path
    end
    return normalize_path(opened_path)
  end

  -- Default: use git root for relative path
  local git_root = utils.get_git_root(canonical_abs_path)

  -- Make path relative to git root.
  local relative = relative_to_root(canonical_abs_path, git_root)
  if relative then
    return relative
  end

  -- Fallback: make path relative to cwd if possible.
  relative = relative_to_root(opened_abs_path, vim.fn.getcwd())
  if relative then
    return relative
  end

  return opened_abs_path
end

return M
