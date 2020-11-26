function asyncomplete#preprocessor#preprocess(options, matches) abort
  let l:items = []
  let l:startcols = []
  for [l:source_name, l:matches] in items(a:matches)
    let l:priority = get(asyncomplete#get_source_info(l:source_name), 'priority', 10)
    let l:startcol = l:matches['startcol']
    let l:base = a:options['typed'][l:startcol-1:]
    for l:item in l:matches['items']
      if stridx(tolower(l:item['word']), tolower(l:base)) == 0
        let l:item['priority'] = l:priority
        call add(l:startcols, l:startcol)
        call add(l:items, l:item)
      endif
    endfor
  endfor

  let l:items = sort(l:items, {a, b -> b['priority'] - a['priority']})
  let a:options['startcol'] = min(l:startcols)
  call asyncomplete#preprocess_complete(a:options, l:items)
endfunction
