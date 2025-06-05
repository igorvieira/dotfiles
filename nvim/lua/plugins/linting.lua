return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")
    
    local function command_exists(cmd)
      local handle = io.popen("which " .. cmd .. " 2>/dev/null")
      if handle then
        local result = handle:read("*a")
        handle:close()
        return result ~= ""
      end
      return false
    end

    local available_linters = {}
    
    if command_exists("eslint_d") then
      available_linters.javascript = { "eslint_d" }
      available_linters.typescript = { "eslint_d" }
      available_linters.javascriptreact = { "eslint_d" }
      available_linters.typescriptreact = { "eslint_d" }
    else
      local notified = false
      if not notified then
        vim.notify("eslint_d not found. Install via :Mason or npm install -g eslint_d", vim.log.levels.WARN)
        notified = true
      end
    end

    lint.linters_by_ft = available_linters

    local function safe_try_lint()
      local current_ft = vim.bo.filetype
      if available_linters[current_ft] then
        local ok, err = pcall(lint.try_lint)
        if not ok then
          available_linters[current_ft] = nil
          lint.linters_by_ft = available_linters
        end
      end
    end

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = safe_try_lint,
    })

    vim.keymap.set("n", "<leader>l", safe_try_lint, { desc = "Trigger linting" })
  end,
}
