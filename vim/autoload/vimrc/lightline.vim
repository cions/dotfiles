scriptversion 4

function vimrc#lightline#setup() abort
  nnoremap <silent> <C-L> <C-L>:<C-U>call lightline#update()<CR>

  let g:lightline = #{
        \   colorscheme: 'nordfox',
        \   separator: #{ left: "", right: "" },
        \   subseparator: #{ left: "\u2502", right: "\u2502" },
        \   active: #{
        \     left: [
        \       ['mode', 'paste'],
        \       ['readonly', 'filename', 'modified'],
        \     ],
        \     right: [
        \       ['lineinfo'],
        \       ['percent'],
        \       ['indentstyle', 'fileformat', 'fileencoding', 'filetype'],
        \     ],
        \   },
        \   inactive: #{
        \     left: [['filename']],
        \     right: [['lineinfo']],
        \   },
        \   component_function: #{
        \     fileencoding: 'vimrc#lightline#fileencoding',
        \     fileformat: 'vimrc#lightline#fileformat',
        \     filename: 'vimrc#lightline#filename',
        \     filetype: 'vimrc#lightline#filetype',
        \     modified: 'vimrc#lightline#modified',
        \     readonly: 'vimrc#lightline#readonly',
        \     indentstyle: 'vimrc#lightline#indentstyle',
        \   }
        \ }
endfunction

function s:is_special_buffer() abort
  return &l:buftype ==# 'help' || &l:buftype ==# 'terminal' || &l:buftype ==# 'nofile'
endfunction

function vimrc#lightline#fileencoding() abort
  return &l:fileencoding ==# 'utf-8' || s:is_special_buffer() ? '' : &l:fileencoding
endfunction

function vimrc#lightline#fileformat() abort
  return &l:fileformat ==# 'unix' || s:is_special_buffer() ? '' : &l:fileformat
endfunction

function vimrc#lightline#filename() abort
  if &l:buftype ==# 'terminal'
    let cmd = substitute(expand('%'), '^!', '', '')
    return fnamemodify(cmd, ':t')
  else
    return expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  endif
endfunction

function vimrc#lightline#filetype() abort
  if &l:buftype ==# 'help' || &l:buftype ==# 'terminal'
    return &l:buftype
  else
    return &l:filetype !=# '' ? &l:filetype : 'no ft'
  endif
endfunction

function vimrc#lightline#modified() abort
  if s:is_special_buffer()
    return ''
  elseif &l:modified
    return '+'
  elseif &l:modifiable
    return ''
  else
    return '-'
  endif
endfunction

function vimrc#lightline#readonly() abort
  return &l:readonly && !s:is_special_buffer() ? 'RO' : ''
endfunction

function vimrc#lightline#indentstyle() abort
  return (&l:expandtab ? 'space' : 'tab') .. &l:shiftwidth
endfunction
