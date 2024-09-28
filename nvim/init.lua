vim.wo.number = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.opt.autoindent = true
vim.opt.smartindent = true

vim.cmd[[syntax enable]]
vim.opt.termguicolors = true

-- Initialize packer.nvim
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Packer manages itself


  -- Syntax highlighting
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'AlessandroYorba/Alduin'
  use 'savq/melange-nvim'
  -- LSP and Autocompletion plugins
  use 'neovim/nvim-lspconfig'    -- Neovim LSP configuration
  use 'hrsh7th/nvim-cmp'         -- Autocompletion plugin
  use 'hrsh7th/cmp-nvim-lsp'     -- LSP source for nvim-cmp
  use 'hrsh7th/cmp-buffer'       -- Buffer source for nvim-cmp
  use 'hrsh7th/cmp-path'         -- Path source for nvim-cmp

  -- Snippet engine (optional)
  use 'hrsh7th/vim-vsnip'        -- Snippet engine
  use 'hrsh7th/cmp-vsnip'        -- Snippet source for nvim-cmp

  -- Icons for autocompletion (optional)
  use 'onsails/lspkind-nvim'     -- Adds icons to autocomplete
end)


-- Syntax highlighting
require('nvim-treesitter.configs').setup {
  ensure_installed = { "c", "cpp", "cuda" },
  highlight = {
    enabled = true,
    additional_vim_regex_highlighting = false,
  },
}

-- Autocommand to enable Treesitter highlighting on every buffer
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*",
  callback = function()
    vim.cmd("TSEnable highlight")
  end
})

vim.cmd[[colorscheme alduin]]



-- LSP settings
local nvim_lsp = require('lspconfig')

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
-- Enable clangd
nvim_lsp.clangd.setup{
  cmd = { "clangd", "--compile-commands-dir=/home/askourtis/test_cake/build" , "--background-index" },
  filetypes = { "cu", "h", "hpp", "c", "cpp", "objc", "objcpp" },
  root_dir = nvim_lsp.util.root_pattern(".git", "CMakeFiles.txt", "Makefile"),
  capabilities = capabilities,
}



-- Autocompletion settings
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      -- For `vsnip` users
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    -- Key mappings for completion
    ['<C-p>'] = cmp.mapping.scroll_docs(-4),
    ['<C-n>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept selected item
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' }, -- For vsnip users
  }, {
    { name = 'buffer' },
  }),
  formatting = {
    format = require('lspkind').cmp_format({ with_text = true, maxwidth = 50 })
  }
})

-- Use buffer source for `/` and `?`
cmp.setup.cmdline({ '/', '?' }, {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for `:`
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Show tabs and spaces
vim.opt.list = true
vim.opt.listchars = { space = '·', tab = '→ ' }


-- Function to trim trailing whitespace and excess newlines
function TrimWhitespace()
  -- Remove trailing whitespace
  vim.cmd([[%s/\s\+$//e]])

  -- Remove excess blank lines at end of file, leaving one
  local last_nonblank = vim.fn.prevnonblank('$')
  local last_line = vim.fn.line('$')
  if last_line - last_nonblank > 1 then
    vim.cmd(string.format('%d,$d', last_nonblank + 2))
  end
end

-- Auto-command to trim whitespace and newlines on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = TrimWhitespace
})
