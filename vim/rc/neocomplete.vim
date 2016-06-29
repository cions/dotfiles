call neocomplete#custom#source('_', 'converters', [
      \   'converter_remove_overlap',
      \   'converter_remove_last_paren',
      \   'converter_delimiter',
      \   'converter_abbr'
      \ ])

if !exists('g:neocomplete#sources#omni#functions')
  let g:neocomplete#sources#omni#functions = {}
endif
let g:neocomplete#sources#omni#functions.css = 'csscomplete#CompleteCSS'
let g:neocomplete#sources#omni#functions.html = 'htmlcomplete#CompleteTags'
let g:neocomplete#sources#omni#functions.xml = 'xmlcomplete#CompleteTags'

if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif

if !exists('g:neocomplete#force_omni_input_patterns')
  let g:neocomplete#force_omni_input_patterns = {}
endif

if !exists('g:neocomplete#sources#vim#complete_functions')
  let g:neocomplete#sources#vim#complete_functions = {}
endif
let g:neocomplete#sources#vim#complete_functions.Unite = 'unite#complete#source'
let g:neocomplete#sources#vim#complete_functions.VimFiler = 'vimfiler#complete'
let g:neocomplete#sources#vim#complete_functions.VimShell = 'vimshell#complete'
let g:neocomplete#sources#vim#complete_functions.Ref = 'ref#complete'
