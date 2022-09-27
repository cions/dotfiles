scriptversion 4

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
      echomsg x
    endfor
    echohl None
  elseif type(a:err) is# v:t_dict && has_key(a:err, 'exception')
    echohl ErrorMsg
    echomsg a:err.exception
    echohl CursorLineNr
    echomsg a:err.throwpoint
    echohl None
  else
    echohl WarningMsg
    echomsg string(a:err)
    echohl None
  endif
  return s:Promise.reject(a:err)
endfunction
let s:onerror = function('s:_onerror')

function s:echow(msg) abort
  echohl WarningMsg
  echomsg a:msg
  echohl None
endfunction

function s:readall(ch, part) abort
  let result = []
  while ch_status(a:ch, { 'part': a:part }) =~# 'open\|buffered'
    call add(result, ch_read(a:ch, { 'part': a:part }))
  endwhile
  return result
endfunction

function vimrc#exec(command, ...) abort
  let options = a:0 ? copy(a:1) : {}
  return s:Promise.new({resolve, reject -> job_start(a:command, extend(options, {
        \   'drop': 'never',
        \   'stoponexit': '',
        \   'in_io': 'null',
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

function vimrc#setup_goenv() abort
  if !executable('go')
    return s:Promise.reject('go not found')
  endif
  let g:goenv = g:vimfiles .. '/.goenv'
  let gobin = g:goenv .. '/bin'
  let gotools = g:goenv .. '/tools.txt'
  if !filereadable(gotools)
    unlet g:goenv
    return s:Promise.reject('tools.txt not found')
  endif
  call s:addpath(gobin)
  if isdirectory(gobin)
    return s:Promise.resolve()
  endif

  call s:echow('Setup go environment...')
  let pkgs = readfile(gotools)
  let opts = { 'cwd': g:goenv, 'env': { 'GOBIN': gobin } }
  return s:Promise.all(map(pkgs, {_,pkg -> vimrc#exec(['go', 'install', pkg], opts)}))
        \.then({-> s:echow('Setup go environment... Done')}, s:onerror)
        \.catch({-> rmdir(gobin, 'r')})
endfunction

function vimrc#setup_ndenv() abort
  if !executable('npm')
    return s:Promise.reject('npm not found')
  endif
  let g:ndenv = g:vimfiles .. '/.ndenv'
  let ndbin = g:ndenv .. '/node_modules/.bin'
  if !filereadable(g:ndenv .. '/package-lock.json')
    unlet g:ndenv
    return s:Promise.reject('package-lock.json not found')
  endif
  call s:addpath(ndbin)
  if isdirectory(ndbin)
    return s:Promise.resolve()
  endif

  call s:echow('Setup node environment...')
  return vimrc#exec(['npm', 'ci'], { 'cwd': g:ndenv })
        \.then({-> s:echow('Setup node environment... Done')}, s:onerror)
        \.catch({-> rmdir(ndbin, 'r')})
endfunction

function vimrc#setup_pyenv() abort
  if !executable('python')
    return s:Promise.reject('python not found')
  endif
  let g:pyenv = g:vimfiles .. '/.pyenv'
  let pybin = g:pyenv .. '/bin'
  call s:addpath(pybin)
  if isdirectory(pybin)
    return s:Promise.resolve()
  endif

  call s:echow('Setup python environment...')
  let p = vimrc#exec(['python', '-mvenv', '--system-site-packages', g:pyenv], {})
  let opts = { 'cwd': g:pyenv, 'env': { 'VIRTUAL_ENV': g:pyenv } }
  let p = p.then({-> vimrc#exec(['pip', 'install', '-U', 'pip'], opts)})
  if filereadable(g:pyenv .. '/requirements.txt')
    let p = p.then({-> vimrc#exec(['pip', 'install', '-r', g:pyenv .. '/requirements.txt'], opts)})
  else
    let p = p.then({-> vimrc#exec(['pip', 'install', 'pynvim'], opts)})
  endif
  return p.then({-> s:echow('Setup python environment... Done')}, s:onerror)
        \.catch({-> rmdir(pybin, 'r')})
endfunction

function vimrc#setup_rbenv() abort
  if !executable('bundle')
    return s:Promise.reject('bundle not found')
  endif
  let g:rbenv = g:vimfiles .. '/.rbenv'
  let rbbin = g:rbenv .. '/bin'
  if !filereadable(g:rbenv .. '/Gemfile.lock')
    unlet g:rbenv
    return s:Promise.reject('Gemfile.lock not found')
  endif
  call s:addpath(rbbin)
  if isdirectory(rbbin)
    return s:Promise.resolve()
  endif

  call s:echow('Setup ruby environment...')
  let opts = { 'cwd': g:rbenv }
  return vimrc#exec(['bundle', 'config', 'set', '--local', 'deployment', 'true'], opts)
        \.then({-> vimrc#exec(['bundle', 'config', 'set', '--local', 'path', 'vendor/bundle'], opts)})
        \.then({-> vimrc#exec(['bundle', 'config', 'set', '--local', 'bin', 'bin'], opts)})
        \.then({-> vimrc#exec(['bundle', 'install'], opts)})
        \.then({-> s:echow('Setup ruby environment... Done')}, s:onerror)
        \.catch({-> rmdir(rbbin, 'r')})
endfunction

function vimrc#setup_rsenv() abort
  if !executable('cargo')
    return s:Promise.reject('cargo not found')
  endif
  let g:rsenv = g:vimfiles .. '/.rsenv'
  let rsbin = g:rsenv .. '/bin'
  if !filereadable(g:rsenv .. '/tools.txt')
    unlet g:rsenv
    return s:Promise.reject('tools.txt not found')
  endif
  call s:addpath(rsbin)
  if isdirectory(rsbin)
    return s:Promise.resolve()
  endif

  call s:echow('Setup rust environment...')
  let pkgs = readfile(g:rsenv .. '/tools.txt')
  let opts = { 'cwd': g:rsenv, 'env': { 'CARGO_HOME': g:cachedir .. '/rust', 'CARGO_INSTALL_ROOT': g:rsenv } }
  return vimrc#exec(['cargo', 'install', '--force'] + pkgs, opts)
        \.then({-> s:echow('Setup rust environment... Done')}, s:onerror)
        \.catch({-> rmdir(rsbin, 'r')})
endfunction

function vimrc#update(thawed, ...) abort
  let targets = a:000
  if len(targets) == 0
    let targets = ['dein', 'go', 'node', 'python', 'ruby', 'rust']
  endif

  if count(targets, 'dein') > 0
    call dein#update()
    if executable('deno')
      call dein#deno_cache()
    endif
    call dein#recache_runtimepath()
  endif

  if exists('g:goenv') && count(targets, 'go') > 0
    call s:echow('Update go environment...')
    let pkgs = readfile(g:goenv .. '/tools.txt')
    let goopts = { 'cwd': g:goenv, 'env': { 'GOBIN': g:goenv .. '/bin' } }
    call s:Promise.all(map(pkgs, {_,pkg -> vimrc#exec(['go', 'install', pkg], goopts)}))
        \.then({-> s:echow('Update go environment... Done')}, s:onerror)
  endif

  if exists('g:ndenv') && count(targets, 'node') > 0
    call s:echow('Update node environment...')
    let ndopts = { 'cwd': g:ndenv }
    if a:thawed
      let p = vimrc#exec(['npm', 'exec', '--yes', '--', 'npm-check-updates', '--upgrade'], ndopts)
             \.then({-> vimrc#exec(['npm', 'audit', 'fix'], ndopts)})
             \.then({-> vimrc#exec(['npm', 'install'], ndopts)})
    else
      let p = vimrc#exec(['npm', 'ci'], ndopts)
    endif
    call p.then({-> s:echow('Update node environment... Done')}, s:onerror)
  endif

  if exists('g:pyenv') && count(targets, 'python') > 0
    call s:echow('Update python environment...')
    let pyopts = { 'cwd': g:pyenv, 'env': { 'VIRTUAL_ENV': g:pyenv } }
    if a:thawed && filereadable(g:pyenv .. '/requirements.txt')
      let p = vimrc#exec(['pip', 'install', '-U', 'pip'], pyopts)
             \.then({-> vimrc#exec(['pip', 'list', '--local', '--format=json'], pyopts)})
             \.then({out -> map(json_decode(join(out, "\n")), {_,x -> x.name})})
             \.then({pkgs -> vimrc#exec(['pip', 'install', '-U'] + pkgs, pyopts)})
             \.then({-> vimrc#exec(['pip', 'freeze', '--local'], pyopts)})
             \.then({out -> writefile(out, g:pyenv .. '/requirements.txt')})
    elseif filereadable(g:pyenv .. '/requirements.txt')
      let p = vimrc#exec(['pip', 'install', '-U', 'pip'], pyopts)
             \.then({-> vimrc#exec(['pip', 'install', '-r', g:pyenv .. '/requirements.txt'], pyopts)})
    else
      let p = vimrc#exec(['pip', 'install', '-U', 'pip', 'pynvim'], pyopts)
    endif
    call p.then({-> s:echow('Update python environment... Done')}, s:onerror)
  endif

  if exists('g:rbenv') && count(targets, 'ruby') > 0
    call s:echow('Update ruby environment...')
    let rbopts = { 'cwd': g:rbenv, 'env': { 'PATH': s:removepath(g:rbenv .. '/bin') } }
    if a:thawed
      let p = vimrc#exec(['bundle', 'config', 'unset', '--local', 'deployment'], rbopts)
             \.then({-> vimrc#exec(['bundle', 'update', '--all'], rbopts)})
    else
      let p = vimrc#exec(['bundle', 'install'], rbopts)
    endif
    call p.then({-> s:echow('Update ruby environment... Done')}, s:onerror)
  endif

  if exists('g:rsenv') && count(targets, 'rust') > 0
    call s:echow('Update rust environment...')
    let pkgs = readfile(g:rsenv .. '/tools.txt')
    let rsopts = { 'cwd': g:rsenv, 'env': { 'CARGO_HOME': g:cachedir .. '/rust', 'CARGO_INSTALL_ROOT': g:rsenv } }
    call vimrc#exec(['cargo', 'install', '--force'] + pkgs, rsopts)
        \.then({-> s:echow('Update rust environment... Done')}, s:onerror)
  endif
endfunction

function vimrc#clean() abort
  for plugin in dein#check_clean()
    call delete(plugin, 'rf')
    call delete(fnamemodify(plugin, ':h'), 'd')
  endfor
  call dein#each('git reflog expire --expire=all --all')
  call dein#each('git gc --aggressive --prune=now')
  if executable('deno')
    call dein#deno_cache()
  endif
  call dein#recache_runtimepath()
  call s:echow('Cleaning done')
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

function vimrc#project_dir(file) abort
  if &buftype !=# '' | return | endif
  if a:file ==# '' | return | endif
  if isdirectory(a:file) | return | endif
  if a:file =~# '^gina://' | return | endif
  let file = substitute(a:file, '^sudo:', '', '')
  let filedir = fnamemodify(file, ':h')
  let targetdir = escape(filedir, '*[]?{};, ')

  let anchordirs = ['.git', '.hg', '.bzr', '.svn']
  for anchordir in anchordirs
    let result = finddir(anchordir, targetdir..';')
    if result !=# ''
      return fnamemodify(result, ':p:h:h')
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
  for anchorfile in anchorfiles
    let result = findfile(anchorfile, targetdir..';')
    if result !=# ''
      return fnamemodify(result, ':p:h')
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
