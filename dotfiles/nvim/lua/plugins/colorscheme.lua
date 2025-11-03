-- ~/.config/nvim/lua/plugins/colorscheme.lua
-- OneDarkPro theme configuration with 3 alpha dashboard color schemes

return {
  {
    "folke/tokyonight.nvim",
    enabled = false,
  },
  {
    "olimorris/onedarkpro.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      -- 1. DRACULA - Vibrant & dark (CURRENTLY ACTIVE)
      highlights = {
        AlphaHeader = { fg = "#bd93f9", style = "bold" }, -- Purple
        AlphaButtons = { fg = "#8be9fd" }, -- Cyan
        AlphaFooter = { fg = "#6272a4", style = "italic" }, -- Comment gray
        AlphaShortcut = { fg = "#ff79c6" }, -- Pink
      },
      -- 2. TOKYONIGHT NIGHT - Deep dark variant
      -- highlights = {
      --   AlphaHeader = { fg = "#7aa2f7", style = "bold" }, -- Blue
      --   AlphaButtons = { fg = "#9d7cd8" }, -- Purple
      --   AlphaFooter = { fg = "#565f89", style = "italic" }, -- Comment
      --   AlphaShortcut = { fg = "#f7768e" }, -- Red
      -- },
      options = {
        cursorline = true,
        transparency = false,
        terminal_colors = true,
        lualine_transparency = false,
        highlight_inactive_windows = false,
      },
    },
    config = function(_, opts)
      require("onedarkpro").setup(opts)
      vim.cmd("colorscheme onedark_dark")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark_dark",
    },
  },
}
