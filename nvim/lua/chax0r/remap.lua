vim.g.mapleader = " "
vim.keymap.set("n","-",vim.cmd.Ex) -- navigates one directory up from netwrp
-- undoTree
vim.api.nvim_set_keymap('n', '<leader>u', ':UndotreeToggle', {noremap = true})

