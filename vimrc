" Vim 8.2+; resolve the installed symlink back to this repository.
set nocompatible
let g:personal_vim_root = fnamemodify(resolve(expand('<sfile>:p')), ':h')
for s:module in ['options', 'plugins', 'filetypes', 'mappings', 'clipboard']
  execute 'source ' . fnameescape(g:personal_vim_root . '/vim/' . s:module . '.vim')
endfor
unlet s:module
" Machine-specific overrides are deliberately not tracked.
if filereadable(expand('~/.vim/local.vim'))
  execute 'source ' . fnameescape(expand('~/.vim/local.vim'))
endif
