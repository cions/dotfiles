" Vim filetype plugin file
" Language: C

if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

let s:cpo_save = &cpo
set cpo&vim

if !exists('b:local_include_paths')
  let s:project_dir = finddir('.git', '.;')
  if s:project_dir ==# ''
    for s:file in ['CMakeLists.txt', 'configure.ac', 'configure', 'Makefile']
      let s:result = findfile(s:file, '.;', -1)
      if !empty(s:result)
        let s:project_dir = s:result[-1]
        break
      endif
    endfor
  endif
  if s:project_dir !=# ''
    let s:project_dir = fnamemodify(s:project_dir, ':h')
  else
    let s:project_dir = '.'
  endif
  let s:headers = globpath(s:project_dir, '**/*.{h,hpp}', 1, 1)
  let b:local_include_path = map(s:headers, {_, x -> fnamemodify(x, ':h')})
  let b:local_include_path = uniq(sort(b:local_include_path))
endif

if !exists('s:system_include_paths')
  let s:system_include_paths = []
  call add(s:system_include_paths, '/usr/local/include')
  if executable('clang')
    let s:resource_dir = trim(system('clang -print-resource-dir'))
    call add(s:system_include_paths,
          \ fnamemodify(s:resource_dir . '/include', ':p'))
  else
    call add(s:system_include_paths,
          \ trim(system('gcc -print-file-name=include')))
    call add(s:system_include_paths,
          \ trim(system('gcc -print-file-name=include-fixed')))
  endif
  call add(s:system_include_paths, '/usr/include')
endif

let &l:path = '.,' . join(filter(
      \ b:local_include_path + s:system_include_paths,
      \ { _, x -> isdirectory(x) }), ',')

let &cpo = s:cpo_save
unlet s:cpo_save
