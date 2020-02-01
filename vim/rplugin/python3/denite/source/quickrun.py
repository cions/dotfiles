# vim:

from denite.base.source import Base
from denite.util import Candidates, Nvim, UserContext


class Source(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = 'quickrun'
        self.kind = 'command'

        self.default_keys = set(self.vim.eval(
            'keys(g:quickrun#default_config)'))

    def gather_candidates(self, context: UserContext) -> Candidates:
        context['is_interactive'] = True

        user_keys = set(self.vim.eval('keys(get(g:, "quickrun_config", {}))'))
        keys = (user_keys | self.default_keys) - {'_'}
        keys = sorted(x for x in keys if x.startswith(context['input']))

        return [{
            'action__command': f'QuickRun -type {x}',
            'word': x,
        } for x in keys]
