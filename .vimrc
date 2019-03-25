if !&compatible
    set nocompatible
endif
augroup MyAutoCmd
    autocmd!
augroup END

let s:cache_home = empty($XDG_CACHE_HOME) ? expand('~/.vim') : $XDG_CACHE_HOME
let s:dein_dir = s:cache_home . '/dein'
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

if !isdirectory(s:dein_repo_dir)
    call system('git clone https://github.com/Shougo/dein.vim ' . shellescape(s:dein_repo_dir))
endif

let &runtimepath = s:dein_repo_dir .",". &runtimepath
let s:toml_file = '~/.dein.toml'

if v:version > 703
    if dein#load_state(s:dein_dir)
        call dein#begin(s:dein_dir, [$MYVIMRC, s:toml_file])
        call dein#load_toml(s:toml_file)
        call dein#end()
        call dein#save_state()
    endif
    if has('vim_starting') && dein#check_install()
        call dein#install()
    endif
endif

if !has('gui_running')
  set t_Co=256
endif

syntax enable
colorscheme 1989

set autoindent
set backspace=indent,eol,start
set cursorcolumn
set cursorline
set encoding=utf-8
set expandtab
set fileencodings=utf-8,cp932,sjis,euc-jp
set hlsearch
set imdisable
set laststatus=2
set nobackup
set noswapfile
set noundofile
set nowrap
set nu
set shiftwidth=4
set showmatch
set smartindent
set tabstop=4
set title
set tw=0
set wrapscan
set clipboard+=unnamed
"vim --version | grep clipboard
" if -clipboard
" https://qiita.com/cawpea/items/3ca4ab80fc465d8eed7e

source $VIMRUNTIME/macros/matchit.vim

if has("autocmd")
  filetype plugin on
  filetype indent on

  autocmd BufRead,BufNewFile *.slim setfiletype slim

  autocmd FileType css        setlocal sw=4 sts=4 ts=4 et
  autocmd FileType scss       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType sass       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType html       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType javascript setlocal sw=2 sts=2 ts=2 et
  autocmd FileType js         setlocal sw=4 sts=4 ts=4 et
  autocmd FileType json       setlocal sw=4 sts=4 ts=4 et
  autocmd FileType php        setlocal sw=4 sts=4 ts=4 et
  autocmd FileType ruby       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType eruby      setlocal sw=2 sts=2 ts=2 et
  autocmd FileType slim       setlocal sw=2 sts=2 ts=2 et
  autocmd FileType vim        setlocal sw=2 sts=2 ts=2 et
  autocmd FileType zsh        setlocal sw=4 sts=4 ts=4 et
endif

let g:syntastic_enable_signs = 1
let g:syntastic_auto_loc_list = 2
let g:lightline = {
    \ 'colorscheme': 'wombat',
    \ 'mode_map': { 'c': 'NORMAL' },
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
    \ },
    \ 'component_function': {
    \   'modified': 'MyModified',
    \   'readonly': 'MyReadonly',
    \   'fugitive': 'MyFugitive',
    \   'filename': 'MyFilename',
    \   'fileformat': 'MyFileformat',
    \   'filetype': 'MyFiletype',
    \   'fileencoding': 'MyFileencoding',
    \   'mode': 'MyMode',
    \ },
    \ 'separator': { 'left': '<', 'right': '>' },
    \ 'subseparator': { 'left': '<', 'right': '>' }
    \ }

function! MyModified()
    return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction
function! MyReadonly()
    return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'R' : ''
endfunction
function! MyFilename()
    return ('' != MyReadonly() ? MyReadonly() . ' ' : '') .
            \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
            \  &ft == 'unite' ? unite#get_status_string() :
            \  &ft == 'vimshell' ? vimshell#get_status_string() :
            \ '' != expand('%:t') ? expand('%') : '[No Name]') .
            \ ('' != MyModified() ? ' ' . MyModified() : '')
endfunction
function! MyFugitive()
    if &ft !~? 'vimfiler\|gundo' && exists("*fugitive#head")
    let _ = fugitive#head()
        return strlen(_) ? '[Git] '._ : ''
    endif
    return ''
endfunction
function! MyFileformat()
    return winwidth(0) > 70 ? &fileformat : ''
endfunction
function! MyFiletype()
    return winwidth(0) > 70 ? (strlen(&filetype) ? &filetype : 'no ft') : ''
endfunction
function! MyFileencoding()
    return winwidth(0) > 70 ? (strlen(&fenc) ? &fenc : &enc) : ''
endfunction
function! MyMode()
    return winwidth(0) > 60 ? lightline#mode() : ''
endfunction

augroup PrevimSettings
    autocmd!
    autocmd BufNewFile,BufRead *.{md,mdwn,mkd,mkdn,mark*} set filetype=markdown
augroup END
nmap - <Plug>(choosewin)
let g:choosewin_overlay_enable = 1
nnoremap <C-c> :call ToggleCase()<cr>

nnoremap s <Nop>
nnoremap sj <C-w>j
nnoremap sk <C-w>k
nnoremap sl <C-w>l
nnoremap sh <C-w>h
nnoremap sJ <C-w>J
nnoremap sK <C-w>K
nnoremap sL <C-w>L
nnoremap sH <C-w>H
nnoremap sn gt
nnoremap sp gT
nnoremap sr <C-w>r
nnoremap s= <C-w>=
nnoremap sw <C-w>w
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap sT :<C-u>Unite tab<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sq :<C-u>q<CR>
nnoremap sw :<C-u>w<CR>
nnoremap sQ :<C-u>bd<CR>
nnoremap sb :<C-u>Unite buffer_tab -buffer-name=file<CR>
nnoremap sB :<C-u>Unite buffer -buffer-name=file<CR>
