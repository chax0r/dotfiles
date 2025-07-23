local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  -- My plugins here
  -- use 'foo1/bar1.nvim'
  -- use 'foo2/bar2.nvim'

  -- telescope
  use {
  'nvim-telescope/telescope.nvim', tag = '0.1.8',
  -- or                            , branch = '0.1.x',
  requires = { {'nvim-lua/plenary.nvim'} }
 }

  -- color schemes
--  use({ 'nanotech/jellybeans.vim' })
use ({ 'rose-pine/neovim', as = 'rose-pine', 
	config = function()
			vim.cmd("colorscheme rose-pine")
		end })
  -- treesiter
  use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate'})

  -- undoTree
  use { "jiaoshijie/undotree" }

  -- Add Fugitive here
  use 'tpope/vim-fugitive'

  -- Add Git Gutter here
  use 'airblade/vim-gitgutter'

  use ('ThePrimeagen/harpoon')

  use('neovim/nvim-lspconfig')

  use {'nvim-telescope/telescope-ui-select.nvim' }

end)
