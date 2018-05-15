function! vimrc#language_client_neovim#on_source() abort
  let g:LanguageClient_autoStart = 1
  let g:LanguageClient_diagnosticsEnable = 0
  let g:LanguageClient_serverCommands = {}

  nnoremap <silent> K :<C-u>call LanguageClient#textDocument_hover()<CR>
  nnoremap <silent> gd :<C-u>call LanguageClient#textDocument_definition()<CR>
  nnoremap <silent> gD :<C-u>call LanguageClient#textDocument_implementation()<CR>
  nnoremap <silent> sf :<C-u>call LanguageClient#textDocument_formatting()<CR>
  nnoremap <silent> sn :<C-u>call LanguageClient#textDocument_rename()<CR>
  nnoremap <silent> sr :<C-u>call LanguageClient#textDocument_references()<CR>
endfunction
