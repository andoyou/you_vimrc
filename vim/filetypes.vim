augroup PersonalFiletypes
  autocmd!
  autocmd BufRead,BufNewFile *.slim setfiletype slim
  autocmd BufRead,BufNewFile *.{md,mdwn,mkd,mkdn,mark*} setfiletype markdown
  autocmd FileType css,scss,sass,json,php,zsh setlocal shiftwidth=4 softtabstop=4 tabstop=4 expandtab
  autocmd FileType html,javascript,ruby,eruby,slim,vim setlocal shiftwidth=2 softtabstop=2 tabstop=2 expandtab
augroup END
