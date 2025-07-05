scriptversion 4

function vimrc#vsnip#setup() abort
  imap <expr> <Tab>
        \ vsnip#expandable() ? '<Plug>(vsnip-expand)'    :
        \ vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<Tab>'
  smap <expr> <Tab>
        \ vsnip#expandable() ? '<Plug>(vsnip-expand)'    :
        \ vsnip#jumpable(1)  ? '<Plug>(vsnip-jump-next)' : '<Tab>'
  imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
  smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'

  let g:vsnip_snippet_dir = g:vimfiles .. '/snippets'
  let g:vsnip_filetypes = {
        \   'cpp': ['cpp', 'c'],
        \   'plaintex': ['plaintex', 'tex'],
        \ }
endfunction
