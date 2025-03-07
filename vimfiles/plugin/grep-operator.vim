" Code for the Grep operator (doesn't work on Windows)

nnoremap <leader>g :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <leader>g :<c-u>call <SID>GrepOperator(visualmode())<cr>

function! s:GrepOperator(type)
	let saved_unnamed_register = @@

	if a:type ==# 'v'
		execute "normal! `<v`>y"
	elseif a:type ==# 'char'
		execute "normal! `[v`]y"
	else
		return
	endif

	if has('win32')
		" Syntax and escaping are different for powershell's Select-String I'm using
		" for grepprg on Windows.
		silent execute "grep! '" . substitute(substitute(@@, "'", "''", "g"), '"', '""""', 'g') . "' *.*,**/*.*"
	else
		silent execute "grep! -R " . shellescape(@@) . " ."
	endif
	copen 15
	redraw!

	let @@ = saved_unnamed_register
endfunction
