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

  nmap <buffer> K <Plug>(go-doc)
  nmap <buffer> gT <Plug>(go-test-func)
  nmap <buffer> gb <Plug>(go-build)
  nmap <buffer> gi <Plug>(go-imports)
  nmap <buffer> gt <Plug>(go-test)
  nmap <buffer> sc <Plug>(go-coverage-toggle)
  nmap <buffer> sf <Plug>(go-fillstruct)
  nmap <buffer> sg <Plug>(go-generate)
  nmap <buffer> si <Plug>(go-info)
  nmap <buffer> sk <Plug>(go-keyify)
  nmap <buffer> sn <Plug>(go-rename)
endfunction

function! vimrc#vim_go#on_post_source() abort
  if !isdirectory(g:goenv)
    GoInstallBinaries
  endif
endfunction
