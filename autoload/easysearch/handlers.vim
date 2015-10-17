fu! easysearch#handlers#cursor_moved()
  if easysearch#util#timenow() < &updatetime/1000.0 + b:last_update_time
    return -1
  endif

  call easysearch#win#update()

  if s:completed()
    call easysearch#handlers#finish()
  endif
endfu

fu! easysearch#handlers#cursor_hold()
  call easysearch#win#update()

  if s:completed()
    call easysearch#handlers#finish()
  else
    call feedkeys('\<Plug>(easysearch-Nop)')
  endif
endfu

fu! easysearch#handlers#finish()
  au! EasysearchAutocommands * <buffer>
  let &updatetime = float2nr(b:updatetime_backup)

  setlocal noreadonly
  setlocal modifiable
  call setline(1, getline(1) . '. Finished.' )
  setlocal readonly
  setlocal nomodifiable
  setlocal nomodified
endfu

fu! s:completed()
  return !b:handler_running && b:_es_iterator == len(b:qf)
endfu
