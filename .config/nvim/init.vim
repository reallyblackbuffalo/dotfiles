" Print Welcome Message ---------------------- {{{

" Print friendly ASCII-art cat whenever I open Vim.
echo ">^.^<"

" }}}

" Basic Settings ---------------------- {{{

" Turn on relative line numbers.
set number relativenumber

" Search settings
set hlsearch incsearch

if has('win32')
	" Windows defaults to using findstr for grep, which doesn't work the
	" greatest. I specifically was running into issues where redirecting
	" the output to a file (like what the Neovim grep command does)
	" doesn't work when the search term includes a double quote that has
	" to be escaped properly.
	" Use powershell's Select-String instead (though it takes a bit more
	" setup).
	let &grepprg = 'powershell -Command "Select-String $* \| Out-String -Stream \| Where { $_ -ne '''' }"'
endif

" }}}

" Custom status line ---------------------- {{{
set statusline=%f		" Filename/relative path
set statusline+=%(\ %m%h%w%r%)	" Flags
set statusline+=\ %y		" Filetype
set statusline+=%=		" Switch to right side
set statusline+=%-14(%l,%c%V%)	" Ruler line and column
set statusline+=\ %P		" Ruler percentage
" }}}

" Set leader and local leader. ---------------------- {{{
let mapleader = " "
let maplocalleader = "\\"
" }}}

" Mappings ---------------------- {{{

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

" Open the previous buffer in a split to the left.
nnoremap <leader>op :execute "leftabove vsplit" bufname("#")<cr>

" Highlight trailing whitespace as an error.
nnoremap <silent> <leader>w :match Error /\v\S\zs\s+$/<cr>

" Clear the trailing whitespace highlighting.
nnoremap <silent> <leader>W :match<cr>

" Automatically turn on "very magic" mode when beginning a search.
nnoremap / /\v
nnoremap ? ?\v

" Clear search highlighting
nnoremap <silent> <leader><space> :nohlsearch<cr>

" Mappings for going to the next and previous matches in the quickfix list.
nnoremap <leader>n :cnext<cr>
nnoremap <leader>p :cprevious<cr>

" }}}

" Operator-pending mappings ---------------------- {{{
onoremap in( :<c-u>normal! f(vi(<cr>
onoremap il( :<c-u>normal! F)vi(<cr>
onoremap an( :<c-u>normal! f(va(<cr>
onoremap al( :<c-u>normal! F)va(<cr>
onoremap in{ :<c-u>normal! f{vi{<cr>
onoremap il{ :<c-u>normal! F}vi{<cr>
onoremap an{ :<c-u>normal! f{va{<cr>
onoremap al{ :<c-u>normal! F}va{<cr>
onoremap in@ :<c-u>execute "normal! /\\(\\w\\<bar>[.%+-]\\)\\+@\\(\\a\\<bar>\\d\\<bar>[.-]\\)\\+\\.\\a\\{2,}\r:nohlsearch\rvt@"<cr>
" }}}

" Abbreviations ---------------------- {{{

" Abbreviation for email address.
iabbrev @@ myemail@example.com

" }}}

" FileType-specific Mappings ---------------------- {{{

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

" Autocommand for folding the current tag in an html file.
augroup filetype_html
	autocmd!
	autocmd FileType html nnoremap <buffer> <localleader>f Vatzf
augroup END

" }}}

" FileType-specific Abbreviations ---------------------- {{{

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

" }}}

" FileType-specific Operator-pending Mappings ---------------------- {{{

" Autocommands for setting operator-pending mappings for markdown files.
augroup filetype_markdown_mappings
	autocmd!
	autocmd FileType markdown onoremap <buffer> ih :<c-u>execute "normal! ?^\\(=\\{2,}\\<bar>-\\{2,}\\)$\r:nohlsearch\rkvg_"<cr>
	autocmd FileType markdown onoremap <buffer> ah :<c-u>execute "normal! ?^\\(=\\{2,}\\<bar>-\\{2,}\\)$\r:nohlsearch\rg_vk0"<cr>
augroup END

" }}}

" Vimscript file settings ---------------------- {{{
augroup filetype_vim
	autocmd!
	autocmd FileType vim setlocal foldmethod=marker
augroup END
" }}}
