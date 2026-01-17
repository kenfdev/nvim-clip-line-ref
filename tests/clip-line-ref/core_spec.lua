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
    it("detects special buffers", function()
      -- TODO: Implement test
      pending("not implemented")
    end)
  end)
end)
