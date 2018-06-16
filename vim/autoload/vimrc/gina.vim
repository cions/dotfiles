function! vimrc#gina#on_source() abort
  let g:gina#component#repo#commit_length = 7

  let g:gina#command#blame#formatter#format = '%su%=%ti %ma%in'
  let g:gina#command#blame#formatter#timestamp_months = 0
  let g:gina#command#blame#formatter#timestamp_format1 = '%Y-%m-%d'
  let g:gina#command#blame#formatter#timestamp_format2 = '%Y-%m-%d'
  " call gina#custom#mapping#nmap('blame', 'j', 'j<Plug>(gina-blame-echo)')
  " call gina#custom#mapping#nmap('blame', 'k', 'k<Plug>(gina-blame-echo)')

  call gina#custom#command#option('branch', '--group', 'gina')
  call gina#custom#command#option('branch', '--opener', 'botright split')
  call gina#custom#action#alias('branch', 'track', 'checkout:track')
  call gina#custom#action#alias('branch', 'merge', 'commit:merge')
  call gina#custom#action#alias('branch', 'rebase', 'commit:rebase')
  call gina#custom#mapping#nmap('branch', 'dd', '<Plug>(gina-branch-delete)')
  call gina#custom#mapping#nmap('branch', 'DD', '<Plug>(gina-branch-delete-force)')
  call gina#custom#mapping#nmap('branch', 'mm', '<Plug>(gina-branch-move)')
  call gina#custom#mapping#nmap('branch', 'MM', '<Plug>(gina-branch-move-force)')

  call gina#custom#command#option('commit', '--group', 'gina')
  call gina#custom#command#option('commit', '--opener', 'botright split')
  call gina#custom#command#option('commit', '-u|--untracked-files')
  call gina#custom#mapping#nmap('commit', '<C-^>', ':Gina status<CR>')

  call gina#custom#command#option('log', '--group', 'gina')
  call gina#custom#command#option('log', '--opener', 'botright split')

  call gina#custom#command#option('stash', '--group', 'gina')
  call gina#custom#command#option('stash', '--opener', 'botright split')

  call gina#custom#command#option('status', '--group', 'gina')
  call gina#custom#command#option('status', '--opener', 'botright split')
  call gina#custom#command#option('status', '-s|--short')
  call gina#custom#command#option('commit', '-u|--untracked-files')
  call gina#custom#mapping#nmap('status', '<C-^>', ':Gina commit<CR>')

  call gina#custom#command#option('tag', '--group', 'gina')
  call gina#custom#command#option('tag', '--opener', 'botright split')
endfunction
