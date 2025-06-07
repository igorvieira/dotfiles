return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    local eslint_d_available = vim.fn.executable("eslint_d") == 1
    local linters_by_ft = {}

    if eslint_d_available then
      local filetypes = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
      }

      for _, ft in ipairs(filetypes) do
        linters_by_ft[ft] = { "eslint_d" }
      end
    else
      vim.schedule(function()
        vim.notify(
          "eslint_d not found. Install via :Mason or npm install -g eslint_d",
          vim.log.levels.WARN
        )
      end)
    end

    lint.linters_by_ft = linters_by_ft

    local function safe_try_lint()
      local ft = vim.bo.filetype
      if linters_by_ft[ft] then
        local ok, err = pcall(lint.try_lint)
        if not ok then
          vim.notify("Lint error: " .. err, vim.log.levels.ERROR)
          linters_by_ft[ft] = nil
          lint.linters_by_ft = linters_by_ft
        end
      end
    end

    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd(
      { "BufEnter", "BufWritePost", "InsertLeave" },
      {
        group = lint_augroup,
        callback = safe_try_lint,
      }
    )

    vim.keymap.set("n", "<leader>l", safe_try_lint, { desc = "Trigger linting" })
  end,
}

