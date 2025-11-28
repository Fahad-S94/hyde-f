-- ~/.config/nvim/lua/plugins/blink-cmp.lua

return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        ghost_text = {
          enabled = false,
        },
        -- Make menu appear above cursor
        -- menu = {
        --   direction_priority = { "n", "s" },
        -- },
        -- Select last item instead of first
        -- list = {
        --   selection = {
        --     preselect = function(ctx)
        --       return ctx.items and #ctx.items > 0
        --     end,
        --   },
        -- },
      },

      -- Change Tab to select last item first when menu opens

      keymap = {
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.snippet_forward()
            else
              -- If nothing selected yet, select last item, otherwise accept
              if cmp.get_selected_item() == nil then
                return cmp.select_prev() -- selects from bottom
              else
                return cmp.accept()
              end
            end
          end,
          "fallback",
        },
      },
    },
  },
}
