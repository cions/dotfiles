function asyncomplete#preprocessor#preprocess(options, matches) abort
  let items = []
  let startcols = []
  for [source_name, matches] in items(a:matches)
    let priority = get(asyncomplete#get_source_info(source_name), 'priority', 10)
    let startcol = matches['startcol']
    let base = a:options['typed'][startcol-1:]
    for item in matches['items']
      if stridx(tolower(item['word']), tolower(base)) == 0
        let item['priority'] = priority
        call add(startcols, startcol)
        call add(items, item)
      endif
    endfor
  endfor

  let items = sort(items, {a, b -> b['priority'] - a['priority']})
  let a:options['startcol'] = min(startcols)
  call asyncomplete#preprocess_complete(a:options, items)
endfunction
