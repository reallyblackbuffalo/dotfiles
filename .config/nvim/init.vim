" Print friendly ASCII-art cat whenever I open Vim.
echo ">^.^<"

" Turn on relative line numbers.
set number relativenumber

" Mappings for moving the current line down or up.
noremap - ddp
noremap _ ddkP

" Mappings for uppercasing the current word in insert and normal modes.
inoremap <c-u> <esc>viwUea
nnoremap <c-u> viwU
