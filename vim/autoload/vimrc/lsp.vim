scriptversion 4

function vimrc#lsp#setup() abort
  let g:lsp_diagnostics_float_cursor = 1
  let g:lsp_diagnostics_highlights_insert_mode_enabled = 0
  let g:lsp_diagnostics_virtual_text_enabled = 0
  let g:lsp_diagnostics_virtual_text_prefix = '> '
  let g:lsp_float_max_width = 0
  let g:lsp_fold_enabled = 0
  let g:lsp_hover_conceal = 0
  let g:lsp_semantic_enabled = 1
  let g:lsp_preview_doubletap = 0

  let g:lsp_settings_filetype_typescript = ['typescript-language-server', 'deno']

  augroup vimrc-lsp
    autocmd!
    autocmd User lsp_buffer_enabled call vimrc#lsp#lsp_buffer_enabled()
    autocmd User lsp_float_opened call vimrc#lsp#lsp_float_opened()
    autocmd User lsp_float_closed call vimrc#lsp#lsp_float_closed()
  augroup END
endfunction

function vimrc#lsp#lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  setlocal signcolumn=yes

  nmap <buffer> gd <Plug>(lsp-definition)
  nmap <buffer> gD <Plug>(lsp-peek-definition)
  nmap <buffer> gt <Plug>(lsp-type-definition)
  nmap <buffer> gT <Plug>(lsp-peek-type-definition)
  nmap <buffer> g, <Plug>(lsp-next-diagnostic)
  nmap <buffer> g; <Plug>(lsp-previous-diagnostic)
  nmap <buffer> si <Plug>(lsp-hover)
  nmap <buffer> s% <Plug>(lsp-references)
  nmap <buffer> s! <Plug>(lsp-document-diagnostics)
  nmap <buffer> s$ <Plug>(lsp-document-symbol)
  nmap <buffer> sf <Plug>(lsp-document-format)
  xmap <buffer> sf <Plug>(lsp-document-range-format)
  nmap <buffer> sx <Plug>(lsp-code-action)
  nmap <buffer> sn <Plug>(lsp-rename)
endfunction

function vimrc#lsp#lsp_float_opened() abort
  call popup_setoptions(lsp#document_hover_preview_winid(), #{
        \   borderchars: ['-', '|', '-', '|', '+', '+', '+', '+'],
        \   close: 'button',
        \   drag: 1,
        \   padding: [0, 1, 1, 1],
        \   resize: 1,
        \ })
  nmap <buffer> <C-C> <Plug>(lsp-preview-close)
  nmap <buffer> <Esc> <Plug>(lsp-preview-close)
  nmap <buffer><expr> <C-F> lsp#scroll(+4)
  nmap <buffer><expr> <C-B> lsp#scroll(-4)
endfunction

function vimrc#lsp#lsp_float_closed() abort
  nunmap <buffer> <C-C>
  nunmap <buffer> <Esc>
  nunmap <buffer> <C-F>
  nunmap <buffer> <C-B>
endfunction
