set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/nerdtree'
Plugin 'easymotion/vim-easymotion'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'jiangmiao/auto-pairs'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-commentary'
Plugin 'unblevable/quick-scope'
Plugin 'davidhalter/jedi-vim'
Plugin 'vim-syntastic/syntastic'
Plugin 'Chiel92/vim-autoformat'

call vundle#end()            
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
set textwidth=79

colorscheme desert

let mapleader=" "

" Quick Html tag
imap << </

" Add new line above or below
nnoremap <silent><C-j> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><C-k> :set paste<CR>m`O<Esc>``:set nopaste<CR>

" NERDTree
map <C-n> :NERDTreeToggle<CR>

" CtrlP
let g:ctrlp_map='<c-p>'
let g:ctrlp_cmd='CtrlP'

" EasyMotion
let g:EasyMotion_do_mapping=0
let g:EasyMotion_smartcase=1
" Turn on case insensitive feature
let g:EasyMotion_smartcase=1
" JK motions: Line motions
let g:EasyMotion_startofline=1
nmap <Leader><Leader>s <Plug>(easymotion-s)

" Autoformat
nmap <Leader>== :Autoformat<CR>

" Jedi
let g:jedi#goto_command = "<C-]>"
let g:jedi#documentation_command = "K"
let g:jedi#usages_command = "<Leader>su"
let g:jedi#completions_command = "<C-Space>"
let g:jedi#rename_command = "<Leader>rn"
let g:jedi#auto_vim_configuration = 0
set completeopt=menuone,longest

" Custom
nnoremap <left> :bp<cr>
nnoremap <right> :bn<cr>
nnoremap <up> :tabp<cr>
nnoremap <down> :tabn<cr>

" Syntax
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_python_checkers = ['flake8']
