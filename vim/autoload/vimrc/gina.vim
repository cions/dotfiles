function vimrc#gina#on_source() abort
  let g:gina#action#mark_sign_text = '*'
  let g:gina#component#repo#commit_length = 7
  let g:gina#command#blame#formatter#format = '%su%=%ti %ma%in'
  let g:gina#command#blame#formatter#timestamp_months = 0
  let g:gina#command#blame#formatter#timestamp_format1 = '%Y-%m-%d'
  let g:gina#command#blame#formatter#timestamp_format2 = '%Y-%m-%d'
endfunction

function vimrc#gina#on_post_source() abort
  call gina#custom#command#option('status', '-s|--short')
  call gina#custom#command#option('/.*', '--opener', 'botright split')
  call gina#custom#command#option('/\%(status\|commit)', '-u|--untracked-files')

  call gina#custom#mapping#nmap('branch', 'dd', '<Plug>(gina-branch-delete)')
  call gina#custom#mapping#nmap('branch', 'DD', '<Plug>(gina-branch-delete-force)')
  call gina#custom#mapping#nmap('branch', 'mm', '<Plug>(gina-branch-move)')
  call gina#custom#mapping#nmap('branch', 'MM', '<Plug>(gina-branch-move-force)')
  call gina#custom#mapping#nmap(
        \ 'commit', '<C-^>',
        \ ':Gina status<CR>',
        \ { 'noremap': 1, 'silent': 1 })
  call gina#custom#mapping#nmap(
        \ 'status', '<C-^>',
        \ ':Gina commit<CR>',
        \ { 'noremap': 1, 'silent': 1 })

  call gina#custom#action#alias('branch', 'merge', 'commit:merge')
  call gina#custom#action#alias('branch', 'track', 'commit:track')
  call gina#custom#action#alias('branch', 'rebase', 'commit:rebase')

  call gina#custom#execute('/.*', 'setlocal winfixheight')
endfunction
