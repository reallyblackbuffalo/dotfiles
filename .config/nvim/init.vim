" Print friendly ASCII-art cat whenever I open Vim.
echo ">^.^<"

" Turn on relative line numbers.
set number relativenumber

" Set leader and local leader.
let mapleader = " "
let maplocalleader = "\\"

" Mappings for moving the current line down or up.
noremap <leader>- ddp
noremap <leader>_ ddkP

" Mappings for uppercasing the current word in insert and normal modes.
inoremap <leader><c-u> <esc>viwUea
nnoremap <leader><c-u> viwU
