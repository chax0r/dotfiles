-- Load and apply LSP configurations
local config_path = vim.fn.stdpath('config')
local lua_ls_config = dofile(config_path .. '/lsp/lua_ls.lua')
local phpactor_config = dofile(config_path .. '/lsp/phpactor.lua')
local gopls_config = dofile(config_path .. '/lsp/gopls.lua')

-- Add capabilities for code actions and completion
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.codeAction = {
  dynamicRegistration = true,
  codeActionLiteralSupport = {
    codeActionKind = {
      valueSet = (function()
        local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
        table.sort(res)
        return res
      end)()
    }
  }
}

-- Apply configurations with capabilities
vim.lsp.config('lua_ls', vim.tbl_extend('force', lua_ls_config, { capabilities = capabilities }))
vim.lsp.config('phpactor', vim.tbl_extend('force', phpactor_config, { capabilities = capabilities }))
vim.lsp.config('gopls', vim.tbl_extend('force', gopls_config, { capabilities = capabilities }))

-- Enable the servers
vim.lsp.enable('lua_ls')
vim.lsp.enable('phpactor')
vim.lsp.enable('gopls')
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
			vim.keymap.set('i', '<Tab>', '<C-y>', { buffer = ev.buf, noremap = true })
		end
			-- Add some useful LSP keymaps
		local opts = { buffer = ev.buf, noremap = true, silent = true }
		vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
		vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
		vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
		vim.keymap.set('n', '<leader>ca', function()
			print("Code action called!")
			vim.lsp.buf.code_action()
		end, opts)
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
