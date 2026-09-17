let g:personal_codex_command = 'mock-codex'
CodexConsole right
call assert_equal('terminal', &buftype)
call assert_equal(2, winnr('$'))
call assert_equal(1, winnr('h'))
call job_stop(term_getjob(bufnr('%')))
stopinsert
close!
if !empty(v:errors)
  call writefile(v:errors, $CONSOLE_TEST_ERRORS)
  cquit
endif
qa!
