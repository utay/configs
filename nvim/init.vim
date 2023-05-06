set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

call plug#begin('~/.vim/plugged')

" GUI enhancements
Plug 'itchyny/lightline.vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" Semantic language support
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Syntactic language support
Plug 'cespare/vim-toml'
Plug 'stephpy/vim-yaml'

" treesitter doesn't support terraform
Plug 'hashivim/vim-terraform'

Plug 'github/copilot.vim'
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

" Enable syntax highlighting
lua <<EOF
require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true
  }
}
EOF

let g:ctrlp_custom_ignore = 'node_modules\|target'

" coc config
let g:coc_global_extensions = [
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-json',
  \ 'coc-rust-analyzer'
  \ ]
" from readme

" Copilot
let g:copilot_enabled = v:false

" Blamer
let g:blamer_delay = 500

" coc go auto import
autocmd BufWritePre *.go :silent call CocAction('runCommand', 'editor.action.organizeImport')

" terraform auto format
autocmd BufWritePre *.tf call terraform#fmt()

nnoremap 1 :call CocAction('jumpDefinition', 'edit')<CR>
nmap <silent> gi <Plug>(coc-implementation)
nnoremap <space> :bp<CR>

" Use tab for trigger completion with characters ahead and navigate.
" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
" Confirm completion (and auto import) with enter
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm() : "\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
