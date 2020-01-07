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
  call s:echow('Downloading dein...')
  let repourl = 'https://github.com/Shougo/dein.vim'
  return vimrc#exec(['git', 'clone', '--depth=1', repourl, a:deinrepo], {})
        \.then({-> s:echow('Downloading dein... Done')}, s:onerror)
endfunction

function vimrc#setup_goenv(goenv) abort
  if !executable('go')
    return s:Promise.reject('go not found').catch(s:onerror)
  endif
  if !filereadable(a:goenv .. '/tools.txt')
    return s:Promise.reject('tools.txt not found').catch(s:onerror)
  endif
  let g:goenv = a:goenv
  let $PATH = g:goenv .. '/bin:' .. $PATH
  if isdirectory(g:goenv .. '/bin')
    return s:Promise.resolve()
  endif

  call s:echow('Setup go environment...')
  let pkgs = readfile(g:goenv .. '/tools.txt')
  let opts = { 'cwd': g:goenv, 'env': { 'GOBIN': g:goenv .. '/bin' } }
  if filereadable(g:goenv .. '/go.mod')
    let p = s:Promise.resolve()
  else
    let p = vimrc#exec(['go', 'mod', 'init', 'vim-goenv'], opts)
  endif
  return p.then({-> vimrc#exec(['go', 'get'] + pkgs, opts)})
         \.then({-> s:echow('Setup go environment... Done')}, s:onerror)
         \.catch({-> rmdir(g:goenv .. '/bin', 'r')})
endfunction

function vimrc#setup_ndenv(ndenv) abort
  if !executable('npm')
    return s:Promise.reject('npm not found').catch(s:onerror)
  endif
  if !filereadable(a:ndenv .. '/package.json')
    return s:Promise.reject('package.json not found').catch(s:onerror)
  endif
  let g:ndenv = a:ndenv
  let $PATH = g:ndenv .. '/node_modules/.bin:' .. $PATH
  if isdirectory(g:ndenv .. '/node_modules/.bin')
    return s:Promise.resolve()
  endif

  call s:echow('Setup node environment...')
  return vimrc#exec(['npm', 'install'], { 'cwd': g:ndenv })
        \.then({-> s:echow('Setup node environment... Done')}, s:onerror)
        \.catch({-> rmdir(g:ndenv .. '/node_modules/.bin', 'r')})
endfunction

function vimrc#setup_pyenv(pyenv) abort
  if !executable('python3')
    return s:Promise.reject('python3 not found').catch(s:onerror)
  endif
  let g:pyenv = a:pyenv
  let $PATH = g:pyenv .. '/bin:' .. $PATH
  if isdirectory(g:pyenv .. '/bin')
    return s:Promise.resolve()
  endif

  call s:echow('Setup python environment...')
  let opts = { 'cwd': g:pyenv }
  let p = vimrc#exec(['python3', '-mvenv', '--system-site-packages', g:pyenv], opts)
  let opts.env = { 'VIRTUAL_ENV': g:pyenv }
  let p = p.then({-> vimrc#exec(['pip', 'install', '-U', 'pip'], opts)})
  if filereadable(g:pyenv .. '/requirements.txt')
    let p = p.then({-> vimrc#exec(['pip', 'install', '-r', g:pyenv .. '/requirements.txt'], opts)})
  else
    let p = p.then({-> vimrc#exec(['pip', 'install', 'pynvim'], opts)})
  endif
  return p.then({-> s:echow('Setup python environment... Done')}, s:onerror)
         \.catch({-> rmdir(g:pyenv .. '/bin', 'r')})
endfunction

function vimrc#setup_rbenv(rbenv) abort
  if !executable('bundle')
    return s:Promise.reject('bundle not found').catch(s:onerror)
  endif
  if !filereadable(a:rbenv .. '/Gemfile')
    return s:Promise.reject('Gemfile not found').catch(s:onerror)
  endif
  let g:rbenv = a:rbenv
  let $PATH = g:rbenv .. '/bin:' .. $PATH
  if isdirectory(g:rbenv .. '/bin')
    return s:Promise.resolve()
  endif

  call s:echow('Setup ruby environment...')
  let opts = { 'cwd': g:rbenv }
  return vimrc#exec(['bundle', 'install', '--path', 'vendor/bundle'], opts)
        \.then({-> vimrc#exec(['bundle', 'binstubs', '--all'], opts)})
        \.then({-> s:echow('Setup ruby environment... Done')}, s:onerror)
        \.catch({-> rmdir(g:rbenv .. '/bin', 'r')})
endfunction

function vimrc#setup_rsenv(rsenv) abort
  if !executable('cargo')
    return s:Promise.reject('cargo not found').catch(s:onerror)
  endif
  if !filereadable(a:rsenv .. '/tools.txt')
    return s:Promise.reject('tools.txt not found').catch(s:onerror)
  endif
  let g:rsenv = a:rsenv
  let $PATH = g:rsenv .. '/bin:' .. $PATH
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

function vimrc#update() abort
  call dein#update()

  if exists('g:goenv')
    let pkgs = readfile(g:goenv .. '/tools.txt')
    let opts = { 'cwd': g:goenv, 'env': { 'GOBIN': g:goenv .. '/bin' } }
    call vimrc#exec(['go', 'get', '-u'] + pkgs, opts)
        \.then({-> s:echow('go environment updated')}, s:onerror)
  endif

  if exists('g:ndenv')
    call vimrc#exec(['npm', 'update'], { 'cwd': g:ndenv })
        \.then({-> s:echow('node environment updated')}, s:onerror)
  endif

  if exists('g:pyenv')
    let opts = { 'cwd': g:pyenv, 'env': { 'VIRTUAL_ENV': g:pyenv } }
    call vimrc#exec(['pip', 'list', '--local', '--format=json'], opts)
        \.then({out -> map(json_decode(join(out, "\n")), {_,x -> x.name})})
        \.then({pkgs -> vimrc#exec(['pip', 'install', '-U'] + pkgs, opts)})
        \.then({-> vimrc#exec(['pip', 'freeze', '--local'], opts)})
        \.then({out -> writefile(out, g:pyenv .. '/requirements.txt')})
        \.then({-> s:echow('python environment updated')}, s:onerror)
  endif

  if exists('g:rbenv')
    let opts = { 'cwd': g:rbenv }
    call vimrc#exec(['bundle', 'update'], opts)
        \.then({-> vimrc#exec(['bundle', 'binstubs', '--all'], opts)})
        \.then({-> s:echow('ruby environment updated')})
  endif

  if exists('g:rsenv')
    let pkgs = readfile(g:rsenv .. '/tools.txt')
    let opts = { 'cwd': g:rsenv, 'env': { 'CARGO_HOME': g:cachedir .. '/rust', 'CARGO_INSTALL_ROOT': g:rsenv } }
    call vimrc#exec(['cargo', 'install', '--force'] + pkgs, opts)
        \.then({-> s:echow('rust environment updated')})
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
