-- ~/.config/nvim/lua/plugins/cheatsheet.lua
-- Complete keymap cheatsheet with ALL keymaps (defaults + custom)
--
-- return {
--   -- Legendary.nvim - THE BEST for complete keymap listing
--   {
--     "mrjones2014/legendary.nvim",
--     -- priority = 10000,
--     lazy = true,
--     dependencies = { "kkharji/sqlite.lua" },
--     opts = {
--       -- Include all keymaps
--       include_builtin = true, -- Include Neovim built-in keymaps
--       include_legendary_cmds = true,
--       -- Sorting options
--       sort = {
--         -- Sort by frecency (frequency + recency)
--         frecency = {
--           -- Use SQLite for persistent frecency data
--           db_root = vim.fn.stdpath("data") .. "/legendary/",
--           max_timestamps = 10,
--         },
--       },
--       -- UI settings
--       col_separator_char = "│",
--       extensions = {
--         lazy_nvim = true, -- Auto-register lazy.nvim keymaps
--         which_key = {
--           auto_register = true, -- Auto-register which-key keymaps
--           use_groups = true,
--         },
--       },
--       -- Finder keymaps configuration
--       select_prompt = "Legendary",
--       select_opts = {
--         close_on_select = true,
--       },
--     },
--     keys = {
--       -- {
--       --   "<leader>fk",
--       --   "<cmd>Legendary keymaps<CR>",
--       --   desc = "Search Keymaps (All)",
--       -- },
--       -- {
--       --   "<leader>fC",
--       --   "<cmd>Legendary commands<CR>",
--       --   desc = "Search Commands",
--       -- },
--       -- {
--       --   "<leader>fa",
--       --   "<cmd>Legendary autocmds<CR>",
--       --     --   desc = "Search Autocmds",
--       --     -- },
--       {
--         "<leader>ch",
--         "<cmd>Legendary<CR>",
--         desc = "Legendary Cheatsheet",
--       },
--     },
--   },
-- }
--
--
-- ~/.config/nvim/lua/plugins/cheatsheet.lua
-- Complete keymap cheatsheet with ALL keymaps (defaults + custom)

-- ~/.config/nvim/lua/plugins/cheatsheet.lua
-- Legendary.nvim - Minimal keymap cheatsheet

return {
  {
    "mrjones2014/legendary.nvim",
    lazy = true,
    opts = {
      include_builtin = true, -- Show Neovim built-in keymaps
      extensions = {
        lazy_nvim = true, -- Auto-register lazy.nvim keymaps
        which_key = {
          auto_register = true, -- Auto-register which-key keymaps
        },
      },
    },
    keys = {
      {
        "<leader>ch",
        "<cmd>Legendary<CR>",
        desc = "Cheatsheet (All Keymaps)",
      },
    },
  },
}
