let s:cpo_save = &cpo
set cpo&vim

if !exists('g:fzf_neoyank_register')
  let g:fzf_neoyank_register = '"'
endif

if !exists('g:fzf_neoyank_command')
  let g:fzf_neoyank_command = 'p'
endif

function! fzf_neoyank#show_for_selection(...)
  call call('fzf_neoyank#run', [1] + a:000)
endfunction

function! fzf_neoyank#show(...)
  call call('fzf_neoyank#run', [0] + a:000)
endfunction

function! fzf_neoyank#run(selection, ...)
  let register = exists('a:1') ? a:1 : g:fzf_neoyank_register
  let command = exists('a:2') ? a:2 : g:fzf_neoyank_command

  call fzf#run({
  \ 'source': s:get_history(register, command, a:selection),
  \ 'down': '40%',
  \ 'options': '+m --delimiter="\t" --with-nth 4.. --tiebreak=index',
  \ 'sink': function('s:history_sink') })
endfunction

function! s:get_history(register, command, selection)
  call neoyank#update()
  let histories = neoyank#_get_yank_histories()
  let reg_history = get(histories, a:register, [])
  return map(
  \ copy(reg_history),
  \ 'a:command . "\t" . a:selection . "\t" . v:val[1] . "\t"  . v:val[0]')
endfunction

function! s:history_sink(line)
  let parts = split(a:line, "\t", 1)
  let command = parts[0]
  let selection = str2nr(parts[1])
  let regtype = parts[2]
  let text = join(parts[3:], "\t")
  call s:paste(text, command, regtype, selection)
endfunction

function! s:paste(text, command, type, selection)
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')

  call setreg('"', a:text, a:type)
  try
    execute 'normal! ' . (a:selection ? 'gv' : '') . '""' . a:command
  finally
    call setreg('"', old_reg, old_regtype)
  endtry
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
