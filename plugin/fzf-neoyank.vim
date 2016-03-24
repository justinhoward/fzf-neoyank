let s:cpo_save = &cpo
set cpo&vim

command! -nargs=* FZFNeoyank call fzf_neoyank#show(<f-args>)

let &cpo = s:cpo_save
unlet s:cpo_save
