" Syntax 
syntax on

" Looks
set background=dark

" When re opening file, return to the latest known line
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

" Line numbers
set relativenumber
set number

" Font
if has("gui_running")
	if has("gui_gtk2")
		set guifont=Inconsolata\ 12
	elseif has("gui_macvim")
		set guifont=Menlo\ Regular:h14
	elseif has("gui_win32")
		  set guifont=Monaco:h11:cANSI
	endif
endif

" Maps
nmap :W :w
nmap :Q :q

" Remaps
map ^C esc 

" Status line
set laststatus=2

" Tab
set autoindent
set smartindent
" There is a bug where printing a # sign when inside insert mode produces no ident. This fixes it. http://vim.wikia.com/wiki/Restoring_indent_after_typing_hash
set cindent
set cinkeys-=0#
set indentkeys-=0#
" Stop fix
set tabstop=4 
set shiftwidth=4
set softtabstop=4
set noexpandtab

" Language
set langmenu=en_US

" Search
set hlsearch

" Sound. Vim please be quiet. Looking at you, GVim
set noerrorbells
set vb t_vb=
autocmd GUIENTER * set vb t_vb=