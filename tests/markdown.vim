execute 'edit ' . fnameescape($MARKDOWN_TEST_FILE)
setfiletype markdown
MarkdownOpen
sleep 200m
call assert_equal(['-NoProfile', '-NonInteractive', '-Command', "Start-Process -LiteralPath 'C:\\mock\\document.md'"], readfile($MARKDOWN_TEST_COMMAND))
if !empty(v:errors)
  call writefile(v:errors, $VIM_TEST_ERRORS)
  cquit
endif
qa!
