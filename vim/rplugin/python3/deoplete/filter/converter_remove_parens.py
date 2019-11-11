# vim:

from deoplete.base.filter import Base
from deoplete.util import Nvim, UserContext, Candidates

class Filter(Base):
    def __init__(self, vim: Nvim) -> None:
        super().__init__(vim)

        self.name = 'converter_remove_parens'
        self.description = 'remove parentheses converter'

    def filter(self, context: UserContext) -> Candidates:
        for candidate in context['candidates']:
            candidate['word'] = candidate['word'].rpartition('(')[0]
        return context['candidates']  # type: ignore

