#!/bin/bash


# See if vim is installed
function viminstall {
	vim=$(command -v vim 2>/dev/null) 
	if [ -d "$vim" ] || [ -f "$vim" ]
	then
		echo "Vim installed"
	else
		echo "Vim not installed"
		echo "Trying to install vim for debian-like systems(apt-get)"
		sudo apt-get install vim
	fi
}

function createsymlink {
	# ln -s /path/to/existing/file /path/to/the/new/symlink
	# -h in if checks if it's a symbolic link

	if [ ! -z "$1" ] || [ ! -z "$2" ]
	then
		dest="$1"
		link="$2"
		if [ ! -h "$link" ] # If there is currently a symbolic link
		then
			name=$(basename "$link")
			existing_path=$(ls ~ -al | grep "$name" | awk '{print $11}')
			if [ "$existing_path" != "$dest" ] # Does the symlink's target differ?
			then
				k=$(ln -sf $dest $link 2>&1)
				if [ -z "$k" ]
				then
					echo "Created symbolic link '$dest' which points to '$link'" 
				else 
					echo "Error setting the symbolic link for $dest"
				fi
			fi
		fi
	fi
}

viminstall # See if vim is installed, if not try to install it

sourcedir="$HOME/dotfiles"
symtarget="$HOME"

dest="$sourcedir/.vim"
link="$symtarget/.vim"
createsymlink "$dest" "$link"

dest="$sourcedir/.vimrc"
link="$symtarget/.vimrc"
createsymlink "$dest" "$link"
