" Copy every yank to the OS clipboard using Vim's native integration or an
" external tool; do not use Neovim-only g:clipboard settings in Vim.
let s:copy = ''
let s:paste = ''
let s:clipboard_warning_shown = v:false
if executable('win32yank.exe') || executable('win32yank')
  let s:exe = executable('win32yank.exe') ? 'win32yank.exe' : 'win32yank'
  let s:copy = s:exe . ' -i --crlf'
  let s:paste = s:exe . ' -o --lf'
elseif has('mac') || has('macunix') || executable('pbcopy')
  if executable('pbcopy') && executable('pbpaste')
    let s:copy = 'pbcopy'
    let s:paste = 'pbpaste'
  endif
elseif !empty($WAYLAND_DISPLAY) && executable('wl-copy') && executable('wl-paste')
  let s:copy = 'wl-copy'
  let s:paste = 'wl-paste --no-newline'
elseif !empty($DISPLAY) && executable('xclip')
  let s:copy = 'xclip -selection clipboard'
  let s:paste = 'xclip -selection clipboard -o'
endif
if has('clipboard') && (has('gui_running') || has('mac') || has('macunix') || !empty($DISPLAY))
  set clipboard+=unnamedplus
endif
function! s:WriteClipboard(text, regtype, quiet) abort
  if !empty(s:copy)
    call system(s:copy, a:text)
    if v:shell_error
      if !a:quiet
        echoerr 'Clipboard copy command failed'
      endif
      return v:false
    endif
  elseif has('clipboard') && (has('gui_running') || !empty($DISPLAY) || has('macunix'))
    call setreg('+', a:text, a:regtype)
  else
    if !a:quiet
      echoerr 'Clipboard unavailable: install win32yank, wl-clipboard or xclip, or use terminal copy'
    elseif !s:clipboard_warning_shown
      echohl WarningMsg
      echom 'Clipboard unavailable: install win32yank, wl-clipboard or xclip, or use terminal copy'
      echohl None
      let s:clipboard_warning_shown = v:true
    endif
    return v:false
  endif
  return v:true
endfunction
function! s:Copy(first, last) abort
  let l:text = join(getline(a:first, a:last), "\n") . "\n"
  call s:WriteClipboard(l:text, 'V', v:false)
endfunction
function! s:CopyYank() abort
  if get(v:event, 'operator', '') !=# 'y' || get(v:event, 'regname', '') ==# '_'
    return
  endif
  let l:contents = get(v:event, 'regcontents', [])
  let l:regtype = get(v:event, 'regtype', 'v')
  let l:text = join(l:contents, "\n")
  if l:regtype ==# 'V'
    let l:text .= "\n"
  endif
  call s:WriteClipboard(l:text, l:regtype, v:true)
endfunction
function! s:Paste() abort
  if !&modifiable
    echoerr 'Buffer is not modifiable'
    return
  endif
  if !empty(s:paste)
    let l:text = system(s:paste)
    if v:shell_error
      echoerr 'Clipboard paste command failed'
      return
    endif
  elseif has('clipboard') && (has('gui_running') || !empty($DISPLAY) || has('macunix'))
    let l:text = getreg('+')
  else
    echoerr 'Clipboard unavailable; use terminal paste'
    return
  endif
  " Only normalize CRLF from the clipboard, never unrelated buffer lines.
  let l:text = substitute(l:text, '\r\n', "\n", 'g')
  let l:lines = split(l:text, "\n", 1)
  if !empty(l:lines) && l:lines[-1] ==# ''
    call remove(l:lines, -1)
  endif
  call append(line('.'), l:lines)
endfunction
command! -range ClipboardCopy call <SID>Copy(<line1>, <line2>)
command! ClipboardPaste call <SID>Paste()
augroup personal_vim_clipboard
  autocmd!
  autocmd TextYankPost * call <SID>CopyYank()
augroup END
