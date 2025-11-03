-- ~/.config/nvim/lua/config/keymaps.lua
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- ============================================================================
-- NORMAL MODE - CUSTOM KEYMAPS
-- ============================================================================

-- Undo/Redo with common shortcuts
map("n", "<C-z>", "u", { desc = "Undo" })
map("n", "<C-y>", "<C-r>", { desc = "Redo" })

-- Clipboard operations
-- map("n", "<C-c>", '"+yy', { desc = "Copy line to clipboard" })
-- map("n", "<C-v>", '"+p', { desc = "Paste from clipboard" })

-- Duplicate line down
map("n", "<A-Down>", "yyp", { desc = "Duplicate line down" })

-- ============================================================================
-- INSERT MODE - CUSTOM KEYMAPS
-- ============================================================================

-- Save in insert mode
-- map("i", "<C-s>", "<Esc>:w<CR>a", { desc = "Save in insert mode" })

-- Undo/Redo in insert mode
map("i", "<C-z>", "<C-o>u", { desc = "Undo in insert mode" })
map("i", "<C-y>", "<C-o><C-r>", { desc = "Redo in insert mode" })

-- Paste from clipboard
-- map("i", "<C-v>", "<C-r>+", { desc = "Paste from clipboard" })

-- Delete word backwards (Alt+Backspace)
map("i", "<M-BS>", "<C-w>", { desc = "Delete word backwards" })

-- Delete entire line (Ctrl+Alt+Backspace)
map("i", "<C-M-BS>", "<C-o>dd", { desc = "Delete entire line" })

-- ============================================================================
-- VISUAL MODE - CUSTOM KEYMAPS
-- ============================================================================

-- Copy selection to clipboard
-- map("v", "<C-c>", '"+y', { desc = "Copy selection to clipboard" })

-- Paste over selection (from clipboard)
-- map("v", "<C-v>", '"+p', { desc = "Paste over selection" })

-- Delete selection with Backspace
-- map("v", "<BS>", "d", { desc = "Delete selection" })

-- ============================================================================
-- OPTIONAL: UNCOMMENT IF YOU WANT THESE
-- ============================================================================

-- Exit insert mode with jk (very popular mapping)
-- map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Semicolon as colon for faster commands
-- map("n", ";", ":", { desc = "Enter command mode" })

-- Quick quit commands (LazyVim has <leader>qq for quit all)
-- map("n", "<Leader>q", ":q<CR>", { desc = "Quit current window" })
-- map("n", "<Leader>Q", ":qa<CR>", { desc = "Quit all" })

-- Select all with Ctrl+A (conflicts with increment in visual mode)
-- Note: LazyVim uses <C-a> for increment/decrement with dial.nvim
-- map("n", "<C-a>", "ggVG", { desc = "Select all" })
