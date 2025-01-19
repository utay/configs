set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

call plug#begin('~/.vim/plugged')

" GUI enhancements
Plug 'itchyny/lightline.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Semantic language support
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp' " Autocompletion plugin
Plug 'hrsh7th/cmp-nvim-lsp' " LSP source for nvim-cmp
Plug 'hrsh7th/cmp-path' " Autocompletion for filesystem paths
Plug 'hrsh7th/cmp-buffer' " Autocompletion for buffer words
Plug 'hrsh7th/cmp-cmdline' " Autocompletion for vim command line
Plug 'ray-x/lsp_signature.nvim' " Show function signature when you type
Plug 'j-hui/fidget.nvim' " LSP progress status
Plug 'windwp/nvim-autopairs' " Write pairs

" Syntactic language support
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'
Plug 'rust-lang/rust.vim'
Plug 'darrikonn/vim-gofmt', { 'do': ':GoUpdateBinaries' }

" treesitter doesn't support terraform
Plug 'hashivim/vim-terraform'

Plug 'APZelos/blamer.nvim'

call plug#end()

" Lightline
let g:lightline = {
      \ 'component_function': {
      \   'filename': 'LightlineFilename',
      \ },
\ }
function! LightlineFilename()
  return expand('%:t') !=# '' ? @% : '[No Name]'
endfunction

let g:ctrlp_custom_ignore = 'node_modules\|target'

" Blamer
let g:blamer_delay = 500

" terraform auto format
" autocmd BufWritePre *.tf call terraform#fmt()

nnoremap <space> :bp<CR>

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Rust
" let g:rustfmt_autosave = 1
" let g:rustfmt_emit_files = 1
" let g:rustfmt_fail_silently = 0
" let g:rust_clip_command = 'xclip -selection clipboard'

" Go
" autocmd BufWritePre *.go :silent GoFmt

" Fix for 'set autoread' to work: https://github.com/neovide/neovide/issues/1477
" VimResume is needed when running 'fg'
autocmd FocusGained,VimResume * checktime

function! LspStatus() abort
  if luaeval('#vim.lsp.buf_get_clients() > 0')
    return luaeval("require('lsp-status').status()")
  endif

  return ''
endfunction

lua <<EOF
-- Disable to make base16-onedark work (in vimrc)
vim.o.termguicolors = false

-- Enable syntax highlighting
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true
  }
}

-- LSP configuration
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
  }, {
    { name = 'path' },
  }, {
    { name = 'buffer' },
  }),
  preselect = cmp.PreselectMode.None,
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup language servers.
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local fidget = require('fidget')
fidget.setup{}

local lsp_signature = require('lsp_signature')
lsp_signature.setup{}

local autopairs = require('nvim-autopairs')
autopairs.setup{}

local lspconfig = require('lspconfig')

-- Rust
lspconfig.rust_analyzer.setup {
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    ['rust-analyzer'] = {},
  },
  capabilities = capabilities,
}

-- Go
lspconfig.gopls.setup{}

-- Typescript
lspconfig.ts_ls.setup{}

lspconfig.ccls.setup {
  init_options = {
    cache = {
      directory = ".ccls-cache";
    };
  }
}

-- Terraform
lspconfig.terraformls.setup{}

-- Zig
lspconfig.zls.setup{}
-- Disable native autosave to avoid conflict with zls
vim.g.zig_fmt_autosave = 0

lspconfig.gdscript.setup{}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '1', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]
EOF
