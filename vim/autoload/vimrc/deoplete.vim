function vimrc#deoplete#on_source() abort
  let g:deoplete#enable_at_startup = 1

  inoremap <expr> <Tab> vimrc#deoplete#tab()
  inoremap <expr> <C-y> deoplete#close_popup()
  inoremap <expr> <C-g> deoplete#cancel_popup()
  inoremap <silent><expr> <C-x><C-n> deoplete#manual_complete()
endfunction

function vimrc#deoplete#on_post_source() abort
  call deoplete#custom#option({
        \   'auto_complete_delay': 10,
        \   'smart_case': v:true,
        \   'ignore_sources': {
        \     '_': ['around', 'dictionary', 'member', 'omni'],
        \   },
        \ })

  call deoplete#custom#source('_', 'sorters', ['sorter_word', 'sorter_rank'])
  call deoplete#custom#source('_', 'converters', [
        \   'converter_remove_parens',
        \   'converter_remove_overlap',
        \   'converter_truncate_abbr',
        \   'converter_truncate_kind',
        \   'converter_truncate_info',
        \   'converter_truncate_menu',
        \ ])
endfunction

function vimrc#deoplete#tab() abort
  let common_string = deoplete#complete_common_string()
  return common_string !=# '' ? common_string :
       \ pumvisible() ? "\<C-n>" : "\<TAB>"
endfunction
