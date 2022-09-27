" custom colorscheme for lightline

let s:red     = ['#262626', '#ff8787', 235, 210]
let s:magenta = ['#262626', '#ff87ff', 235, 213]
let s:blue    = ['#262626', '#87afff', 235, 111]
let s:cyan    = ['#262626', '#87d7ff', 235, 117]
let s:green   = ['#262626', '#afff87', 235, 156]
let s:yellow  = ['#262626', '#ffff5f', 235, 227]
let s:orange  = ['#262626', '#ffaf87', 235, 216]
let s:black   = ['#d0d0d0', '#262626', 252, 235]
let s:gray1   = ['#d0d0d0', '#444444', 252, 238]
let s:gray2   = ['#d0d0d0', '#666666', 252, 242]
let s:gray3   = ['#eeeeee', '#8a8a8a', 255, 245]
let s:gray4   = ['#444444', '#a8a8a8', 238, 248]
let s:white   = ['#262626', '#d0d0d0', 235, 252]

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

let g:lightline#colorscheme#custom#palette = s:palette
