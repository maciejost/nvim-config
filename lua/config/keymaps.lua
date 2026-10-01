-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Ensure Neo-tree is loaded before setting the keymap

-- Ctrl+Esc to exit terminal mode and jump back to code
vim.keymap.set("t", "<C-Esc>", "<C-\\><C-n><C-w>h", { desc = "Exit terminal, focus code" })

