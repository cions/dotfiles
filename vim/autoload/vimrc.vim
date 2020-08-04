scriptversion 3
scriptencoding utf-8

let s:Promise = vital#vimrc#import('Async.Promise')

let s:pathsep = has('win32') ? ';' : ':'

function s:addpath(path) abort
  let $PATH = join(insert(split($PATH, s:pathsep), a:path), s:pathsep)
endfunction

function s:removepath(path) abort
  return join(filter(split($PATH, s:pathsep), {_,x -> x !=# a:path}), s:pathsep)
endfunction

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
let s:onerror = function('s:_onerror')

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
  call s:echow('Downloading dein...')
  let repourl = 'https://github.com/Shougo/dein.vim'
  return vimrc#exec(['git', 'clone', '--depth=1', repourl, a:deinrepo], {})
        \.then({-> s:echow('Downloading dein... Done')}, s:onerror)
endfunction

function vimrc#setup_goenv(goenv) abort
  if !executable('go')
    return s:Promise.reject('go not found')
  endif
  if !filereadable(a:goenv .. '/tools.txt')
    return s:Promise.reject('tools.txt not found')
  endif
  let g:goenv = a:goenv
  call s:addpath(g:goenv .. '/bin')
  if isdirectory(g:goenv .. '/bin')
    return s:Promise.resolve()
  endif

  call s:echow('Setup go environment...')
  let pkgs = readfile(g:goenv .. '/tools.txt')
  let opts = { 'cwd': g:goenv, 'env': { 'GOBIN': g:goenv .. '/bin' } }
  return vimrc#exec(['go', 'get'] + pkgs, opts)
        \.then({-> s:echow('Setup go environment... Done')}, s:onerror)
        \.catch({-> rmdir(g:goenv .. '/bin', 'r')})
endfunction

function vimrc#setup_ndenv(ndenv) abort
  if !executable('npm')
    return s:Promise.reject('npm not found')
  endif
  if !filereadable(a:ndenv .. '/package-lock.json')
    return s:Promise.reject('package-lock.json not found')
  endif
  let g:ndenv = a:ndenv
  call s:addpath(g:ndenv .. '/node_modules/.bin')
  if isdirectory(g:ndenv .. '/node_modules/.bin')
    return s:Promise.resolve()
  endif

  call s:echow('Setup node environment...')
  return vimrc#exec(['npm', 'ci'], { 'cwd': g:ndenv })
        \.then({-> s:echow('Setup node environment... Done')}, s:onerror)
        \.catch({-> rmdir(g:ndenv .. '/node_modules/.bin', 'r')})
endfunction

function vimrc#setup_pyenv(pyenv) abort
  if !executable('python3')
    return s:Promise.reject('python3 not found')
  endif
  let g:pyenv = a:pyenv
  call s:addpath(g:pyenv .. '/bin')
  if isdirectory(g:pyenv .. '/bin')
    return s:Promise.resolve()
  endif

  call s:echow('Setup python environment...')
  let p = vimrc#exec(['python3', '-mvenv', '--system-site-packages', g:pyenv], {})
  let opts = { 'cwd': g:pyenv, 'env': { 'VIRTUAL_ENV': g:pyenv } }
  let p = p.then({-> vimrc#exec(['pip', 'install', '-U', 'pip'], opts)})
  if filereadable(g:pyenv .. '/requirements.txt')
    let p = p.then({-> vimrc#exec(['pip', 'install', '-r', g:pyenv .. '/requirements.txt'], opts)})
  else
    let p = p.then({-> vimrc#exec(['pip', 'install', 'pynvim'], opts)})
  endif
  return p.then({-> s:echow('Setup python environment... Done')}, s:onerror)
endfunction

function vimrc#setup_rbenv(rbenv) abort
  if !executable('bundle')
    return s:Promise.reject('bundle not found')
  endif
  if !filereadable(a:rbenv .. '/Gemfile.lock')
    return s:Promise.reject('Gemfile.lock not found')
  endif
  let g:rbenv = a:rbenv
  call s:addpath(g:rbenv .. '/bin')
  if isdirectory(g:rbenv .. '/bin')
    return s:Promise.resolve()
  endif

  call s:echow('Setup ruby environment...')
  let opts = {
        \   'cwd': g:rbenv,
        \   'env': {
        \     'BUNDLE_DEPLOYMENT': 'true',
        \     'BUNDLE_PATH': 'vendor/bundle',
        \     'BUNDLE_BIN': 'bin',
        \   }
        \ }
  return vimrc#exec(['bundle', 'install'], opts)
        \.then({-> s:echow('Setup ruby environment... Done')}, s:onerror)
        \.catch({-> rmdir(g:rbenv .. '/bin', 'r')})
endfunction

function vimrc#setup_rsenv(rsenv) abort
  if !executable('cargo')
    return s:Promise.reject('cargo not found')
  endif
  if !filereadable(a:rsenv .. '/tools.txt')
    return s:Promise.reject('tools.txt not found')
  endif
  let g:rsenv = a:rsenv
  call s:addpath(g:rsenv .. '/bin')
  if isdirectory(g:rsenv .. '/bin')
    return s:Promise.resolve()
  endif

  call s:echow('Setup rust environment...')
  let pkgs = readfile(g:rsenv .. '/tools.txt')
  let opts = { 'cwd': g:rsenv, 'env': { 'CARGO_HOME': g:cachedir .. '/rust', 'CARGO_INSTALL_ROOT': g:rsenv } }
  return vimrc#exec(['cargo', 'install', '--force'] + pkgs, opts)
        \.then({-> s:echow('Setup rust environment... Done')}, s:onerror)
        \.catch({-> rmdir(g:rsenv .. '/bin', 'r')})
endfunction

function vimrc#update(thawed) abort
  call dein#update()

  if exists('g:goenv')
    let pkgs = readfile(g:goenv .. '/tools.txt')
    let opts = { 'cwd': g:goenv, 'env': { 'GOBIN': g:goenv .. '/bin' } }
    call vimrc#exec(['go', 'get', '-u'] + pkgs, opts)
        \.then({-> s:echow('go environment updated')}, s:onerror)
  endif

  if exists('g:ndenv')
    let opts = { 'cwd': g:ndenv }
    if a:thawed && executable('npx')
      let p = vimrc#exec(['npx', 'npm-check-updates', '-u'], opts)
             \.then({-> vimrc#exec(['npm', 'install', opts])})
    else
      if a:thawed
        call s:echow('npx not found')
      endif
      let p = vimrc#exec(['npm', 'ci'], opts)
    endif
    call p.then({-> s:echow('node environment updated')}, s:onerror)
  endif

  if exists('g:pyenv')
    let opts = { 'cwd': g:pyenv, 'env': { 'VIRTUAL_ENV': g:pyenv } }
    if a:thawed && filereadable(g:pyenv .. '/requirements.txt')
      let p = vimrc#exec(['pip', 'list', '--local', '--not-required', '--format=json'], opts)
             \.then({out -> map(json_decode(join(out, "\n")), {_,x -> x.name})})
             \.then({pkgs -> vimrc#exec(['pip', 'install', '-U'] + pkgs, opts)})
             \.then({-> vimrc#exec(['pip', 'freeze', '--local'], opts)})
             \.then({out -> writefile(out, g:pyenv .. '/requirements.txt')})
    elseif filereadable(g:pyenv .. '/requirements.txt')
      let p = vimrc#exec(['pip', 'install', '-U', 'pip'])
             \.then({-> vimrc#exec(['pip', 'install', '-r', g:pyenv .. '/requirements.txt'])})
    else
      let p = vimrc#exec(['pip', 'install', '-U', 'pip', 'pynvim'])
    endif
    call p.then({-> s:echow('python environment updated')}, s:onerror)
  endif

  if exists('g:rbenv')
    let opts = {
          \   'cwd': g:rbenv,
          \   'env': {
          \     'BUNDLE_PATH': 'vendor/bundle',
          \     'BUNDLE_BIN': 'bin',
          \     'PATH': s:removepath(g:rbenv .. '/bin'),
          \   }
          \ }
    if a:thawed
      let p = vimrc#exec(['bundle', 'config', '--delete', 'frozen'], opts)
             \.then({-> vimrc#exec(['bundle', 'config', '--delete', 'deployment'], opts)})
             \.then({-> vimrc#exec(['bundle', 'update', '--all'], opts)})
    else
      let opts['env']['BUNDLE_DEPLOYMENT'] = 'true'
      let p = vimrc#exec(['bundle', 'install'], opts)
    endif
    call p.then({-> s:echow('ruby environment updated')}, s:onerror)
  endif

  if exists('g:rsenv')
    let pkgs = readfile(g:rsenv .. '/tools.txt')
    let opts = { 'cwd': g:rsenv, 'env': { 'CARGO_HOME': g:cachedir .. '/rust', 'CARGO_INSTALL_ROOT': g:rsenv } }
    call vimrc#exec(['cargo', 'install', '--force'] + pkgs, opts)
        \.then({-> s:echow('rust environment updated')}, s:onerror)
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
        \   'pyproject.toml',
        \   'pyvenv.cfg',
        \   'setup.py',
        \   'setup.cfg',
        \   'Pipfile',
        \   'package.json',
        \   'go.mod',
        \   'Gemfile',
        \   'Rakefile',
        \   'Cargo.toml',
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
