-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- Delete/change without clobbering the unnamed/system clipboard registers.
-- Yank still copies normally; delete/change always go to the black-hole register.
map({ "n", "x" }, "d", '"_d', { desc = "Delete without yanking" })
map({ "n", "x" }, "D", '"_D', { desc = "Delete to line end without yanking" })
map({ "n", "x" }, "c", '"_c', { desc = "Change without yanking" })
map({ "n", "x" }, "C", '"_C', { desc = "Change to line end without yanking" })
map({ "n", "x" }, "x", '"_x', { desc = "Delete char without yanking" })
map({ "n", "x" }, "X", '"_X', { desc = "Delete char backward without yanking" })
map({ "n", "x" }, "s", '"_s', { desc = "Substitute without yanking" })
map({ "n", "x" }, "S", '"_S', { desc = "Substitute line without yanking" })

-- Fallback mappings for moving lines/selections when Alt/Option combos are not
-- reliably forwarded by the terminal emulator.
map("n", "<A-Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-Down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-Up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

map("n", "<S-Down>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down (Fallback)" })
map("n", "<S-Up>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up (Fallback)" })
map("i", "<S-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down (Fallback)" })
map("i", "<S-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up (Fallback)" })
map("v", "<S-Down>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down (Fallback)" })
map("v", "<S-Up>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up (Fallback)" })
