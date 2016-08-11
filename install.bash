#!/bin/bash

sourcedir=$(echo "$PWD")
symtarget="$HOME"

# Helper functions
if [ -f "$sourcedir/dotbin.symlink/colors.bash" ] 
then
	echo "loading colors.bash"
	source "$sourcedir/dotbin.symlink/colors.bash"
else
	echo "Warning. Colors.bash could not be found"
fi

function success {
	if [ ! -z "${GREEN}" ]
	then
		echo -e "${GREEN}OK${NC}: $1"
	fi
}

function fail {
	if [ ! -z "${RED}" ]
	then
		echo -e "${RED}FAIL${NC}: $1"
	fi
	exit
}

function info {
	if [ ! -z "${BLUE}" ]
	then
		echo -e "${BLUE}INFO${NC}: $1"
	fi
}

function warning {
	if [ ! -z "${YELLOW}" ]
	then
		echo -e "${YELLOW}WARNING${NC}: $1"
	fi
}

# See if vim is installed
function viminstall {
	vim=$(command -v vim 2>/dev/null) 
	if [ -d "$vim" ] || [ -f "$vim" ]
	then
		success "Vim installed"
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
		is_target_dotfile_repo=$(echo "$target" | grep "$sourcedir") # if the symlink of the current dotfile links to "*../dotfiles/*"

		if [ ! -z "$target" ] && [ "$target" == "$is_target_dotfile_repo" ] 
		then # match
			success "Unlinking $file which pointed to $target"
			unlink "$file"
		fi
	done

	popd 1>&2
}

function install_dot_file {
	# ln -s /path/to/existing/file /path/to/the/new/symlink
	# -h in if checks if it's a symbolic link

	dest="$1" # the pointed
	link="$2" # the pointer
	mode="$3"
	info "mode: $mode"

	if [ ! -z "$dest" ] || [ ! -z "$link" ]
	then	
		install=0
		skip=0
		backup=0

		if ! test -h "$link"
		then
			install=1
		fi


		if [ "$install" -eq 0 ]
		then
			sym_link=$(readlink "$link") 
			if [ "$sym_link" == "$dest" ] # would an installation point to the same as existing?
			then
				info "Skipping '$link' because the existing link would link to same post-install"
				skip=1
			fi

			if [ "$skip" -eq 0 ]
			then
				info "There seems like '$link' is already a symbolic link and does not link to ${sourcedir}. What would you like to do?"
				info "[o] overwrite(remove old) [s] skip [a] abort [b] backup(backup old and create new)"

				read -n1 ans
				echo ""

				case $ans in 
					o)
						install=1				
					;;
					a)
						fail "Aborted"
					;;
					s)
						info "skipped"
						skip=1
					;;
					b)
						backup=1
						intsall=1
					;;

				esac
			fi
		fi

		if [ "$backup" -eq 1 ]
		then
			if [ -f "${link}.backup${iterator}" ]
			then
				iterator=0
				while [ ! -f "${link}.backup${iterator}" ]
				do
					iterator=$((iterator+=1))
				done
				if [ -f "${link}.backup${iterator}" ]
				then
					mv "$link" "${link}.backup${iterator}"
					if [ -f "${link}.backup${iterator}" ]
					then
						success "backed up $link"

					fi
				fi
			else
				mv "$link" "${link}.backup"
				if [ -f "${link}.backup" ]
				then
					if [ -f "${link}.backup" ]
					then
						success "backed up $link"
					fi
				fi
			fi

			
		fi

		if [ "$mode" == "-c" ]
		then
			x=""
			echo "Do you want to install '$dest'? y/n"
			read -n 1 x
			echo ""
			if [ "$x" == "n" ]
			then
				install=0
			fi
		fi

		if [ "$install" -eq 1 ]
		then
			k=$(ln -sf $dest $link 2>&1)
			if [ -z "$k" ]
			then
				success "Created symbolic link '$link' which points to '$dest'" 
			else 
				info "Error setting the symbolic link for '$dest' which would point to '$link'"
				info "Error msg:$k"
			fi
		fi
	else 
		info "else hit"
	fi
}

function install_files
{
	mode=""
	if [ "$1" == "-f" ]
	then
		mode="-f"
	elif [ "$1" == "-c" ]
	then
		mode="-c"
	fi


	viminstall # See if vim is installed, if not try to install it

	# General dotfile case
	sources=$(find -H "$sourcedir" -maxdepth 2 -name "*.symlink" -not -path '*.git*')
	if [ ! -z "$sources" ]
	then
		for src in $sources
		do
			file=$(basename "$src" | sed "s/\.symlink$//") # sed to remove .symlink
			#echo "$src => $symtarget/.$file"
			install_dot_file "$src" "$symtarget/.$file" "$mode"
		done
	else
		warning "No sources in $sourcedir"
	fi
}

function setup_git_credentials
{
	force=$1
	git_local="gitconfig.local.symlink"
	git_local_path="$sourcedir/git/$git_local"

	git_local_sample="gitconfig.local.sample"
	git_local_sample_path="$sourcedir/git/$git_local_sample"

	if  [ ! -f "$git_local_path" ] || [ "$force" == "-f" ]
	then
		if [ -f "$git_local_sample_path" ]
		then
			name=""
			email=""

			info "Setting up git credentials"
			info "What is your name? First and last name."
			read -e name

			info "What is your email?"
			read -e email

			# replace 
			# "name = " with "name = $name"
			# and
			# "email = " with "email = $email"
			# into a new file called .gitconfig.local

			cp "$git_local_sample_path" "$git_local_path"
			line=$(cat "$git_local_path" | sed "s/name\s*\=/name\ \=\ $name/g")
			echo "$line" > "$git_local_path"

			line=$(cat "$git_local_path" | sed "s/email\s*\=/email\ \=\ $email/g")
			echo "$line" > "$git_local_path"

			success "gitconfig.local initialized"
		else 
			info "Skipped making git credentials becase the sample file could not be found"
		fi
	else
		info "Skipped making git credentials because either a gitconfig.local existed"
	fi
}

function test_dependencies
{
	# Tests dependencies
	entries="basename readlink dirname"

	for entry in $entries
	do
		cmd=$(which $entry)
		fail_msg="cmd '$entry' does not exist"
		success_msg="cmd '$entry' exist"

		line=$(which readlink)

		if [ -z "$cmd" ]
		then
			fail "$fail_msg"
		else
			success  "$success_msg"
		fi
	done

	# test colors.bash sourcing
	if [ -f "$sourcedir/dotbin.symlink/colors.bash" ] 
	then
		success "colors.bash"
	else
		fail "Warning. colors.bash could not be found"
	fi

}

function test_shell
{
	this_shell=$(echo $SHELL)
	case "$this_shell" in
	"/bin/bash")
		success "bash is supported for installation"
	;;
	"/bin/zsh")
		info "zsh has not been tested for installation"
	;;
	"/bin/fish")
		info "fish has not been tested for installation"
	;;
	"/bin/tcsh")
		info "tcsh has not been tested for installation"
	;;
	"/bin/csh")
		info "csh has not been tested for installation"
	;;
	"/bin/sh")
		info "sh has not been tested for installation"
	;;
	esac
}




## MAIN
if [ "$1" == "-f" ] 
then
	info "Forcfully installing. This action might remove old dotfiles on your system. Proceed? [y/n]"
	read -r p
	if [ "$p" == "y" ]
	then
		install_files "-f"	
	else
		info "Aborting"
	fi
elif [ "$1" == "--test" ]
then
	test_dependencies
	test_shell
elif [ "$1" == "-u" ]
then
	uninstall_dot_file
elif [ "$1" == "-c" ]
then
	install_files "-c"	
else
	setup_git_credentials
	install_files
fi
