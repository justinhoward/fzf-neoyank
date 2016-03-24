let s:cpo_save = &cpo
set cpo&vim

if !exists('g:fzf_neoyank_register')
  let g:fzf_neoyank_register = '"'
endif

if !exists('g:fzf_neoyank_command')
  let g:fzf_neoyank_command = 'p'
endif

function! fzf_neoyank#show(...)
  let register = exists('a:1') ? a:1 : g:fzf_neoyank_register
  let command = exists('a:2') ? a:2 : g:fzf_neoyank_command

  call fzf#run({
  \ 'source': s:get_history(register, command),
  \ 'down': '40%',
  \ 'options': '+m --delimiter="\t" --with-nth 3.. --tiebreak=index',
  \ 'sink': function('s:history_sink') })
endfunction

function! s:get_history(register, command)
  let histories = neoyank#_get_yank_histories()
  let reg_history = get(histories, a:register, [])
  return map(
  \ copy(reg_history),
  \ 'a:command . "\t" . v:val[1] . "\t"  . v:val[0]')
endfunction

function! s:history_sink(line)
  let parts = split(a:line, "\t", 1)
  let command = parts[0]
  let regtype = parts[1]
  let text = join(parts[2:], "\t")
  call s:paste(text, command, regtype)
endfunction

function! s:paste(text, command, type)
  let old_reg = getreg('"')
  let old_regtype = getregtype('"')

  call setreg('"', a:text, a:type)
  try
    execute 'normal! ""' . a:command
  finally
    call setreg('"', old_reg, old_regtype)
  endtry
endfunction

let &cpo = s:cpo_save
unlet s:cpo_save
