"
" Note: Apparently, there can be no blank lines and each line
" should end in a comment.  This is to prevent carping about
" invalid characters and options (can't seem to lose the ^M's).
" I'm using "dnl"s just to indicate when it's effectively a noop
" at the end of a command.
"
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
" Format this paragraph to 80 columns
map <c-x> {!}fmt -w 80
syntax on			" Syntax Hilighting
set t_Co=256
set t_AB=[48;5;%dm
set t_AF=[38;5;%dm
" colo nightwish
colo desert256
" Perl syntax checking 'X' in command mode runs perl -c on the current
" script; 'E' afterwards jumps to the line where an error occurred and
" prints the error.
nnoremap <buffer> <silent> X :w<Enter>:!/usr/local/bin/perl -c -MVi::QuickFix %<Enter>
nnoremap <buffer> <silent> E :cf <Enter>
"
" Only do this part when compiled with support for autocommands.
if has("autocmd") " dnl
 if !exists("autocommands_loaded")
  let autocommands_loaded = 1
  "
  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on " dnl
  "
  " Textwidth should be 80 in mail, not 72.
  autocmd FileType mail setlocal textwidth=72 " dnl
  " For some reason, External Editor in T-Bird occasionally loses its
  " mind and starts vim in /usr/local/lib/thunderbird.
  autocmd FileType mail chdir ${HOME}
  " Read a new signature (Mail)
  autocmd FileType mail map <c-k> dG:r ${HOME}/sig<enter>
  "
  " All mail settings should go here...
  autocmd FileType mail source ${HOME}/.vim.mail
  "
  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=80 " dnl
  "
  " For perl files, make things tidy
  autocmd FileType perl setlocal expandtab shiftwidth=4 tabstop=4 textwidth=100 " dnl
  "
  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost * " dnl
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif
  au BufNewFile,BufRead *.i set filetype=swig
  au BufNewFile,BufRead *.swg set filetype=swig 
 "
 endif " !exists("autocommands_loaded")
"
endif " has("autocmd")
