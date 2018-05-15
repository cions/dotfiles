function! s:system_site_packages(bool) abort
  let lines = readfile(g:pyenv . '/pyvenv.cfg')
  let lines = map(lines, { i, v ->
        \ substitute(v, '^include-system-site-packages = \zs.*', a:bool, '') })
  call writefile(lines, g:pyenv . '/pyvenv.cfg')
endfunction

function! vimrc#pyenv#init() abort
  call job_start(['python3', '-mvenv', g:pyenv], {
        \   'exit_cb': { job, code -> code == 0 && vimrc#pyenv#install() },
        \   'stoponexit': ''
        \ })
endfunction

function! vimrc#pyenv#install() abort
  call s:system_site_packages('false')
  call job_start(['pip', 'install', '-qU', 'pip'] + g:python_modules, {
        \   'cwd': g:pyenv,
        \   'env': { 'PATH': g:pyenv . '/bin:' . $PATH },
        \   'exit_cb': { job, code -> s:system_site_packages('true') },
        \   'stoponexit': ''
        \ })
endfunction

function! vimrc#pyenv#init_path() abort
  python3 <<EOF
import vim
import sys
import sysconfig
import pathlib
import importlib.machinery

class VimPyvenvFinder(importlib.machinery.PathFinder):
    @classmethod
    def find_spec(cls, fullname, path, target=None):
        if path is not None:
            return None
        buf = vim.current.buffer
        if not buf.name or buf.options['buftype']:
            return None
        parents = pathlib.Path(buf.name).absolute().parents
        venv = next((p for p in parents if (p / 'pyvenv.cfg').is_file()), None)
        if venv is None:
            return None
        paths = sysconfig.get_paths(vars={ 'base': str(venv) })
        path = [paths['scripts'], paths['purelib']]
        return super().find_spec(fullname, path, target)

sys.meta_path.append(VimPyvenvFinder)
EOF
endfunction
