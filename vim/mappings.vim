" Keep the existing s-prefix workflow. sw has always effectively meant save.
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
nnoremap so <C-w>_<C-w>|
nnoremap sO <C-w>=
nnoremap sN :<C-u>bn<CR>
nnoremap sP :<C-u>bp<CR>
nnoremap st :<C-u>tabnew<CR>
nnoremap ss :<C-u>sp<CR>
nnoremap sv :<C-u>vs<CR>
nnoremap sq :<C-u>q<CR>
nnoremap sw :<C-u>w<CR>
nnoremap sQ :<C-u>bd<CR>
" Replace unavailable Unite commands with built-in interactive lists.
nnoremap sT :<C-u>tabs<CR>:tabnext<Space>
nnoremap sb :<C-u>ls<CR>:buffer<Space>
nnoremap sB :<C-u>ls!<CR>:buffer<Space>
" Previously unresolved choosewin mapping: cycle windows with Vim itself.
nnoremap - <C-w>w
" Ctrl-C is left to Vim; ToggleCase() was undefined. Use built-in ~ / g~.
