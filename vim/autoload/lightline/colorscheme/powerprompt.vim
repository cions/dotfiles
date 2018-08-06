" powerprompt colorscheme for lightline

let s:red     = [['#262626', 235], ['#ff8787', 210]]
let s:magenta = [['#262626', 235], ['#ff87ff', 213]]
let s:blue    = [['#262626', 235], ['#87afff', 111]]
let s:cyan    = [['#262626', 235], ['#87d7ff', 117]]
let s:green   = [['#262626', 235], ['#afff87', 156]]
let s:yellow  = [['#262626', 235], ['#ffff5f', 227]]
let s:orange  = [['#262626', 235], ['#ffaf87', 216]]
let s:black   = [['#d0d0d0', 252], ['#262626', 235]]
let s:gray1   = [['#d0d0d0', 252], ['#444444', 238]]
let s:gray2   = [['#d0d0d0', 252], ['#666666', 242]]
let s:gray3   = [['#eeeeee', 255], ['#8a8a8a', 245]]
let s:gray4   = [['#444444', 238], ['#a8a8a8', 248]]
let s:white   = [['#262626', 235], ['#d0d0d0', 252]]

let s:palette = {
      \   'normal': {
      \     'left': [s:cyan, s:gray2],
      \     'middle': [s:gray1],
      \     'right': [s:gray3, s:gray2],
      \     'warning': [s:yellow],
      \     'error': [s:red]
      \   },
      \   'inactive': {
      \     'left': [s:gray2],
      \     'middle': [s:gray1],
      \     'right': [s:gray3, s:gray2]
      \   },
      \   'insert': { 'left': [s:green, s:gray2] },
      \   'replace': { 'left': [s:red, s:gray2] },
      \   'visual': { 'left': [s:orange, s:gray2] },
      \   'tabline': {
      \     'left': [s:gray2],
      \     'tabsel': [s:gray1],
      \     'middle': [s:gray3],
      \     'right': [s:gray4]
      \   }
      \ }

let g:lightline#colorscheme#powerprompt#palette =
      \ lightline#colorscheme#flatten(s:palette)
