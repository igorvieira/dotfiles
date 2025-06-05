return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-web-devicons").setup({
      override = {
        folder = {
          icon = "📁",
          color = "#D2B48C",
          name = "Folder"
        }
      },
      color_icons = true,
      default = true,
    })

    require("nvim-tree").setup({
      view = { width = 35, side = "left" },
      renderer = {
        icons = {
          show = { file = true, folder = true, folder_arrow = true, git = true },
          glyphs = {
            folder = {
              arrow_closed = "",
              arrow_open = "",
              default = "",
              open = "",
              empty = "󰉋",
              empty_open = "",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "",
              renamed = "➜",
              untracked = "★",
              deleted = "",
              ignored = "◌",
            },
          },
        },
      },
      filters = { custom = { "node_modules", "\\.cache" } },
      git = { enable = true, ignore = false },
    })

    vim.cmd([[
      highlight NvimTreeFolderIcon guifg=#D2B48C
      highlight NvimTreeOpenedFolderIcon guifg=#D2B48C
      highlight NvimTreeEmptyFolderIcon guifg=#D2B48C
      highlight NvimTreeFolderName guifg=#E5E7EB gui=bold
      highlight NvimTreeOpenedFolderName guifg=#E5E7EB gui=bold
      highlight NvimTreeEmptyFolderName guifg=#E5E7EB gui=bold
    ]])

    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Find current file" })
    vim.keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse tree" })
    vim.keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh tree" })
  end
}
