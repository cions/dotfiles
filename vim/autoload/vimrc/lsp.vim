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
  nmap <buffer> gn <Plug>(lsp-next-diagnostic)
  nmap <buffer> gp <Plug>(lsp-previous-diagnostic)
  nmap <buffer> gF <Plug>(lsp-document-format)
  xmap <buffer> gF <Plug>(lsp-document-format-range)
  nmap <buffer> g! <Plug>(lsp-code-action)
  nmap <buffer> <F2> <Plug>(lsp-rename)

  if s:has_formatting_support()
    autocmd BufWritePre <buffer> LspDocumentFormatSync
  endif
endfunction

function s:has_formatting_support() abort
  for name in lsp#get_server_names()
    if lsp#capabilities#has_document_formatting_provider(name)
      return v:true
    endif
  endfor
  return v:false
endfunction
