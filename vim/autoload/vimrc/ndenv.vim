function! vimrc#ndenv#init() abort
  let packagejson = '{"name":"vim-ndenv","version":"0.0.0"}'
  call mkdir(g:ndenv)
  call writefile([packagejson], g:ndenv . '/package.json')
  call job_start(['npm', 'install', '-q', '-S'] + g:node_packages, {
        \   'cwd': g:ndenv,
        \   'stoponexit': ''
        \ })
endfunction
