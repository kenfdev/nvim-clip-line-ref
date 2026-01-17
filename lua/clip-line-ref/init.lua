-- clip-line-ref: Main module
-- Public API: setup(), copy(), get_reference()

local core = require("clip-line-ref.core")
local utils = require("clip-line-ref.utils")

local M = {}

local cfg = {
  use_git_root = true,
}

function M.setup(opts)
  opts = opts or {}
  cfg = vim.tbl_deep_extend("force", cfg, opts)
end

function M.copy()
  local reference = M.get_reference()
  if reference then
    vim.fn.setreg("+", reference)
  end
  return reference
end

function M.get_reference()
  local bufnr = vim.api.nvim_get_current_buf()

  -- Check for special buffers
  local is_special, _ = utils.is_special_buffer(bufnr)
  if is_special then
    return nil
  end

  -- Get path and line range
  local path = core.resolve_path(bufnr, cfg.use_git_root)
  if not path then
    return nil
  end

  local start_line, end_line = utils.get_line_range()
  return core.format_reference(path, start_line, end_line)
end

return M
