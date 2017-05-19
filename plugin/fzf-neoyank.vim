let s:cpo_save = &cpo
set cpo&vim

command! -nargs=* FZFNeoyank call fzf_neoyank#show(<f-args>)
command! -nargs=* -range FZFNeoyankSelection call fzf_neoyank#show_for_selection(<f-args>)

let &cpo = s:cpo_save
unlet s:cpo_save
