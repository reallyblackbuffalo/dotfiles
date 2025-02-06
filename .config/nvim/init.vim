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

" Abbreviation for email address.
iabbrev @@ myemail@example.com
