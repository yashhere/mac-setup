--[[
  Minimal Neovim Configuration
  A clean, fast setup for everyday editing
]]

-- Set leader key before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load configuration modules
require("options")
require("keymaps")
require("plugins")
