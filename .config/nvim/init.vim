" Print friendly ASCII-art cat whenever I open Vim.
echo ">^.^<"

" Turn on relative line numbers.
set number relativenumber

" Set leader and local leader.
let mapleader = " "
let maplocalleader = "\\"

" Mappings for moving the current line down or up.
nnoremap <leader>- ddp
nnoremap <leader>_ ddkP

" Mappings for uppercasing the current word in insert and normal modes.
inoremap <c-u> <esc>viwUea
nnoremap <leader><c-u> viwU

" Mappings to open and source config file
nnoremap <leader>ev :vsplit $MYVIMRC<cr>
nnoremap <leader>sv :source $MYVIMRC<cr>

" Mappings for surrounding the current word (or selection) with quotes.
nnoremap <leader>" viw<esc>a"<esc>bi"<esc>lel
nnoremap <leader>' viw<esc>a'<esc>bi'<esc>lel
vnoremap <leader>" <esc>`>a"<esc>`<i"<esc>lel
vnoremap <leader>' <esc>`>a'<esc>`<i'<esc>lel

" Mappings for going to the beginning and end of the line. (Not sure yet if I
" like these enough to give up the original functions of H and L)
nnoremap H 0
nnoremap L $

" Operator-pending mappings
onoremap in( :<c-u>normal! f(vi(<cr>
onoremap il( :<c-u>normal! F)vi(<cr>
onoremap an( :<c-u>normal! f(va(<cr>
onoremap al( :<c-u>normal! F)va(<cr>
onoremap in{ :<c-u>normal! f{vi{<cr>
onoremap il{ :<c-u>normal! F}vi{<cr>
onoremap an{ :<c-u>normal! f{va{<cr>
onoremap al{ :<c-u>normal! F}va{<cr>

" Abbreviation for email address.
iabbrev @@ myemail@example.com

" Autocommands for commenting out the current line in different languages.
augroup filetype_comment_mappings
	autocmd!
	autocmd FileType javascript,c,cpp,java nnoremap <buffer> <localleader>c I//<esc>
	autocmd FileType javascript,c,cpp,java vnoremap <buffer> <localleader>c :normal I//<esc>
	autocmd FileType python nnoremap <buffer> <localleader>c I#<esc>
	autocmd FileType python vnoremap <buffer> <localleader>c :normal I#<esc>
	autocmd FileType vim nnoremap <buffer> <localleader>c I"<esc>
	autocmd FileType vim vnoremap <buffer> <localleader>c :normal I"<esc>
augroup END

" Autocommands to set snippet-like abbreviations for different file types.
augroup filetype_snippet_abbreviations
	autocmd!
	autocmd FileType javascript,c,cpp,java iabbrev <buffer> iff if ()<left>
	autocmd FileType python iabbrev <buffer> iff if:<left>
	autocmd FileType javascript,c,cpp,java,python iabbrev <buffer> ret return
	autocmd FileType javascript,c,cpp,java,python iabbrev <buffer> return NOPENOPENOPE
	autocmd FileType javascript iabbrev <buffer> fn function
	autocmd FileType javascript iabbrev <buffer> function NOPENOPENOPE
augroup END

" Autocommand for folding the current tag in an html file.
augroup filetype_html
	autocmd!
	autocmd FileType html nnoremap <buffer> <localleader>f Vatzf
augroup END
