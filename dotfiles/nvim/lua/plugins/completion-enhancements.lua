-- ~/.config/nvim/lua/plugins/completion-enhancements.lua
-- Additional plugins to enhance completion experience

return {
  -- ==========================================================================
  -- AUTO-PAIRS: Better bracket/quote pairing
  -- ==========================================================================
  {
    "nvim-mini/mini.pairs",
    event = "VeryLazy",
    opts = {
      -- Modes where auto-pairs is active
      modes = { insert = true, command = false, terminal = false },

      -- Skip autopair when next character is one of these
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],

      -- Skip autopair when the cursor is inside these treesitter nodes
      skip_ts = { "string" },

      -- Skip autopair when next character is closing pair
      skip_unbalanced = true,

      -- Better markdown support
      markdown = true,
    },
  },

  -- ==========================================================================
  -- AUTOPAIRS ENHANCEMENT: Context-aware pairing
  -- ==========================================================================
  {
    "windwp/nvim-autopairs",
    enabled = false, -- Disable if using mini.pairs above
    event = "InsertEnter",
    opts = {
      check_ts = true, -- Use treesitter
      ts_config = {
        lua = { "string" }, -- Don't add pairs in lua string treesitter nodes
        javascript = { "template_string" },
        java = false, -- Don't check treesitter on java
      },
      disable_filetype = { "TelescopePrompt", "vim" },
      fast_wrap = {
        map = "<M-e>", -- Alt+e for fast wrap
        chars = { "{", "[", "(", '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "Search",
        highlight_grey = "Comment",
      },
    },
  },

  -- Comment.nvim, LuaSnip, and cmp-cmdline removed - already handled by LazyVim

  -- ==========================================================================
  -- COMPLETION ICONS: Better icons in completion menu
  -- ==========================================================================
  {
    "onsails/lspkind.nvim",
    opts = {
      mode = "symbol_text",
      preset = "codicons",
      symbol_map = {
        Text = "󰉿",
        Method = "󰆧",
        Function = "󰊕",
        Constructor = "",
        Field = "󰜢",
        Variable = "󰀫",
        Class = "󰠱",
        Interface = "",
        Module = "",
        Property = "󰜢",
        Unit = "󰑭",
        Value = "󰎠",
        Enum = "",
        Keyword = "󰌋",
        Snippet = "",
        Color = "󰏘",
        File = "󰈙",
        Reference = "󰈇",
        Folder = "󰉋",
        EnumMember = "",
        Constant = "󰏿",
        Struct = "󰙅",
        Event = "",
        Operator = "󰆕",
        TypeParameter = "",
      },
    },
  },

  -- ==========================================================================
  -- RECOMMENDATIONS: Additional useful plugins
  -- ==========================================================================

  -- 1. Better search/replace while typing
  {
    "nvim-pack/nvim-spectre",
    -- Already enabled if you have the search extra
    cmd = "Spectre",
    opts = {
      open_cmd = "noswapfile vnew",
    },
    keys = {
      {
        "<leader>sr",
        function()
          require("spectre").toggle()
        end,
        desc = "Replace in files (Spectre)",
      },
    },
  },

  -- 2. Better word motions (optional)
  {
    "chrisgrieser/nvim-spider",
    enabled = false, -- Enable if you want smarter word motions
    lazy = true,
    keys = {
      {
        "w",
        "<cmd>lua require('spider').motion('w')<CR>",
        mode = { "n", "o", "x" },
        desc = "Spider-w",
      },
      {
        "e",
        "<cmd>lua require('spider').motion('e')<CR>",
        mode = { "n", "o", "x" },
        desc = "Spider-e",
      },
      {
        "b",
        "<cmd>lua require('spider').motion('b')<CR>",
        mode = { "n", "o", "x" },
        desc = "Spider-b",
      },
    },
  },

  -- 3. Highlight word under cursor (already enabled via illuminate extra)
  -- vim-illuminate is already configured via editor.illuminate extra

  -- 4. Better folding (optional - UFO for better fold preview)
  {
    "kevinhwang91/nvim-ufo",
    enabled = false, -- Enable if you want advanced folding
    dependencies = "kevinhwang91/promise-async",
    event = "BufReadPost",
    opts = {
      provider_selector = function()
        return { "treesitter", "indent" }
      end,
    },
    config = function(_, opts)
      require("ufo").setup(opts)
      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
    end,
  },
}
