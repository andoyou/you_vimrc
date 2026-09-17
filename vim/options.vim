syntax enable
set autoindent backspace=indent,eol,start cursorcolumn cursorline
set encoding=utf-8 expandtab fileencodings=utf-8,cp932,sjis,euc-jp
set hlsearch laststatus=2 nobackup noswapfile noundofile nowrap number
set shiftwidth=4 softtabstop=4 tabstop=4 showmatch smartindent title textwidth=0 wrapscan
if exists('+imdisable')
  set imdisable
endif
if exists('+termguicolors')
  if has('gui_running') || $COLORTERM =~? 'truecolor\|24bit' || $TERM =~# 'direct'
    set termguicolors
  else
    set notermguicolors
  endif
endif
" Keep terminal capability detection; do not force 256 colors on every terminal.
filetype plugin indent on
if exists(':packadd') == 2
  packadd! matchit
endif
