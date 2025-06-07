return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "ts_ls",
        "html",
        "cssls",
        "tailwindcss",
        "lua_ls",
        "emmet_ls",
        "rust_analyzer",
        "pyright",
        "clangd",
        "elixirls",
        "ruby_lsp",
        "astro",
        "volar"
      },
      automatic_installation = true,
    })

    local tools_to_install = {
      "prettier",
      "stylua",
      "eslint_d",
      "black",
      "isort",
      "rustfmt",
      "clang-format",
      "rubocop",
      "pylint",
    }

    local function install_tools()
      local registry = require("mason-registry")

      for _, tool in ipairs(tools_to_install) do
        local p = registry.get_package(tool)
        if not p:is_installed() then
          vim.notify("Instalando " .. tool .. "...", vim.log.levels.INFO)
          p:install()
        else
          vim.notify(tool .. " já está instalado", vim.log.levels.INFO)
        end
      end
    end

    vim.api.nvim_create_user_command("MasonInstallTools", function()
      install_tools()
    end, { desc = "Instalar todas as ferramentas necessárias" })

    vim.api.nvim_create_autocmd("User", {
      pattern = "MasonRegistryReady",
      callback = function()
      end,
    })
  end,
}
