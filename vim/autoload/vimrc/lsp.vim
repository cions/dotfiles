function vimrc#lsp#on_source() abort
  let g:lsp_diagnostics_echo_cursor = 1

  augroup vimrc-lsp
    autocmd!
    autocmd User lsp_buffer_enabled call vimrc#lsp#on_lsp_buffer_enabled()
    autocmd User lsp_float_opened nmap <buffer><silent> <Esc> <Plug>(lsp-preview-close)
    autocmd User lsp_float_closed nunmap <buffer> <Esc>
  augroup END
endfunction

function vimrc#lsp#on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes

  nmap <buffer> gd <Plug>(lsp-definition)
  nmap <buffer> gD <Plug>(lsp-peek-definition)
  nmap <buffer> gt <Plug>(lsp-type-definition)
  nmap <buffer> gT <Plug>(lsp-peek-type-definition)
  nmap <buffer> gR <Plug>(lsp-references)
  nmap <buffer> gi <Plug>(lsp-hover)
  nmap <buffer> gs <Plug>(lsp-document-symbol)
  nmap <buffer> ge <Plug>(lsp-document-diagnostics)
  nmap <buffer> g, <Plug>(lsp-next-diagnostic)
  nmap <buffer> g; <Plug>(lsp-previous-diagnostic)
  nmap <buffer> sf <Plug>(lsp-document-format)
  xmap <buffer> sf <Plug>(lsp-document-range-format)
  nmap <buffer> sx <Plug>(lsp-code-action)
  nmap <buffer> sn <Plug>(lsp-rename)
endfunction
