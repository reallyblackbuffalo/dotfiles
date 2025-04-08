" Bootstrap vim-plug installation
let s:uservimdir = fnamemodify($MYVIMRC, ':p:h')
let s:vimplug_path = s:uservimdir .. '/autoload/plug.vim'
if empty(glob(s:vimplug_path))
  echo "vim-plug not found, downloading..."
  silent execute '!curl -fLo ' .. s:vimplug_path .. ' --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  if empty(glob(s:vimplug_path))
    echoerr "Failed to download vim-plug! Please check your internet connection or curl installation."
	echo "Press any key to exit..."
	call getchar()
	cquit!
  else
	  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
endif

call plug#begin()

Plug 'preservim/nerdtree'
Plug 'wlangstroth/vim-racket'

call plug#end()
