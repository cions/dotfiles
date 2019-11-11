scriptversion 3
scriptencoding utf-8

let s:Promise = vital#vimrc#import('Async.Promise')

function s:_onerror(err) abort
  if type(a:err) is# v:t_list
    echohl WarningMsg
    for x in a:err
      echom x
    endfor
    echohl None
  elseif type(a:err) is# v:t_dict && has_key(a:err, 'exception')
    echohl ErrorMsg
    echom a:err.exception
    echohl CursorLineNr
    echom a:err.throwpoint
    echohl None
  else
    echohl WarningMsg
    echom string(a:err)
    echohl None
  endif
  return s:Promise.reject(a:err)
endfunction
let s:onerror = funcref('s:_onerror')

function s:echow(msg) abort
  echohl WarningMsg
  echom a:msg
  echohl None
endfunction

function s:readall(ch, part) abort
  let result = []
  while ch_status(a:ch, {'part': a:part}) =~# 'open\|buffered'
    call add(result, ch_read(a:ch, {'part': a:part}))
  endwhile
  return result
endfunction

function vimrc#exec(command, ...) abort
  let options = a:0 ? copy(a:1) : {}
  return s:Promise.new({resolve, reject -> job_start(a:command, extend(options, {
        \   'drop': 'never',
        \   'stoponexit': '',
        \   'close_cb': {-> v:null},
        \   'exit_cb': {ch, code ->
        \     code ? reject(s:readall(ch, 'err')) : resolve(s:readall(ch, 'out'))
        \   }
        \ }))})
endfunction

function vimrc#await(promise) abort
  return s:Promise.wait(a:promise)
endfunction

function vimrc#setup_dein(deinrepo) abort
  call s:echow('cloning dein repository...')
  let repourl = 'https://github.com/Shougo/dein.vim'
  return vimrc#exec(['git', 'clone', '--depth=1', repourl, a:deinrepo], {})
        \.then({-> s:echow('cloning dein repository... Done')}, s:onerror)
endfunction

function vimrc#setup_pyenv() abort
  call s:echow('Setup python environment...')
  let options = { 'cwd': g:pyenv }
  let p = vimrc#exec(['python3', '-mvenv', '--system-site-packages', g:pyenv], options)
  let options.env = { 'PATH': g:pyenv .. '/bin:' .. $PATH, 'VIRTUAL_ENV': g:pyenv }
  let p = p.then({-> vimrc#exec(['pip', 'install', '-U', 'pip'], options)})
  if filereadable(g:pyenv .. '/requirements.txt')
    let p = p.then({-> vimrc#exec(['pip', 'install', '-r', g:pyenv .. '/requirements.txt'], options)})
  else
    let p = p.then({-> vimrc#exec(['pip', 'install', 'pynvim'], options)})
  endif
  return p.then({-> s:echow('Setup python environment... Done')}, s:onerror)
endfunction

function vimrc#setup_ndenv() abort
  if !filereadable(g:ndenv .. '/package.json')
    return s:Promise.reject('No package.json')
  endif
  call s:echow('Setup node environment...')
  return vimrc#exec(['npm', 'install'], { 'cwd': g:ndenv })
        \.then({-> s:echow('Setup node environment... Done')}, s:onerror)
endfunction

function vimrc#setup_goenv() abort
  if !filereadable(g:goenv .. '/tools.txt')
    return s:Promise.reject('No tools.txt')
  endif
  call s:echow('Setup go environment...')
  let pkgs = filter(readfile(g:goenv .. '/tools.txt'), {_,x -> x !~# '^#\|^\s*$'})
  let options = {
        \   'cwd': g:goenv,
        \   'env': { 'GOBIN': g:goenv .. '/bin' }
        \ }
  if filereadable(g:goenv .. '/go.mod')
    let p = s:Promise.resolve()
  else
    let p = vimrc#exec(['go', 'mod', 'init', 'vim-goenv'], options)
  endif
  return p.then({-> vimrc#exec(['go', 'get'] + pkgs, options)})
        \.then({-> s:echow('Setup go environment... Done')}, s:onerror)
endfunction

function vimrc#update() abort
  call dein#update()

  if exists('g:pyenv')
    let options = {
          \   'cwd': g:pyenv,
          \   'env': { 'PATH': g:pyenv .. '/bin:' .. $PATH, 'VIRTUAL_ENV': g:pyenv },
          \ }
    let p = vimrc#exec(['pip', 'list', '--local', '--format=json'], options)
          \.then({out -> map(json_decode(join(out, "\n")), {_,x -> x.name})})
          \.then({pkgs -> vimrc#exec(['pip', 'install', '-U'] + pkgs, options)})
          \.then({-> vimrc#exec(['pip', 'freeze', '--local'], options)})
          \.then({out -> writefile(out, g:pyenv .. '/requirements.txt')})
          \.then({-> s:echow('python environment updated')}, s:onerror)
  endif

  if exists('g:ndenv')
    let p = vimrc#exec(['npm', 'update'], { 'cwd': g:ndenv })
          \.then({-> s:echow('node environment updated')}, s:onerror)
  endif

  if exists('g:goenv')
    let pkgs = filter(readfile(g:goenv .. '/tools.txt'), {_,x -> x !~# '^#\|^\s*$'})
    let options = {
          \   'cwd': g:goenv,
          \   'env': { 'GOBIN': g:goenv .. '/bin' },
          \ }
    let p = vimrc#exec(['go', 'get', '-u'] + pkgs, options)
          \.then({-> s:echow('go environment updated')}, s:onerror)
  endif
endfunction

function vimrc#clean() abort
  for plugin in dein#check_clean()
    call delete(plugin, 'rf')
    call delete(fnamemodify(plugin, ':h'), 'd')
  endfor
  call dein#each('git gc')
  call dein#recache_runtimepath()
endfunction

function vimrc#synstack() abort
  let stack = synstack(line('.'), col('.'))
  let names = map(stack, {_,x -> synIDattr(x, 'name')})
  echomsg join(names, ' / ')
endfunction

function vimrc#highlight() abort
  let synid = synIDtrans(synID(line('.'), col('.'), 1))
  echomsg synIDattr(synid, 'name')
endfunction

function vimrc#lcd_to_project_dir(file) abort
  if &buftype !=# '' | return | endif
  if a:file ==# '' | return | endif
  if isdirectory(a:file) | return | endif
  if a:file =~# '^gina://' | return | endif
  let file = substitute(a:file, '^sudo:', '', '')
  let filedir = fnamemodify(file, ':h')
  let targetdir = escape(filedir, '*[]?{};, ')

  let anchordirs = ['.git', '.hg', '.bzr', '.svn']
  for x in anchordirs
    let newdir = finddir(x, targetdir..';')
    if newdir !=# ''
      execute 'lcd' fnameescape(fnamemodify(newdir, ':p:h:h'))
      return
    endif
  endfor

  let anchorfiles = [
        \   'Pipfile',
        \   'pyproject.toml',
        \   'pyvenv.cfg',
        \   'setup.py',
        \   'package.json',
        \   'go.mod',
        \   'Gemfile',
        \   'Rakefile',
        \   'CMakeLists.txt',
        \   'meson.build',
        \   'configure.ac',
        \   'configure',
        \   'Makefile.am',
        \   'Makefile',
        \   'build.gradle',
        \   'pom.xml',
        \ ]
  for x in anchorfiles
    let newdir = findfile(x, targetdir..';')
    if newdir !=# ''
      execute 'lcd' fnameescape(fnamemodify(newdir, ':p:h'))
      return
    endif
  endfor
endfunction

function vimrc#auto_mkdir(dir, force) abort
  if isdirectory(a:dir)
    return
  endif
  let prompt = '"%s" does not exists. Create? [y/N] '
  if a:force || input(prompt, a:dir) =~? '^y\%[es]$'
    call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
  endif
endfunction
