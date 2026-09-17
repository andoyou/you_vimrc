new
call setline(1, ['original', 'copy me'])
normal! gg0yw
call assert_equal(['original'], readfile($CLIPBOARD_TEST_COPY))
call assert_equal(8, getfsize($CLIPBOARD_TEST_COPY))
normal! gg0yy
call assert_equal(['original'], readfile($CLIPBOARD_TEST_COPY))
call assert_equal(9, getfsize($CLIPBOARD_TEST_COPY))
execute 'normal! G0"ayy'
call assert_equal(['copy me'], readfile($CLIPBOARD_TEST_COPY))
2ClipboardCopy
call assert_equal(['copy me'], readfile($CLIPBOARD_TEST_COPY))
call cursor(1, 1)
ClipboardPaste
call assert_equal(['original', 'alpha', 'beta', 'copy me'], getline(1, '$'))
if !empty(v:errors)
  call writefile(v:errors, $VIM_TEST_ERRORS)
  cquit
endif
qa!
