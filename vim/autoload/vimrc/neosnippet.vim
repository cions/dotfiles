function! vimrc#neosnippet#on_source() abort
  let g:neosnippet#snippets_directory = g:vimfiles . '/snippets'
  let g:neosnippet#data_directory = g:cachedir . '/neosnippet'
  let g:neosnippet#disable_runtime_snippets = { '_': 1 }

  imap <C-k> <Plug>(neosnippet_expand_or_jump)
  smap <C-k> <Plug>(neosnippet_expand_or_jump)
  xmap <C-k> <Plug>(neosnippet_expand_target)
endfunction
