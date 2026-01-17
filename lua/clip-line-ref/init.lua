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

function M.copy(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()

  -- Check for special buffers first and show warning
  local is_special, reason = utils.is_special_buffer(bufnr)
  if is_special then
    utils.notify("Cannot copy line reference from " .. reason .. " buffer", vim.log.levels.WARN)
    return nil
  end

  local reference = M.get_reference(opts)
  if reference then
    vim.fn.setreg("+", reference)

    -- Build success message with optional unsaved indicator
    local msg = "Copied: " .. reference
    if vim.bo[bufnr].modified then
      msg = msg .. " [unsaved]"
    end
    utils.notify(msg)
  end
  return reference
end

function M.get_reference(opts)
  opts = opts or {}
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

  -- Use provided range (from command) or detect from mode
  local start_line, end_line
  if opts.line1 and opts.line2 then
    start_line, end_line = opts.line1, opts.line2
  else
    start_line, end_line = utils.get_line_range()
  end
  return core.format_reference(path, start_line, end_line)
end

return M
