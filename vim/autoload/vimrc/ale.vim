function! vimrc#ale#on_source() abort
  let g:ale_lint_on_enter = 1
  let g:ale_lint_on_filetype_changed = 1
  let g:ale_lint_on_save = 1
  let g:ale_lint_on_text_changed = 'never'
  let g:ale_lint_on_insert_leave = 0
  let g:ale_fix_on_save = 0

  let g:ale_warn_about_trailing_blank_lines = 0
  let g:ale_warn_about_trailing_whitespace = 0

  let g:ale_sign_error = '✖'
  let g:ale_sign_warning = '⚠'
  let g:ale_echo_msg_format = '%severity%: %code: %%s'
  let g:ale_echo_msg_error_str = 'E'
  let g:ale_echo_msg_warning_str = 'W'
  let g:ale_echo_msg_info_str = 'I'

  let g:ale_virtualenv_dir_names = ['.venv']
endfunction
