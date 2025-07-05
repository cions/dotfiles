scriptversion 4

function vimrc#caw#setup() abort
  map gc <Plug>(caw:prefix)
  map gcc <Plug>(caw:hatpos:toggle)
  map gci <Plug>(caw:hatpos:comment)
  map gcu <Plug>(caw:hatpos:uncomment)
  map gcI <Plug>(caw:zeropos:comment)
  map gca <Plug>(caw:dollarpos:comment)
  map gcw <Plug>(caw:wrap:comment)
  map gcW <Plug>(caw:wrap:uncomment)
  nmap gcd yyPv']<Plug>(caw:hatpos:comment)+
  xmap gcd yP'[v']<Plug>(caw:hatpos:comment)'>+

  let g:caw_hatpos_skip_blank_line = 1
  let g:caw_dollarpos_sp_left = "  "
endfunction
