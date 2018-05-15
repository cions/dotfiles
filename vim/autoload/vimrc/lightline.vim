function! vimrc#lightline#on_source()
  let g:lightline = {
        \   'colorscheme': 'powerprompt',
        \   'separator': { 'left': "\uE0B0", 'right': "\uE0B2" },
        \   'subseparator': { 'left': "\uE0B1", 'right': "\uE0B3" },
        \   'active': {
        \     'left': [ [ 'mode', 'paste', 'gitbranch' ],
        \               [ 'readonly', 'filename', 'modified' ] ],
        \     'right': [ [ 'lineinfo' ],
        \                [ 'fileformat', 'fileencoding', 'filetype' ] ]
        \   },
        \   'inactive': {
        \     'left': [ [ 'filename' ] ],
        \     'right': [ [ 'lineinfo' ] ]
        \   },
        \   'component_function': {
        \     'fileencoding': 'vimrc#lightline#fileencoding',
        \     'fileformat': 'vimrc#lightline#fileformat',
        \     'filename': 'vimrc#lightline#filename',
        \     'filetype': 'vimrc#lightline#filetype',
        \     'gitbranch': 'vimrc#lightline#gitbranch',
        \     'modified': 'vimrc#lightline#modified',
        \     'readonly': 'vimrc#lightline#readonly'
        \   }
        \ }
endfunction

function! s:is_special_buffer() abort
  return &buftype ==# 'help' || &buftype ==# 'terminal' || &buftype == 'nofile'
endfunction

function! vimrc#lightline#fileencoding() abort
  if s:is_special_buffer()
    return ''
  else
    return &fenc !=# '' && &fenc !=# 'utf-8' ? &fenc : ''
  endif
endfunction

function! vimrc#lightline#fileformat() abort
  if s:is_special_buffer()
    return ''
  else
    return &ff !=# 'unix' ? &ff : ''
  endif
endfunction

function! vimrc#lightline#filename() abort
  if &buftype ==# 'terminal'
    let cmd = substitute(expand('%'), '^!', '', '')
    return fnamemodify(cmd, ':t')
  elseif &ft ==# 'vimfiler'
    return vimfiler#get_status_string()
  elseif &ft ==# 'unite'
    return unite#get_status_string()
  else
    return expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  endif
endfunction

function! vimrc#lightline#filetype() abort
  if &buftype ==# 'help' || &buftype ==# 'terminal'
    return &buftype
  else
    return &ft !=# '' ? &ft : 'no ft'
  endif
endfunction

function! vimrc#lightline#gitbranch() abort
  return !s:is_special_buffer() ? gina#component#repo#branch() : ''
endfunction

function! vimrc#lightline#modified() abort
  if s:is_special_buffer()
    return ''
  else
    return &modified ? '+' : &modifiable ? '' : '-'
  endif
endfunction

function! vimrc#lightline#readonly() abort
  return &readonly && !s:is_special_buffer() ? 'RO' : ''
endfunction
