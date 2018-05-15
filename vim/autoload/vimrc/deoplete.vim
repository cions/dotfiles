function! vimrc#deoplete#on_source() abort
  let g:deoplete#enable_at_startup = 1

  inoremap <expr> <C-l> deoplete#complete_common_string()
  inoremap <expr> <Tab>
        \ deoplete#complete_common_string() !=# ''
        \   ? deoplete#complete_common_string()
        \   : pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <C-h> deoplete#smart_close_popup() . "\<C-h>"
  inoremap <expr> <BS> deoplete#smart_close_popup() . "\<BS>"
  inoremap <expr> <C-g> deoplete#undo_completion()
  inoremap <expr> <CR> pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
endfunction

function! vimrc#deoplete#on_post_source() abort
  call deoplete#custom#option('num_processes', 8)
  call deoplete#custom#option('sources', {
        \   'python': ['jedi', 'file']
        \ })
endfunction
