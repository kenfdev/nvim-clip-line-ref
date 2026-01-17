-- clip-line-ref: Tests using plenary.nvim

local core = require("clip-line-ref.core")
local utils = require("clip-line-ref.utils")

describe("clip-line-ref", function()
  describe("format_reference", function()
    it("formats single line reference", function()
      local result = core.format_reference("src/main.lua", 42, 42)
      assert.are.equal("src/main.lua L42", result)
    end)

    it("formats single line when end_line equals start_line", function()
      local result = core.format_reference("lua/init.lua", 10, 10)
      assert.are.equal("lua/init.lua L10", result)
    end)

    it("formats single line when end_line is nil", function()
      local result = core.format_reference("src/main.lua", 42, nil)
      assert.are.equal("src/main.lua L42", result)
    end)

    it("formats line range reference", function()
      local result = core.format_reference("src/main.lua", 13, 17)
      assert.are.equal("src/main.lua L13-L17", result)
    end)

    it("handles paths with spaces", function()
      local result = core.format_reference("path with spaces/file.lua", 5, 5)
      assert.are.equal("path with spaces/file.lua L5", result)
    end)

    it("handles paths with special characters", function()
      local result = core.format_reference(".devcontainer/devcontainer.json", 13, 17)
      assert.are.equal(".devcontainer/devcontainer.json L13-L17", result)
    end)

    it("returns nil when path is nil", function()
      local result = core.format_reference(nil, 42, 42)
      assert.is_nil(result)
    end)

    it("returns nil when start_line is nil", function()
      local result = core.format_reference("src/main.lua", nil, 42)
      assert.is_nil(result)
    end)
  end)

  describe("resolve_path", function()
    it("returns relative path to git root for file in repo", function()
      -- Create a buffer with a file path inside the repo
      local buf = vim.api.nvim_create_buf(true, false)
      local cwd = vim.fn.getcwd()
      local test_path = cwd .. "/lua/clip-line-ref/core.lua"
      vim.api.nvim_buf_set_name(buf, test_path)

      local result = core.resolve_path(buf, true)

      -- Should return relative path
      assert.is_not_nil(result)
      assert.are.equal("lua/clip-line-ref/core.lua", result)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("returns absolute path when use_git_root is false", function()
      local buf = vim.api.nvim_create_buf(true, false)
      local cwd = vim.fn.getcwd()
      local test_path = cwd .. "/lua/clip-line-ref/core.lua"
      vim.api.nvim_buf_set_name(buf, test_path)

      local result = core.resolve_path(buf, false)

      -- Should return absolute path
      assert.is_not_nil(result)
      assert.are.equal(test_path, result)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("returns nil for buffer without file name", function()
      local buf = vim.api.nvim_create_buf(true, false)
      -- No name set

      local result = core.resolve_path(buf, true)

      assert.is_nil(result)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("uses current buffer when no bufnr provided", function()
      local current_buf = vim.api.nvim_get_current_buf()
      local current_name = vim.api.nvim_buf_get_name(current_buf)

      if current_name ~= "" then
        local result = core.resolve_path(nil, true)
        assert.is_not_nil(result)
      else
        -- If current buffer has no name, should return nil
        local result = core.resolve_path(nil, true)
        assert.is_nil(result)
      end
    end)

    it("handles paths with special characters", function()
      local buf = vim.api.nvim_create_buf(true, false)
      local cwd = vim.fn.getcwd()
      -- Path with spaces and special chars (simulated)
      local test_path = cwd .. "/test file with spaces.lua"
      vim.api.nvim_buf_set_name(buf, test_path)

      local result = core.resolve_path(buf, true)

      -- Should return the path as-is without escaping
      assert.is_not_nil(result)
      assert.are.equal("test file with spaces.lua", result)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("defaults to use_git_root=true when not specified", function()
      local buf = vim.api.nvim_create_buf(true, false)
      local cwd = vim.fn.getcwd()
      local test_path = cwd .. "/lua/clip-line-ref/core.lua"
      vim.api.nvim_buf_set_name(buf, test_path)

      -- Call without use_git_root parameter
      local result = core.resolve_path(buf)

      -- Should return relative path (same as use_git_root=true)
      assert.is_not_nil(result)
      assert.are.equal("lua/clip-line-ref/core.lua", result)

      vim.api.nvim_buf_delete(buf, { force = true })
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

  describe("clipboard integration", function()
    local clip = require("clip-line-ref")

    it("copies reference to + register", function()
      -- Create a buffer with a file name
      local buf = vim.api.nvim_create_buf(true, false)
      local cwd = vim.fn.getcwd()
      local test_path = cwd .. "/lua/clip-line-ref/init.lua"
      vim.api.nvim_buf_set_name(buf, test_path)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "line 1", "line 2", "line 3" })
      vim.api.nvim_set_current_buf(buf)
      vim.api.nvim_win_set_cursor(0, { 2, 0 })

      -- Clear the register first
      vim.fn.setreg("+", "")

      -- Call copy()
      local result = clip.copy()

      -- Verify the reference was returned
      assert.are.equal("lua/clip-line-ref/init.lua L2", result)

      -- Verify the register was set
      local register_content = vim.fn.getreg("+")
      assert.are.equal("lua/clip-line-ref/init.lua L2", register_content)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("returns nil and does not set register for special buffer", function()
      -- Create a special buffer (nofile)
      local buf = vim.api.nvim_create_buf(true, false)
      vim.bo[buf].buftype = "nofile"
      vim.api.nvim_set_current_buf(buf)

      -- Set a known value in the register
      vim.fn.setreg("+", "original value")

      -- Call copy()
      local result = clip.copy()

      -- Should return nil
      assert.is_nil(result)

      -- Register should be unchanged
      local register_content = vim.fn.getreg("+")
      assert.are.equal("original value", register_content)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("get_reference returns formatted reference without copying", function()
      -- Create a buffer with a file name
      local buf = vim.api.nvim_create_buf(true, false)
      local cwd = vim.fn.getcwd()
      local test_path = cwd .. "/lua/clip-line-ref/core.lua"
      vim.api.nvim_buf_set_name(buf, test_path)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "line 1" })
      vim.api.nvim_set_current_buf(buf)
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Set a known value in the register
      vim.fn.setreg("+", "should not change")

      -- Call get_reference()
      local result = clip.get_reference()

      -- Verify the reference was returned
      assert.are.equal("lua/clip-line-ref/core.lua L1", result)

      -- Register should be unchanged
      local register_content = vim.fn.getreg("+")
      assert.are.equal("should not change", register_content)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("get_reference returns nil for special buffer", function()
      local buf = vim.api.nvim_create_buf(true, false)
      vim.bo[buf].buftype = "help"
      vim.api.nvim_set_current_buf(buf)

      local result = clip.get_reference()
      assert.is_nil(result)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("get_line_range", function()
    it("returns cursor line in normal mode", function()
      -- Create a buffer with some content
      local buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "line 1",
        "line 2",
        "line 3",
        "line 4",
        "line 5",
      })
      vim.api.nvim_set_current_buf(buf)

      -- Set cursor to line 3
      vim.api.nvim_win_set_cursor(0, { 3, 0 })

      -- Ensure we're in normal mode
      vim.cmd("stopinsert")

      local start_line, end_line = utils.get_line_range()
      assert.are.equal(3, start_line)
      assert.are.equal(3, end_line)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("returns cursor line for single line", function()
      -- Create a buffer with some content
      local buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "line 1",
      })
      vim.api.nvim_set_current_buf(buf)

      -- Set cursor to line 1
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      -- Ensure we're in normal mode
      vim.cmd("stopinsert")

      local start_line, end_line = utils.get_line_range()
      assert.are.equal(1, start_line)
      assert.are.equal(1, end_line)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)
end)
