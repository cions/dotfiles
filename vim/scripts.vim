" scripts.vim

if did_filetype()
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

let s:line1 = getline(1)

if s:line1 =~# '\M-*- C++ -*-'
  setf cpp
endif

let &cpo = s:cpo_save
unlet s:cpo_save s:line1
