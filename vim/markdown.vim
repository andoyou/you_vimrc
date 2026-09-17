" Open the saved Markdown file with the OS default browser/handler.
function! s:IsWsl() abort
  return !has('win32') && filereadable('/proc/version')
        \ && join(readfile('/proc/version'), "\n") =~? 'microsoft\|wsl'
endfunction

function! s:BrowserCommand(path) abort
  if has('mac') || has('macunix')
    return executable('open') ? ['open', '--', a:path] : []
  endif
  if s:IsWsl()
    if executable('wslview')
      return ['wslview', a:path]
    endif
    if executable('wslpath') && executable('powershell.exe')
      let l:windows_path = trim(systemlist(['wslpath', '-w', '--', a:path])[0])
      if v:shell_error || empty(l:windows_path)
        return []
      endif
      " PowerShell single quotes are escaped by doubling them; LiteralPath avoids
      " wildcard expansion and job_start avoids a shell command string.
      let l:literal_path = substitute(l:windows_path, "'", "''", 'g')
      return ['powershell.exe', '-NoProfile', '-NonInteractive', '-Command',
            \ "Start-Process -LiteralPath '" . l:literal_path . "'"]
    endif
    return []
  endif
  if has('win32') || has('win64')
    return executable('powershell.exe')
          \ ? ['powershell.exe', '-NoProfile', '-NonInteractive', '-Command',
          \    "Start-Process -LiteralPath '" . substitute(a:path, "'", "''", 'g') . "'"]
          \ : []
  endif
  return executable('xdg-open') ? ['xdg-open', a:path] : []
endfunction

function! s:OpenMarkdown() abort
  let l:path = expand('%:p')
  let l:extension = tolower(expand('%:e'))
  if &filetype !=# 'markdown' && index(['md', 'markdown', 'mdown', 'mkdn', 'mdwn', 'mark'], l:extension) < 0
    echoerr 'MarkdownOpen is available only for Markdown files'
    return
  endif
  if empty(l:path)
    echoerr 'MarkdownOpen requires a file on disk'
    return
  endif
  if &modified
    echoerr 'Save the Markdown file before opening it in a browser'
    return
  endif
  let l:command = s:BrowserCommand(l:path)
  if empty(l:command)
    echoerr 'No supported browser opener: install wslu, xdg-utils, or use a GUI browser'
    return
  endif
  let l:job = job_start(l:command, {'out_io': 'null', 'err_io': 'null'})
  " Vim 8 returns a Number, while Vim 9 returns a Job object.
  if type(l:job) == v:t_number && l:job <= 0
    echoerr 'Could not start the default browser'
  endif
endfunction

command! MarkdownOpen call <SID>OpenMarkdown()
