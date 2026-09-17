" Installation is explicit: python3 install.py. Startup never accesses the network.
let s:base = expand('~/.vim/dein')
let s:manager = s:base . '/repos/github.com/Shougo/dein.vim'
if v:version >= 802 && filereadable(s:manager . '/autoload/dein.vim')
  if stridx(&runtimepath, s:manager) < 0
    execute 'set runtimepath^=' . escape(s:manager, ' ,\')
  endif
  call dein#begin(s:base)
  call dein#load_toml(g:personal_vim_root . '/dein.toml', {'merged': 0})
  call dein#end()
endif
if !empty(globpath(&runtimepath, 'colors/1989.vim'))
  colorscheme 1989
else
  colorscheme default
endif

filetype plugin indent on
