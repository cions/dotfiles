scriptversion 4

let g:vimrc#indent_style = {
      \   'c': ['space', 4],
      \   'cpp': ['space', 4],
      \   'dockerfile': ['space', 4],
      \   'javascript': ['space', 2],
      \   'json': ['tab', 2],
      \   'python': ['space', 4],
      \   'ruby': ['space', 4],
      \   'rust': ['space', 4],
      \   'typescript': ['space', 2],
      \   'vim': ['space', 2],
      \   'yaml': ['space', 2],
      \ }

function vimrc#guess_indent() abort
  if &l:buftype ==# 'nofile'
    return
  endif
  let maxlnum = min([1000, line('$')])
  let lines = getline(1, maxlnum)
  let tabindent = v:false
  let minindent = 0
  for line in lines
    if line =~# '\t'
      let tabindent = v:true
      break
    endif
    let indent = len(matchstr(line, '^ *'))
    if indent == 6 && &l:filetype ==# 'vim'
      let indent = 2
    endif
    if indent > 1
      if minindent ==# 0
        let minindent = indent
      else
        let minindent = min([minindent, indent])
      endif
    endif
  endfor
  let style = v:null
  if tabindent ==# v:true
    let style = ['tab', &l:tabstop]
  elseif minindent !=# 0
    let style = ['space', minindent]
  elseif has_key(g:vimrc#indent_style, &l:filetype)
    let style = g:vimrc#indent_style[&l:filetype]
  endif
  if style !=# v:null
    let &l:tabstop = style[1]
    let &l:shiftwidth = style[1]
    let &l:softtabstop = style[1]
    if style[0] ==# 'tab'
      setlocal noexpandtab
    else
      setlocal expandtab
    endif
  endif
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
  let anchordirs = [
        \   '.git',
        \   '.bzr',
        \   '.hg', 
        \   '.svn',
        \ ]
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
  let dir = fnamemodify(a:file, ':p:h')
  let lastdir = dir

  while dir !=# fnamemodify(dir, ':h')
    for anchordir in anchordirs
      if isdirectory(dir .. '/' .. anchordir)
        let lastdir = dir
      endif
    endfor

    for anchorfile in anchorfiles
      if filereadable(dir .. '/' .. anchorfile)
        let lastdir = dir
      endif
    endfor

    let dir = fnamemodify(dir, ':h')
  endwhile

  return lastdir
endfunction
