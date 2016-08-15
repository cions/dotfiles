" =============================================================================
" Filename: autoload/lightline/colorscheme/powerprompt.vim
" Author: cions
" License: MIT License
" Last Change: 2016-08-05
" =============================================================================
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

let s:p = {'normal': {}, 'inactive': {}, 'insert': {}, 'replace': {}, 'visual': {}, 'tabline': {}}
let s:p.normal.left     = [s:cyan, s:gray2]
let s:p.normal.middle   = [s:gray1]
let s:p.normal.right    = [s:gray3, s:gray2]
let s:p.normal.warning  = [s:yellow]
let s:p.normal.error    = [s:red]
let s:p.inactive.left   = [s:gray2]
let s:p.inactive.middle = [s:gray1]
let s:p.inactive.right  = [s:gray3, s:gray2]
let s:p.insert.left     = [s:green, s:gray2]
let s:p.replace.left    = [s:red, s:gray2]
let s:p.visual.left     = [s:orange, s:gray2]
let s:p.tabline.left    = [s:gray2]
let s:p.tabline.tabsel  = [s:gray1]
let s:p.tabline.middle  = [s:gray3]
let s:p.tabline.right   = [s:gray4]

let g:lightline#colorscheme#powerprompt#palette = lightline#colorscheme#flatten(s:p)
