-- clip-line-ref: Tests using plenary.nvim

local core = require("clip-line-ref.core")
local utils = require("clip-line-ref.utils")

describe("clip-line-ref", function()
  describe("format_reference", function()
    it("formats single line reference", function()
      -- TODO: Implement test
      pending("not implemented")
    end)

    it("formats line range reference", function()
      -- TODO: Implement test
      pending("not implemented")
    end)
  end)

  describe("git root detection", function()
    it("detects git root for file in git repo", function()
      -- Use a file path within this repo
      local filepath = vim.fn.expand("%:p")
      if filepath == "" then
        filepath = vim.fn.getcwd() .. "/lua/clip-line-ref/utils.lua"
      end
      local git_root = utils.get_git_root(filepath)

      -- Should return a non-empty string
      assert.is_not_nil(git_root)
      assert.is_true(#git_root > 0)

      -- Should contain this project (ends with repo name or is a valid path)
      assert.is_true(vim.fn.isdirectory(git_root) == 1)
    end)

    it("returns cached result on subsequent calls", function()
      local filepath = vim.fn.getcwd() .. "/lua/clip-line-ref/utils.lua"

      -- Clear cache first
      utils.clear_git_root_cache(filepath)

      -- First call
      local result1 = utils.get_git_root(filepath)
      -- Second call should return same cached result
      local result2 = utils.get_git_root(filepath)

      assert.are.equal(result1, result2)
    end)

    it("returns cwd for empty filepath", function()
      local result = utils.get_git_root("")
      assert.are.equal(vim.fn.getcwd(), result)
    end)

    it("returns cwd for nil filepath", function()
      local result = utils.get_git_root(nil)
      assert.are.equal(vim.fn.getcwd(), result)
    end)
  end)

  describe("special buffer detection", function()
    it("returns false for normal file buffer", function()
      -- Create a normal buffer with a file name
      local buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_name(buf, "/tmp/test_file.lua")

      local is_special, reason = utils.is_special_buffer(buf)
      assert.is_false(is_special)
      assert.is_nil(reason)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("detects terminal buffer", function()
      -- Create a real terminal buffer
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_current_buf(buf)
      vim.fn.termopen("echo test")

      local is_special, reason = utils.is_special_buffer(buf)
      assert.is_true(is_special)
      assert.are.equal("terminal", reason)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("detects quickfix buffer", function()
      local buf = vim.api.nvim_create_buf(true, false)
      vim.bo[buf].buftype = "quickfix"

      local is_special, reason = utils.is_special_buffer(buf)
      assert.is_true(is_special)
      assert.are.equal("quickfix", reason)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("detects help buffer", function()
      local buf = vim.api.nvim_create_buf(true, false)
      vim.bo[buf].buftype = "help"

      local is_special, reason = utils.is_special_buffer(buf)
      assert.is_true(is_special)
      assert.are.equal("help", reason)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("detects nofile (scratch) buffer", function()
      local buf = vim.api.nvim_create_buf(true, false)
      vim.bo[buf].buftype = "nofile"

      local is_special, reason = utils.is_special_buffer(buf)
      assert.is_true(is_special)
      assert.are.equal("nofile", reason)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("detects buffer without file name", function()
      local buf = vim.api.nvim_create_buf(true, false)
      -- Buffer has no name set, buftype is empty

      local is_special, reason = utils.is_special_buffer(buf)
      assert.is_true(is_special)
      assert.are.equal("noname", reason)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("uses current buffer when no bufnr provided", function()
      -- This test verifies the default behavior
      local current_buf = vim.api.nvim_get_current_buf()
      local is_special, _ = utils.is_special_buffer()

      -- Result should be consistent with explicitly passing current buffer
      local is_special2, _ = utils.is_special_buffer(current_buf)
      assert.are.equal(is_special, is_special2)
    end)
  end)
end)
