call assert_equal(0, &compatible)
call assert_equal(4, &shiftwidth)
call assert_equal(':<C-U>w<CR>', maparg('sw', 'n'))
call assert_equal('', maparg('<C-c>', 'n'))
call assert_equal('<C-W>w', maparg('-', 'n'))
call assert_equal(2, exists(':ClipboardCopy'))
call assert_equal(2, exists(':NERDTreeToggle'))
call assert_equal('1989', get(g:, 'colors_name', ''))
execute 'source ' . fnameescape(g:personal_vim_root . '/vimrc')
execute 'source ' . fnameescape(g:personal_vim_root . '/vimrc')
let s:events = execute('autocmd PersonalFiletypes')
call assert_equal(1, len(filter(split(s:events, "\n"), 'v:val =~# "^    css "')))
new test.js
call assert_equal('javascript', &filetype)
call assert_equal(2, &shiftwidth)
call assert_equal(2, &softtabstop)
NERDTreeToggle
call assert_equal('nerdtree', &filetype)
NERDTreeClose
if !empty(v:errors)
  call writefile(v:errors, $VIM_TEST_ERRORS)
  cquit
endif
qa!
