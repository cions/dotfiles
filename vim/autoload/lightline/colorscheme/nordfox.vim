" nordfox colorscheme for lightline

let s:black   = ['#cdcecf', '#2e3440', 252, 236]
let s:red     = ['#2e3440', '#bf616a', 236, 131]
let s:green   = ['#2e3440', '#a3be8c', 236, 108]
let s:yellow  = ['#2e3440', '#ebcb8b', 236, 222]
let s:blue    = ['#2e3440', '#81a1c1', 236, 110]
let s:magenta = ['#2e3440', '#b48ead', 236, 139]
let s:cyan    = ['#2e3440', '#88c0d0', 236, 109]
let s:white   = ['#2e3440', '#e5e9f0', 236, 254]
let s:orange  = ['#2e3440', '#c9826b', 236, 173]
let s:pink    = ['#2e3440', '#bf88bc', 236, 139]
let s:gray1   = ['#cdcecf', '#39404f', 252, 237]
let s:gray2   = ['#cdcecf', '#444c5e', 252, 238]
let s:gray3   = ['#e5e9f0', '#7e8188', 254, 244]
let s:gray4   = ['#444c5e', '#abb1bb', 238, 145]

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

let g:lightline#colorscheme#nordfox#palette = s:palette
