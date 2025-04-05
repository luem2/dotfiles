-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }

-- select all
keymap.set("n", "<leader>a", "gg<S-v>G", opts)

-- fast navigation between the first 5 buffers
keymap.set("n", "<leader>1", "<cmd>BufferLineGoToBuffer 1<CR>", opts)
keymap.set("n", "<leader>2", "<cmd>BufferLineGoToBuffer 2<CR>", opts)
keymap.set("n", "<leader>3", "<cmd>BufferLineGoToBuffer 3<CR>", opts)
keymap.set("n", "<leader>4", "<cmd>BufferLineGoToBuffer 4<CR>", opts)
keymap.set("n", "<leader>5", "<cmd>BufferLineGoToBuffer 5<CR>", opts)

-- smooth motions
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

-- increment/decrement number
keymap.set("n", "<leader>+", "<C-a>", opts)
keymap.set("n", "<leader>-", "<C-x>", opts)

-- oil.nvim
keymap.set("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
