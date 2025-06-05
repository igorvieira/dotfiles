return {
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    config = function()
      require("dracula").setup({
        colors = {
          bg = "#282A36", fg = "#F8F8F2", selection = "#44475A", comment = "#6272A4",
          red = "#FF5555", orange = "#FFB86C", yellow = "#F1FA8C", green = "#50fa7b",
          purple = "#BD93F9", cyan = "#8BE9FD", pink = "#FF79C6",
        },
        show_end_of_buffer = true,
        transparent_bg = false,
        lualine_bg_color = "#44475a",
        italic_comment = true,
      })
      vim.cmd("colorscheme dracula")
    end,
  },
}
