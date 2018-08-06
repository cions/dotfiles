function! vimrc#deoplete#on_source() abort
  let g:deoplete#enable_at_startup = 1

  inoremap <expr> <Tab> vimrc#deoplete#tab()
  inoremap <expr> <C-g> deoplete#undo_completion()
endfunction

function! vimrc#deoplete#on_post_source() abort
  if executable('nproc')
    call deoplete#custom#option('num_processes', str2nr(system('nproc')))
  endif
  call deoplete#custom#option('auto_complete_delay', 10)
  call deoplete#custom#option('ignore_sources', {
        \   '_': ['around', 'buffer', 'dictionary', 'member', 'tag']
        \ })
endfunction

function! vimrc#deoplete#tab() abort
  let common_string = deoplete#complete_common_string()
  return common_string !=# '' ? common_string :
        \ pumvisible() ? "\<C-n>" :
        \ line('.') =~# '\S\%#' ? deoplete#manual_complete() :
        \ "\<TAB>"
endfunction
