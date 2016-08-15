" scripts.vim

if did_filetype()
  finish
endif

let s:firstline = getline(1)

if s:firstline =~# '\M-*- C++ -*-'
  setfiletype cpp
endif
