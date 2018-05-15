" filetype.vim

if exists('did_load_filetypes')
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

augroup filetypedetect
  au! BufNewFile,BufRead *.wls setf mma
augroup END

let &cpo = s:cpo_save
unlet s:cpo_save
