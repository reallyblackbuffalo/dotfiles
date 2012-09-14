" Wayne Robison
" Personalized vimrc file
" 14 Sep 2011

" Set to work with the Vim-related packages available in Debian.
" (No error if not in Debian)
runtime! debian.vim

set nocompatible " Use Vim default settings.

set backspace=indent,eol,start " allow backspacing over everything in insert mode
set ruler   " show the cursor position all the time
set laststatus=2

" Tab Settings
set tabstop=4
set shiftwidth=4
set expandtab

if has("vms")
    set nobackup      " do not keep a backup file, use versions instead
else
    set backup        " keep a backup file
endif

set history=50  " keep 50 lines of command line history
set showcmd " display incomplete commands
set showmatch   " Show matching brackets.
set ignorecase  " Do case insensitive matching
set smartcase   " Do smart case matching
"set incsearch  " Do incremental searching
set hidden  " Hide buffers when they are abandoned

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" Switch syntax highlighting on.
syntax on
set number

" Set things up for the list setting, which shows invisible things like tabs
" and eol, etc.
set listchars=eol:$,tab:>-
noremap <F6> :set list!<CR>

" Switch on highlighting the last used search pattern.
set hlsearch
" Press Space to turn off highlighting and clear any message already
" displayed.
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>
" Press F4 to toggle highlighting on/off, and show current value.
noremap <F4> :set hlsearch! hlsearch?<CR>
" Press F8 to highlight all occurrences of the current word.
noremap <F8> :let @/='\<<C-R>=expand("<cword>")<CR>\>'<CR>:set hls<CR>

set t_Co=256
colors wombat256

" Set gui specific settings (could go in a gvimrc file)
if has("gui_running")
    if has("gui_gtk2")
        set guifont=Inconsolata\ 12
    elseif has("gui_win32")
        set guifont=Inconsolata:h12
    endif
    set columns=90
    set lines=40
    set winaltkeys=no
endif

" Turn off the confounded beeping.
set noerrorbells visualbell t_vb=

" Only do this part when compiled with support for autocommands.
if has("autocmd")

    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on

    " Put these in an autocmd group, so that we can delete them easily.
    augroup vimrcEx
        au!

        " For all text files set 'textwidth' to 78 characters.
        autocmd FileType text setlocal textwidth=78

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid or when inside an event handler
        " (happens when dropping a file on gvim).
        " Also don't do it when the mark is in the first line, that is the default
        " position when opening a file.
        autocmd BufReadPost *
                    \ if line("'\"") > 1 && line("'\"") <= line("$") |
                    \   exe "normal! g`\"" |
                    \ endif

    augroup END

    " Turn off the confounded beeping.
    autocmd GUIEnter * set visualbell t_vb=

else

    set autoindent        " always set autoindenting on

endif " has("autocmd")

" configure tags - add additional tags here or comment out not-used ones
"set tags+=~/.vim/tags/cpp_tags
"set tags+=~/.vim/tags/c_tags
"set tags+=~/.vim/tags/gl
"set tags+=~/.vim/tags/sdl
"set tags+=~/.vim/tags/qt4
" build tags of your own project with Ctrl-F12
map <C-F12> :!ctags -R --sort=yes --c++-kinds=+p --fields=+iaS --extra=+q .<CR>

" OmniCppComplete
let OmniCpp_NamespaceSearch = 1
let OmniCpp_GlobalScopeSearch = 1
let OmniCpp_ShowAccess = 1
let OmniCpp_ShowPrototypeInAbbr = 1 " show function parameters
let OmniCpp_MayCompleteDot = 1 " autocomplete after .
let OmniCpp_MayCompleteArrow = 1 " autocomplete after ->
let OmniCpp_MayCompleteScope = 1 " autocomplete after ::
let OmniCpp_DefaultNamespaces = ["std", "_GLIBCXX_STD"]
" automatically open and close the popup menu / preview window
au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
set completeopt=menuone,menu,longest,preview
