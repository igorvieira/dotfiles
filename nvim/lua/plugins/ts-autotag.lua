return {
  "windwp/nvim-ts-autotag",
  opts = {
    enable_close = true,  -- Auto close tags
    enable_rename = true, -- Auto rename tags
    filetypes = {
      "html",
      "xml",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "svelte",
      "vue",
      "astro",
    },
  },
  config = function(_, opts)
    require("nvim-ts-autotag").setup(opts)
  end,
}
