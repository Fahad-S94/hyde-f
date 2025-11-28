-- ~/.config/nvim/lua/config/options.lua
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local opt = vim.opt

-- Allow cursor to move where there is no text in visual block mode
opt.whichwrap = "b,s,<,>,[,],h,l"
opt.wrap = true
opt.showbreak = "↪ "
-- opt.textwidth = 0 -- Don't auto wrap text
-- opt.wrapmargin = 0 -- Don't wrap based on terminal size
opt.linebreak = true -- Wrap on word boundaries
opt.breakindent = true -- Indent wrapped lines
opt.breakindentopt = "shift:2,min:40,sbr" -- Wrapped line indent options

opt.updatetime = 250
opt.timeoutlen = 400

opt.scrolloff = 10
opt.sidescrolloff = 10

vim.g.autoformat = true
