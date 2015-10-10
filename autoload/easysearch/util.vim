fu! easysearch#util#parse_results(from, to)
  if b:qf_file == [] | return [] | endif
  let r = '^\(.\{-}\)\:\(\d\{-}\)\:\(\d\{-}\)\:\(.\{-}\)$'
  let results = []

  for i in range(a:from, a:to - 1)
    let el = matchlist(b:qf_file[i], r)[1:4]
    if empty(el) | continue | endif
    let new_result_elem = { 'fname': el[0], 'lnum': el[1], 'col': el[2], 'text': el[3] }
    call add(results, new_result_elem)
  endfor
  return results
endfu

fu! easysearch#util#trunc_str(str, size)
  if len(a:str) > a:size
    return a:str[:a:size] . '…'
  endif

  return a:str
endfu


fu! easysearch#util#escape_str(str)
  return substitute(a:str, '["#$%]', '\\\0', 'g')
endfu


fu! easysearch#util#timenow()
  let now = reltime()
  return str2float(reltimestr([now[0] % 10000, now[1]/1000 * 1000]))
endfu


" Extracted from tpope/dispatch
fu! easysearch#util#request_status()
  let request = b:request
  try
    let status = str2nr(readfile(request.file . '.complete', 1)[0])
  catch
    let status = -1
  endtry
  return status
endfu

fu! easysearch#util#cgetfile(request) abort
  let request = a:request
  if !filereadable(fnameescape(request.file)) | return 1 | endif

  let efm = &l:efm
  let makeprg = &l:makeprg
  let compiler = get(b:, 'current_compiler', '')
  let cd = exists('*haslocaldir') && haslocaldir() ? 'lcd' : 'cd'
  let dir = getcwd()
  let modelines = &modelines
  try
    let &modelines = 0
    exe cd fnameescape(request.directory)
    let b:qf_file = readfile(fnameescape(request.file))
  catch '^E40:'
    echohl Error | echo v:exception | echohl None
  finally
    let &modelines = modelines
    exe cd fnameescape(dir)
  endtry

  return 0
endfu

fu! easysearch#util#running(handler, pid) abort
  if empty(a:pid)
    return 0
  elseif exists('*dispatch#'.a:handler.'#running')
    return dispatch#{a:handler}#running(a:pid)
  elseif has('win32')
    let tasklist_cmd = 'tasklist /fi "pid eq '.a:pid.'"'
    if &shellxquote ==# '"'
      let tasklist_cmd = substitute(tasklist_cmd, '"', "'", "g")
    endif
    return system(tasklist_cmd) =~# '==='
  else
    call system('kill -0 '.a:pid)
    return !v:shell_error
  endif
endfu
