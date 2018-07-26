function! vimrc#quickrun#on_source() abort
  let g:quickrun_no_default_key_mappings = 1
  let g:quickrun_config = {
    \   '_': {
    \     'runner': 'job',
    \     'outputter': 'buffer',
    \   }
    \ }

  nmap <Space>r <Plug>(quickrun)
endfunction
