" my filetype file
if exists("did_load_filetypes")
  finish
endif
augroup filetypedetect
" http logfile highlighting
 au! BufRead,BufNewFile *access[_.]log* setf httplog
augroup END
