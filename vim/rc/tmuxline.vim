let g:tmuxline_theme = 'lightline'
let g:tmuxline_preset = {
      \   'a': ['#S', '#H'],
      \   'b': [
      \     join([
      \       '#(~/.tmux/freezer query "[P]" "")',
      \       '#(~/.tmux/freezer -e query "[E]" "")',
      \       '#(~/.tmux/freezer -w query "[W]" "")'
      \     ], '')
      \   ],
      \   'win': '#I:#W#F',
      \   'cwin': '#I:#W#F',
      \   'x': ['#(~/.tmux/sysinfo memusage)',
      \         '#(~/.tmux/sysinfo swapusage)'],
      \   'y': ['#(~/.tmux/sysinfo loadavg)'],
      \   'z': ['%Y-%m-%d', '%H:%M'],
      \   'options': {
      \     'status-justify': 'left'
      \   }
      \ }

