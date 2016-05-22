" Syntax 
syntax on

" Looks
set background=dark

set relativenumber
set number

" Font
if has("gui_running")
	if has("gui_gtk2")
		set guifont=Inconsolata\ 12
	elseif has("gui_macvim")
		set guifont=Menlo\ Regular:h14
	elseif has("gui_win32")
		  set guifont=Consolas:h11:cANSI
	endif
endif

" Remaps
map ^C esc 

" Tab
set autoindent
set smartindent
set tabstop=4 
set shiftwidth=4
set softtabstop=4
set noexpandtab

" Language
set langmenu=en_US
