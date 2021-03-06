if filereadable(expand("~/.vim/bundle/Vundle.vim/autoload/vundle.vim"))
    " be iMproved, required
    set nocompatible

    " also required
    filetype off

    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()

    " alternatively, pass a path where Vundle should install plugins
    "call vundle#begin('~/some/path/here')

    " let Vundle manage Vundle, required
    Plugin 'gmarik/Vundle.vim'

    " The following are examples of different formats supported.
    " Keep Plugin commands between vundle#begin/end.
    " plugin on GitHub repo
    Plugin 'tpope/vim-fugitive'

    " Also from tpope - asynchronous compilation / testing
    Plugin 'tpope/vim-dispatch'

    " NERDTree - Excellent directory explorer
    Plugin 'scrooloose/nerdtree'

    " That's a lot of typing to open NERDTree  :)
    map <c-n> :NERDTree<enter>

    " Go go gadget vim!
    Plugin 'fatih/vim-go'

    " Lovely status bar
    Plugin 'bling/vim-airline'
    set laststatus=2

    " Nice colorscheme, this
    Plugin 'nanotech/jellybeans.vim'

    """ Other loading examples...

    " plugin from http://vim-scripts.org/vim/scripts.html
    """ Plugin 'L9'

    " Git plugin not hosted on GitHub
    """ Plugin 'git://git.wincent.com/command-t.git'

    " git repos on your local machine (i.e. when working on your own plugin)
    """ Plugin 'file:///home/gmarik/path/to/plugin'

    " The sparkup vim script is in a subdirectory of this repo called vim.
    " Pass the path to set the runtimepath properly.
    """ Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

    " Avoid a name conflict with L9
    """ Plugin 'user/L9', {'name': 'newL9'}

    " All of your Plugins must be added before the following line
    call vundle#end()            " required
    filetype plugin indent on    " required
    " To ignore plugin indent changes, instead use:
    "filetype plugin on

    " Brief help
    " :PluginList       - lists configured plugins
    " :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
    " :PluginSearch foo - searches for foo; append `!` to refresh local cache
    " :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
    "
    " see :h vundle for more details or wiki for FAQ
    """""""""""""""""""""""""""""""""""""""""""""""
    " Put your non-Plugin stuff after this line
    """""""""""""""""""""""""""""""""""""""""""""""
endif

" UI preferences
abbrev gerp grep
set background=dark		" Classic CRT look
set nohlsearch			" Don't fill my screen with blocks
set ruler			" Show cursor position

" Spacing
set ai				" Autoindentation
set expandtab			" Change tabs to spaces on the fly
set shiftwidth=4		" Four spaces per autoindent step
set tabstop=4			" Four spaces per tab

" Misc
set matchpairs=(:),[:],{:},<:>	" What I can bounce on with %
set backspace=indent,eol,start

" color settings
syntax on   " Syntax Hilighting
set t_Co=256
set t_AB=[48;5;%dm
set t_AF=[38;5;%dm

" colorscheme nightwish
" colorscheme desert256
" colorscheme jellybeans
colorscheme railscasts

" Perl syntax checking 'X' in command mode runs perl -c on the current
" script; 'E' afterwards jumps to the line where an error occurred and
" prints the error.
nnoremap <buffer> <silent> X :w<Enter>:!/usr/local/bin/perl -c -MVi::QuickFix %<Enter>
nnoremap <buffer> <silent> E :cf <Enter>

" Move around split windows with <ctrl>-<movement key> (h, j, k, l)
map <c-h> <c-w>h
map <c-j> <c-w>j
map <c-k> <c-w>k
map <c-l> <c-w>l

" Line numbers on, please.
set number

" Only do this part when compiled with support for autocommands.
if has("autocmd") " dnl
 if !exists("autocommands_loaded")
  let autocommands_loaded = 1

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on " dnl

  " Textwidth should be 80 in mail, not 72.
  autocmd FileType mail setlocal textwidth=72 " dnl

  " For some reason, External Editor in T-Bird occasionally loses its
  " mind and starts vim in /usr/local/lib/thunderbird.
  autocmd FileType mail chdir ${HOME}

  " Read a new signature (Mail)
  autocmd FileType mail map <c-k> dG:r ${HOME}/sig<enter>

  " For all text files set 'textwidth' to 80 characters.
  autocmd FileType text setlocal textwidth=80 " dnl

  " For perl files, make things tidy
  autocmd FileType perl setlocal expandtab shiftwidth=4 tabstop=4 textwidth=100 " dnl

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost * " dnl
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
  au BufNewFile,BufRead *.i set filetype=swig
  au BufNewFile,BufRead *.swg set filetype=swig

 endif " !exists("autocommands_loaded")

endif " has("autocmd")
