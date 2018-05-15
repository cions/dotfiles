function! vimrc#clang_format#on_source() abort
  let g:clang_format#auto_format = 1
  let g:clang_format#code_style = 'llvm'
  let g:clang_format#style_options = {
        \   'AccessModifierOffset': -4,
        \   'AllowShortIfStatementsOnASingleLine': 'true',
        \   'Standard': 'C++11'
        \ }

  augroup ClangFormat
    au!
    au FileType c,cpp,objc nnoremap <buffer> sf :ClangFormat<CR>
  augroup END
endfunction
