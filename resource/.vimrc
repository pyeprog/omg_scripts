" Prerequisite
" fzf:
" - fzf-bin
" - rtp+=/path/to/fzf
" - ignore: respecting .gitignore
" - page-up/page-down: export FZF_DEFAULT_OPTS='--bind ctrl-f:page-down,ctrl-b:page-up'
" tags:
" - ctags(macOs) / exuberant-ctags(debian)
" - .ctags(--python-kinds=-i)
" completion:
" - jedi
" - compile YCM
" debug:
" - vimproc.vim
" - pdb
" format:
" - ~/.flake8([flake8] max-line-length = 120)
" system copy:
" - osx=pbcopy & pbpaste; linux=xsel

set nocompatible
filetype off

call plug#begin('~/.vim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'easymotion/vim-easymotion'
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'unblevable/quick-scope'
Plug 'Chiel92/vim-autoformat'
Plug 'sheerun/vim-polyglot'
Plug 'dense-analysis/ale'
Plug 'tpope/vim-fugitive'
Plug 'ludovicchabant/vim-gutentags'
Plug 'ycm-core/YouCompleteMe'
Plug 'majutsushi/tagbar'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'itchyny/lightline.vim'
Plug 'Shougo/vimproc.vim'
Plug 'idanarye/vim-vebugger'
Plug 'christoomey/vim-system-copy'
Plug 'gioele/vim-autoswap'
Plug 'mhinz/vim-startify'

call plug#end()
filetype plugin indent on

syntax on
set nu
set smartindent
set cindent
set autoindent
set nobackup
set shiftwidth=4
set tabstop=4
set softtabstop=4
set smarttab
set expandtab
set nowrap
set hidden
set textwidth=120
set encoding=utf-8
set backspace=indent,eol,start
set splitbelow
" set termguicolors

colorscheme edge

let mapspace='\'

" Quick Html tag

" Add new line above or below
nnoremap <silent><C-j> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><C-k> :set paste<CR>m`O<Esc>``:set nopaste<CR>

" NERDTree
map <space>n :NERDTreeTabsToggle<CR>
map <space><space>n :NERDTreeClose<CR>:NERDTreeFind<CR>
let g:NERDTreeChDirMode=2
let g:NERDTreeShowHidden=1

" fzf
set rtp+=/usr/local/bin/fzf
nnoremap <space>p :Files<cr>
nnoremap <space><space>p :History<cr>
nnoremap <space>f :Ag<cr>
cmap ls Buffers<cr>
map <space>/ :BLines<cr>
omap <space>/ :BLines<cr>
cmap Glog Commites<cr>
nnoremap <space><space>h :Commands<cr>
nnoremap <space><space>su :Tags
let g:fzf_layout = { 'down': '~40%' }
let g:FZF_DEFAULT_OPTS='--bind ctrl-f:page-down,ctrl-b:page-up'

" EasyMotion
let g:EasyMotion_do_mapping=0
" Turn on case insensitive feature
let g:EasyMotion_smartcase=1
" JK motions: Line motions
let g:EasyMotion_startofline=1
map <space>l <Plug>(easymotion-bd-jk)
nmap <space>l <Plug>(easymotion-overwin-line)
nmap <space>s <Plug>(easymotion-sn)
omap <space>s <Plug>(easymotion-sn)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)

" Autoformat
nmap <space>== :Autoformat<CR>
let g:autoformat_autoindent = 0
let g:autoformat_retab = 0
let g:autoformat_remove_trailing_spaces = 0

" " Jedi
" let g:jedi#goto_command = "<C-]>"
" let g:jedi#documentation_command = "K"
" let g:jedi#usages_command = "<space>su"
" let g:jedi#completions_command = "<C-Space>"
" let g:jedi#rename_command = "<space>rn"
" let g:jedi#auto_vim_configuration = 0
" set completeopt=menuone,longest

" Ale
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['eslint'],
\   'python': ['flake8']
\}
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
nmap <silent> <space>k <Plug>(ale_previous_wrap)
nmap <silent> <space>j <Plug>(ale_next_wrap)

" git fugitive
nnoremap <space>bl :Gblame<cr>
nnoremap <space>g :G<cr>

" lightline
let g:lightline = {
      \ 'colorscheme': 'one',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

" YouCompleteMe
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1

" tagbar
nnoremap <space>u :TagbarToggle<CR>

" vebugger
nnoremap <space><space>d :VBGstartPDB
nnoremap <space><space>b :VBGtoggleBreakpointThisLine<cr>
nnoremap <space><space>e :VBGeval
nnoremap <space>ew :VBGevalWordUnderCursor<cr>
nnoremap <F9> :VBGcontinue<cr>
nnoremap <F8> :VBGstepOver<cr>
nnoremap <F7> :VBGstepIn<cr>
nnoremap <F6> :VBGstepOut<cr>
nnoremap <F1> :VBGkill<cr>

" Custom
set shell=/bin/bash\ --login
nnoremap <leader>rc :tabe ~/.vimrc<cr>
nnoremap <leader>sr :source ~/.vimrc<cr>
nnoremap <up> :bp<cr>
nnoremap <down> :bn<cr>
nnoremap <left> :tabp<cr>
nnoremap <right> :tabn<cr>
nnoremap <space>tt :term<cr>
nnoremap <space><space>t :term<cr>
inoremap <c-r><c-r> <c-r>"
cnoremap <c-r><c-r> <c-r>"
inoremap <c-w> <esc>Ea
inoremap <c-b> <esc>Bi
inoremap <c-j> <esc>o
inoremap <c-k> <esc>O
inoremap <c-n> <esc>}A
inoremap <c-p> <esc>{A
inoremap <c-a> <esc>I
inoremap <c-e> <esc>A
nnoremap <c-n> }
nnoremap <c-p> {
