function! vimrc#vim_go#on_source() abort
  let g:go_def_reuse_buffer = 1
  let g:go_info_mode = 'guru'
  let g:go_list_type = 'quickfix'
  let g:go_metalinter_autosave = 0
  let g:go_snippet_engine = 'neosnippet'
  let g:go_template_autocreate = 0
  let g:go_test_show_name = 1
  let g:go_updatetime = 0
  let g:go_highlight_extra_types = 1
  let g:go_highlight_operators = 1

  au FileType go nmap <buffer> K <Plug>(go-doc)
  au FileType go nmap <buffer> gT <Plug>(go-test-func)
  au FileType go nmap <buffer> gb <Plug>(go-build)
  au FileType go nmap <buffer> gi <Plug>(go-imports)
  au FileType go nmap <buffer> gt <Plug>(go-test)
  au FileType go nmap <buffer> sc <Plug>(go-coverage-toggle)
  au FileType go nmap <buffer> ss <Plug>(go-fillstruct)
  au FileType go nmap <buffer> sg <Plug>(go-generate)
  au FileType go nmap <buffer> si <Plug>(go-info)
  au FileType go nmap <buffer> sk <Plug>(go-keyify)
  au FileType go nmap <buffer> sr <Plug>(go-rename)
endfunction
