scriptversion 4

function vimrc#fall#setup() abort
  nnoremap <silent> \g :<C-U>Fall repository<CR>
  nnoremap <silent> \f :<C-U>Fall file<CR>

  augroup vimrc-fall
    autocmd!
    autocmd User FallPickerEnter:* call vimrc#fall#setup_fall()
  augroup END
endfunction

function vimrc#fall#setup_fall() abort
  cnoremap <nowait> <Up> <Plug>(fall-list-prev)
  cnoremap <nowait> <Down> <Plug>(fall-list-next)

  cnoremap <nowait> <C-X> <Cmd>call fall#action('open:split')<CR>
  cnoremap <nowait> <C-V> <Cmd>call fall#action('open:vsplit')<CR>
endfunction
