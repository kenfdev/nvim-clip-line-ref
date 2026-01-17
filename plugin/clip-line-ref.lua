-- clip-line-ref: Plugin initialization
-- Commands and keymaps

if vim.g.loaded_clip_line_ref then
  return
end
vim.g.loaded_clip_line_ref = true

-- Create user command
vim.api.nvim_create_user_command("ClipLineRef", function(cmd_opts)
  -- Pass range from command (for visual mode support)
  require("clip-line-ref").copy({
    line1 = cmd_opts.line1,
    line2 = cmd_opts.line2,
  })
end, { range = true, desc = "Copy file path with line reference to clipboard" })

-- Default keymaps
vim.keymap.set("n", "<leader>yl", function()
  require("clip-line-ref").copy()
end, { desc = "Copy line reference" })

vim.keymap.set("v", "<leader>yl", ":ClipLineRef<CR>", { desc = "Copy line range reference" })
