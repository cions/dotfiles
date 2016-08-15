" filetype.vim

if exists('did_load_filetypes')
  finish
endif

augroup filetypedetect
  au! BufRead,BufNewFile *.ll   setfiletype llvm
augroup END
