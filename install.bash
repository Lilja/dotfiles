#!/bin/bash

sourcedir="$HOME/dotfiles"
symtarget="$HOME"

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

function uninstall_dot_file
{
	pushd "$symtarget"
	var=$(ls -al | awk '{print $9}' | grep  "^\." | tail -n+3) # there might be a better way to do this. ls -al, get $9(file names) grep for a dot in the begining

	target=""
	for file in $var
	do
		target=$(ls -al "$file" | awk '{print $11}')
		is_target_dotfile_repo=$(echo "$target" | grep "$sourcedir")

		if [ ! -z "$target" ] && [ "$target" == "$is_target_dotfile_repo" ] 
		then
			echo "unlinking $file which pointed to $target"
			unlink "$file"
		fi
	done

	popd 1>&2
}

function install_dot_file {
	# ln -s /path/to/existing/file /path/to/the/new/symlink
	# -h in if checks if it's a symbolic link

	dest="$1"
	link="$2"
	force="$3"

	if [ ! -z "$dest" ] || [ ! -z "$dest" ]
	then	

		if [ ! -h "$link" ] || [ ! -z "$force" ] # If there isn't currently a symbolic link, or forcefully create one
		then
			name=$(basename "$link")
			existing_path=$(ls ~ -al | grep "$name" | awk '{print $11}')
			if [ "$existing_path" != "$dest" ] # Does the symlink's target differ?
			then
				k=$(ln -sf $dest $link 2>&1)
				if [ -z "$k" ]
				then
					echo "Created symbolic link '$link' which points to '$dest'" 
				else 
					echo "Error setting the symbolic link for $dest"
				fi
			fi
		fi
	fi
}

function install_files
{
	force=""
	if [ "$1" == "-f" ]
	then
		echo "force fully install matched"
		force="-f"
	fi


	viminstall # See if vim is installed, if not try to install it

	# General dotfile case
	directories="vim i3"
	for dir in $directories
	do
		dest="$sourcedir/$dir"
		link="$symtarget/.$dir"
		install_dot_file "$dest" "$link" "$force"

	done

	files="xinitrc vimrc gitconfig git-prompt.sh i3status.conf"
	for file in $files
	do
		dest="$sourcedir/$file"
		link="$symtarget/.$file"
		install_dot_file "$dest" "$link" "$force"

	done

	# Specific ones
	name="solarized_dark_high_contrast"
	if [ -d "$symtarget/.config/" ]
	then
		if [ -d "$symtarget/.config/xfce4/" ]
		then
			if [ -d "$symtarget/.config/xfce4/terminal/" ]
			then
				echo "copying file"
				cp "$sourcedir/terminal/$name" "$symtarget/.config/xfce4/terminal/terminalrc"
			else
				echo "no terminal folder, skipping."
			fi
		else
			echo "No xfce4 dir. Not installing terminal-emulator specific preset $name"
		fi
	fi
}

## MAIN
if [ "$1" == "-f" ] 
then
	echo "Forcfully installing. This action might remove old dotfiles on your system. Proceed? [y/n]"
	read -r p
	if [ "$p" == "y" ]
	then
		install_files "-f"	
	else
		echo "Aborting"
	fi
elif [ "$1" == "-u" ]
then
	uninstall_dot_file
else
	install_files
fi
