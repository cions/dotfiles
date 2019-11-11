let s:tabid = 0
function s:set_tabid() abort
  if !has_key(t:, 'defx_tabid')
    let s:tabid += 1
    let t:defx_tabid = s:tabid
  endif
endfunction

function s:on_BufEnter(afile) abort
  if isdirectory(a:afile)
    let curbufnr = bufnr('%')
    call defx#start([a:afile], { 'new': v:true })
    execute 'silent!' printf('%dbwipeout', curbufnr)
  endif
endfunction

function vimrc#defx#on_source() abort
  let g:loaded_netrw = 1
  let g:loaded_netrwPlugin = 1

  augroup vimrc-defx
    autocmd!
    autocmd FileType defx call vimrc#defx#on_defx_buffer()
    autocmd VimEnter,TabNew * call s:set_tabid()
    autocmd BufEnter * call s:on_BufEnter(expand('<afile>:p'))
  augroup END

  nnoremap <silent> <Leader>e :Defx -search=`expand('%:p')`<CR>
  nnoremap <silent> <Leader>E
        \ :Defx -buffer-name=explorer%`t:defx_tabid`
        \ -search=`expand('%:p')`<CR>
endfunction

function vimrc#defx#on_post_source() abort
  call defx#custom#option('_', {
        \   'columns': 'mark:indent:icon:filename',
        \   'direction': 'topleft',
        \   'listed': v:true,
        \   'resume': v:true,
        \   'split': 'vertical',
        \   'toggle': v:true,
        \   'winwidth': 30,
        \ })
  call defx#custom#option('default', {
        \   'columns': 'mark:indent:icon:filename:type:size:time',
        \   'direction': '',
        \   'listed': v:false,
        \   'resume': v:false,
        \   'split': 'no',
        \   'toggle': v:false,
        \   'winwidth': 90,
        \ })

  call defx#custom#column('icon', {
        \   'directory_icon': '+',
        \   'opened_icon': '-',
        \   'root_icon': ' ',
        \ })
  call defx#custom#column('mark', {
        \   'readonly_icon': 'X',
        \   'selected_icon': '*',
        \ })
  call defx#custom#column('time', 'format', '%F %H:%M')
endfunction

function vimrc#defx#on_defx_buffer() abort
  nnoremap <buffer> <Esc>[ <Esc>[
  nmap <buffer> <Left> h
  nmap <buffer> <Right> l

  nnoremap <silent><buffer><expr> <C-g> defx#do_action('print')
  nnoremap <silent><buffer><expr> <C-l> defx#do_action('redraw')
  nnoremap <silent><buffer><expr> <C-c> defx#do_action('quit')
  nnoremap <silent><buffer><expr><nowait> <Esc> defx#do_action('quit')
  nnoremap <silent><buffer><expr> q defx#do_action('quit')

  nnoremap <silent><buffer><expr> <CR> defx#is_directory()
        \ ? defx#do_action('open')
        \ : defx#do_action('call', ['vimrc#defx#smart_open'])
  nnoremap <silent><buffer><expr> <BS> defx#do_action('cd', '..')
  nnoremap <silent><buffer><expr> h vimrc#defx#under_opened_tree()
        \ ? defx#do_action('close_tree')
        \ : defx#do_action('cd', '..')
  nnoremap <silent><buffer><expr> l defx#is_directory()
        \ ? defx#do_action('open_tree')..'j'
        \ : defx#do_action('call', ['vimrc#defx#smart_open'])
  nnoremap <silent><buffer><expr> L defx#do_action('open_tree_recursive')
  nnoremap <silent><buffer><expr> j line('.') == line('$') ? 'gg' : 'j'
  nnoremap <silent><buffer><expr> k line('.') == 1 ? 'G' : 'k'
  nnoremap <silent><buffer><expr> s
        \ defx#do_action('call', ['vimrc#defx#smart_open', 'vsplit'])
  nnoremap <silent><buffer><expr> S
        \ defx#do_action('call', ['vimrc#defx#smart_open', 'split'])
  nnoremap <silent><buffer><expr> v defx#do_action('open', 'pedit')
  nnoremap <silent><buffer><expr> g/ defx#do_action('cd', '/')
  nnoremap <silent><buffer><expr> g. defx#do_action('cd', getcwd())
  nnoremap <silent><buffer><expr> ~ defx#do_action('cd')
  nnoremap <silent><buffer><expr> go defx#do_action('change_vim_cwd')

  nnoremap <silent><buffer><expr><nowait> <Space>
        \ defx#do_action('toggle_select')..'j'
  xnoremap <silent><buffer><expr><nowait> <Space>
        \ defx#do_action('toggle_select_visual')
  nnoremap <silent><buffer><expr> * defx#do_action('toggle_select_all')
  nnoremap <silent><buffer><expr> . defx#do_action('toggle_ignored_files')
  nnoremap <silent><buffer><expr> t defx#do_action('toggle_sort', 'time')
  nnoremap <silent><buffer><expr> <
        \ defx#do_action('resize', defx#get_context().winwidth - 5)
  nnoremap <silent><buffer><expr> >
        \ defx#do_action('resize', defx#get_context().winwidth + 5)

  nnoremap <silent><buffer><expr> N defx#do_action('new_file')
  nnoremap <silent><buffer><expr> D defx#do_action('new_directory')
  nnoremap <silent><buffer><expr> r defx#do_action('rename')
  nnoremap <silent><buffer><expr> c defx#do_action('copy')
  nnoremap <silent><buffer><expr> d defx#do_action('move')
  nnoremap <silent><buffer><expr> p defx#do_action('paste')
  nnoremap <silent><buffer><expr> x defx#do_action('remove')
  nnoremap <silent><buffer><expr> gx defx#do_action('execute_system')
  nnoremap <silent><buffer><expr> y defx#do_action('yank_path')
  nnoremap <silent><buffer><expr> ; defx#do_action('repeat')

  nnoremap <silent><buffer> ? :nmap <buffer><CR>
endfunction

function vimrc#defx#under_opened_tree() abort
  let candidate = defx#get_candidate()
  return get(candidate, 'is_opened_tree', 0) || get(candidate, 'level', 0)
endfunction

function vimrc#defx#smart_open(context) abort
  if a:context.split =~# '^\%(no\|tab\)$' || winnr('$') == 1
    call defx#call_action('open', a:context.args[1:])
    call defx#call_action('quit')
  else
    let command = get(a:context.args, 1, 'edit')
    let winnr = win_id2win(a:context.prev_winid)
    if winnr == 0
      let winnr = winnr('#')
    endif
    call win_gotoid(win_getid(winnr))
    for target in a:context.targets
      if isdirectory(target)
        continue
      endif
      call defx#util#execute_path(command, target)
    endfor
  endif
endfunction
