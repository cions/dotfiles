scriptversion 4

function vimrc#fern#setup() abort
  nnoremap <silent> \e :<C-U>Fern . -drawer -toggle<CR>

  let g:fern#default_hidden = 1

  augroup vimrc-fern
    autocmd!
    autocmd FileType fern call vimrc#fern#setup_fern()
  augroup END
endfunction

function vimrc#fern#setup_fern() abort
  nmap <buffer> <Plug>(fern-action-open) <Plug>(fern-action-open:drop)

  nmap <buffer><expr>
        \ <Plug>(fern-action-collapse-or-up)
        \ fern#smart#leaf(
        \   '<Plug>(fern-action-focus:parent)<Plug>(fern-action-collapse)',
        \   '<Plug>(fern-action-focus:parent)<Plug>(fern-action-collapse)',
        \   '<Plug>(fern-action-collapse)',
        \ )

  nmap <buffer> <C-L> <Plug>(fern-action-reload:all)<Plug>(fern-action-redraw)
  nmap <buffer><expr> h
        \ fern#smart#root(
        \   '<Plug>(fern-action-leave)',
        \   '<Plug>(fern-action-collapse-or-up)'
        \ )
  nmap <buffer> * <Plug>(fern-action-mark:toggle)
  nmap <buffer> . <Plug>(fern-action-hidden:toggle)
  nmap <buffer> g. <Plug>(fern-action-repeat)
  nmap <buffer> > <Plug>(fern-action-expand-tree:stay)

  nmap <buffer> e <Plug>(fern-action-open:select)
  nmap <buffer> s <Plug>(fern-action-open:split)
  nmap <buffer> S <Plug>(fern-action-open:vsplit)
  nmap <buffer> t <Plug>(fern-action-open:tabedit)

  nmap <buffer> N <Plug>(fern-action-new-file)
  nmap <buffer> K <Plug>(fern-action-new-dir)
  nmap <buffer> C <Plug>(fern-action-copy)
  nmap <buffer> M <Plug>(fern-action-move)
  nmap <buffer> R <Plug>(fern-action-rename:split)
  nmap <buffer> D <Plug>(fern-action-remove)
  nmap <buffer> gx <Plug>(fern-action-open:system)

  nmap <buffer> c <Plug>(fern-action-clipboard-copy)
  nmap <buffer> x <Plug>(fern-action-clipboard-move)
  nmap <buffer> v <Plug>(fern-action-clipboard-paste)
endfunction
