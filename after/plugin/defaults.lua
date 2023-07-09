-- Shorten function name
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local telescope_builtin = require 'telescope.builtin'

vim.opt.relativenumber = true

vim.keymap.set('n', '<leader>ch', telescope_builtin.command_history, { desc = '[C]ommand [H]istory' })
vim.keymap.set('n', '<leader>dkm', telescope_builtin.keymaps, { desc = '[D]isplay [K]ey [M]aps' })
vim.keymap.set('n', '<leader>dsm', telescope_builtin.lsp_document_symbols, { desc = '[D]ocument [S]ymbols' })
vim.keymap.set('n', '<leader>ff', '<cmd>lua vim.lsp.buf.format()<CR>', { desc = '[F]ormat [F]ile' })
vim.keymap.set('n', '<leader>ft', '<cmd>Neotree toggle<cr><CR>', { desc = '[F]ile [T]ree' })
vim.keymap.set('n', '<leader>gbr', telescope_builtin.git_branches, { desc = '[G]it [Br]anches' })
vim.keymap.set('n', '<leader>gbt', '<cmd>GitBlameToggle<cr><CR>', { desc = '[G]it [B]lame [T]oggle' })
vim.keymap.set('n', '<leader>gs', telescope_builtin.git_status, { desc = '[G]it [S]tatus' })
vim.keymap.set('n', '<leader>ht', telescope_builtin.help_tags, { desc = '[G]it [B]lame [T]oggle' })
vim.keymap.set('n', '<leader>jl', telescope_builtin.jumplist, { desc = '[J]ump [L]ist' })
vim.keymap.set('n', '<leader>lg', '<cmd>LazyGit<cr><CR>', { desc = '[L]azy [G]it' })
vim.keymap.set('n', '<leader>pf', '<cmd>Prettier<cr><CR>', { desc = '[P]rettier [F]ormat' })
vim.keymap.set('n', '<leader>rd', telescope_builtin.diagnostics, { desc = '[R]un [D]iagnostics' })
vim.keymap.set('n', '<leader>sb', telescope_builtin.buffers, { desc = '[S]earch [B]uffer' })
vim.keymap.set('n', '<leader>sr', telescope_builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>sof', telescope_builtin.oldfiles, { desc = '[S]earch [O]ld [F]iles' })
vim.keymap.set('n', '<leader>svo', telescope_builtin.vim_options, { desc = '[S]et [V]im [O]ptions' })

vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").open()<CR>', {
	desc = 'Open Spectre',
})
vim.keymap.set('n', '<leader>sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
	desc = 'Search current word',
})
vim.keymap.set('v', '<leader>sw', '<esc><cmd>lua require("spectre").open_visual()<CR>', {
	desc = 'Search current word',
})
vim.keymap.set('n', '<leader>sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
	desc = 'Search on current file',
})

-- Normal --
-- Better window navigation
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)

-- Resize with arrows
keymap('n', '<C-Up>', ':resize -2<CR>', opts)
keymap('n', '<C-Down>', ':resize +2<CR>', opts)
keymap('n', '<C-Left>', ':vertical resize -2<CR>', opts)
keymap('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- Navigate buffers
keymap('n', '<S-l>', ':bnext<CR>', opts)
keymap('n', '<S-h>', ':bprevious<CR>', opts)

-- Move text up and down
keymap('n', '<A-j>', '<Esc>:m .+1<CR>==gi', opts)
keymap('n', '<A-k>', '<Esc>:m .-2<CR>==gi', opts)

-- Insert --
-- Press jk fast to exit insert mode
keymap('i', 'jk', '<ESC>', opts)
keymap('i', 'kj', '<ESC>', opts)

-- Visual --
-- Stay in indent mode
keymap('v', '<', '<gv', opts)
keymap('v', '>', '>gv', opts)

-- Move text up and down
keymap('v', '<A-j>', ':m .+1<CR>==', opts)
keymap('v', '<A-k>', ':m .-2<CR>==', opts)
keymap('v', 'p', '"_dP', opts)
