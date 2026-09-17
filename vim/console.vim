" Open an interactive Codex or Claude CLI in a split next to the current buffer.
function! s:ConsoleDirections(arglead, cmdline, cursorpos) abort
  return filter(['up', 'down', 'right', 'left'], 'stridx(v:val, a:arglead) == 0')
endfunction

function! s:OpenConsole(program, direction) abort
  if !has('terminal') || !exists('*term_start')
    echoerr 'This Vim build does not support terminal buffers'
    return
  endif
  if type(a:program) != v:t_string || empty(a:program) || !executable(a:program)
    echoerr 'Console command is not executable: ' . string(a:program)
    return
  endif
  let l:splits = {
        \ 'up': 'aboveleft new',
        \ 'down': 'belowright new',
        \ 'right': 'belowright vertical new',
        \ 'left': 'aboveleft vertical new',
        \ }
  if !has_key(l:splits, a:direction)
    echoerr 'Direction must be one of: up, down, right, left'
    return
  endif
  execute l:splits[a:direction]
  let l:job = term_start([a:program], {'curwin': v:true})
  if type(l:job) == v:t_number && l:job <= 0
    echoerr 'Could not start console command: ' . a:program
    return
  endif
  startinsert
endfunction

if !exists('g:personal_codex_command')
  let g:personal_codex_command = 'codex'
endif
if !exists('g:personal_claude_command')
  let g:personal_claude_command = 'claude'
endif

command! -nargs=1 -complete=customlist,<SID>ConsoleDirections CodexConsole
      \ call <SID>OpenConsole(g:personal_codex_command, <q-args>)
command! -nargs=1 -complete=customlist,<SID>ConsoleDirections ClaudeConsole
      \ call <SID>OpenConsole(g:personal_claude_command, <q-args>)
