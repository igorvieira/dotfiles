return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "ts_ls", "html", "cssls", "tailwindcss", "lua_ls", "emmet_ls" },
      automatic_installation = true,
    })
    require("mason-tool-installer").setup({
      ensure_installed = { "prettier", "stylua", "eslint_d" },
    })
  end,
}
