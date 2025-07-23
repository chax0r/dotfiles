vim.lsp.enable('lua_ls')
vim.api.nvim_create_autocmd('LspAttach', {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client then
			return
		end	
		if client:supports_method('textDocument/completion') then
			vim.opt.completeopt = {'menu', 'menuone', 'noinsert', 'fuzzy', 'popup'}
			vim.lsp.completion.enable(true, client.id, ev.buf, {autotrigger = true})
			vim.keymap.set('i', '<C-Space>', function()
				vim.lsp.completion.get()
			end, { buffer = ev.buf })

				-- Navigate completion menu
			vim.keymap.set('i', '<C-n>', '<C-n>', { buffer = ev.buf, noremap = true })
			vim.keymap.set('i', '<C-p>', '<C-p>', { buffer = ev.buf, noremap = true })
			
			-- Accept completion with Enter or Tab
			vim.keymap.set('i', '<CR>', '<C-y>', { buffer = ev.buf, noremap = true })
			vim.keymap.set('i', '<Tab>', '<C-y>', { buffer = ev.buf, noremap = true })
		end
			-- Add some useful LSP keymaps
		local opts = { buffer = ev.buf, noremap = true, silent = true }
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
		vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
		vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, opts)
		vim.keymap.set('n', '[d', function()
		vim.diagnostic.jump({ count = -1 })
		end, opts)
		vim.keymap.set('n', ']d', function()
			vim.diagnostic.jump({ count = 1 })
		end, opts)
	end,
})

vim.diagnostic.config({
virtual_lines = true,
signs = true,
underline = true,
})
