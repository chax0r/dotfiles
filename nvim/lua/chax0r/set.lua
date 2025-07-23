vim.opt.guicursor = ""  -- Empty string to disable cursor styling
-- OR use a proper guicursor format:
-- vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false

-- Fix the undodir path (HOME should be uppercase)
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.g.mapleader = " "

-- Additional productivity settings
vim.opt.ignorecase = true      -- Case insensitive searching
vim.opt.smartcase = true       -- Case sensitive if uppercase is used
vim.opt.mouse = "a"            -- Enable mouse support
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard
vim.opt.splitbelow = true      -- Horizontal splits go below
vim.opt.splitright = true     -- Vertical splits go right
vim.opt.cursorline = true      -- Highlight current line
vim.opt.number = true          -- Show line numbers (you already have this)

-- Better completion experience
vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.pumheight = 10         -- Popup menu height

-- Faster scrolling
vim.opt.lazyredraw = true      -- Don't redraw during macros
vim.opt.ttyfast = true         -- Fast terminal connection

-- Better search
vim.opt.showmatch = true       -- Show matching brackets
vim.opt.matchtime = 2          -- How long to show matching bracket

-- Indentation
vim.opt.autoindent = true      -- Auto indent new lines
vim.opt.breakindent = true     -- Maintain indent when wrapping

-- File handling
vim.opt.autoread = true        -- Auto reload files changed outside vim
vim.opt.hidden = true          -- Allow hidden buffers

-- Visual improvements
vim.opt.showmode = false       -- Don't show mode (status line shows it)
vim.opt.showcmd = true         -- Show partial commands
vim.opt.cmdheight = 1          -- Command line height
vim.opt.ruler = true           -- Show cursor position

-- Performance
vim.opt.timeout = true
vim.opt.timeoutlen = 300       -- Faster key sequence timeout
vim.opt.ttimeoutlen = 0        -- Eliminate delays on ESC

-- Folding (optional)
vim.opt.foldmethod = "indent"  -- Fold based on indentation
vim.opt.foldlevel = 99         -- Start with all folds open

-- Create necessary directories
vim.fn.system("mkdir -p " .. os.getenv("HOME") .. "/.vim/{backup,swap,undodir}")

-- Disable some built-in plugins for faster startup
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimbao = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
--[[ vim.g.loaded_netrw = 1         -- Disable netrw (you might want this if using a file explorer plugin)
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1
]]
local function organize_imports_sync()
  -- Check if LSP is attached and supports code actions
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if not clients or #clients == 0 then
    return
  end
  -- Check if any client supports code actions
  local supports_code_actions = false
  for _, client in pairs(clients) do
    if client.server_capabilities.codeActionProvider then
      supports_code_actions = true
      break
    end
  end
  if not supports_code_actions then
    return
  end

  -- Get the entire document range
  local bufnr = vim.api.nvim_get_current_buf()
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ['end'] = { line = line_count, character = 0 }
    },
    context = {
      only = { 'source.organizeImports' },
      diagnostics = vim.diagnostic.get(bufnr)
    }
  }
  local result = vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, 1000)
  if not result then
    return
  end
  for _, res in pairs(result) do
    for _, r in pairs(res.result or {}) do
      if r.edit then
        vim.lsp.util.apply_workspace_edit(r.edit, 'UTF-8')
      end
    end
  end
end

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- Remove trailing whitespace
    vim.cmd([[%s/\s\+$//e]])
    organize_imports_sync()
  end,
})

-- Diagnostic settings (works well with your LSP setup)
vim.diagnostic.config({
  virtual_text = {
    prefix = '●', -- Could be '■', '▎', 'x', '●'
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Auto-formatting on save (optional)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- Remove trailing whitespace
    vim.cmd([[%s/\s\+$//e]])
    organize_imports_sync()
  end,
})

-- Use this in the autocmd callback instead

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 300 })
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 1 and line <= vim.fn.line("$") then
      vim.cmd('normal! g`"')
    end
  end,
})
