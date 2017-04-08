#!/bin/bash

sourcedir=$(echo "$PWD")
symtarget="$HOME"
visualfolder="visuals"

ININSTALL="-u"
INSTALL="-i"
AGREE="y"
ABORT="n"

# Helper functions
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
NC=$(tput sgr0)
BOLD=$(tput bold)

success() {
	[ ! -z "${GREEN}" ] && echo "${GREEN}OK${NC}: $1"
}

fail() {
	[ ! -z "${RED}" ] && echo "${RED}FAIL${NC}: $1"; exit
}

info() {
	[ ! -z "${BLUE}" ] && echo "${BLUE}INFO${NC}: $1"
}

warning() {
	[ ! -z "${YELLOW}" ] && echo "${YELLOW}WARNING${NC}: $1"
}

backup() {
	# Back up if the user wanted to.
	if [ $1 -eq 1 ]; then
		if [ -e "${2}.backup" ]; then
			iterator=0
			# if there already is a file with .backup0, .backup1 ... .backup[n] and so on, try to figure out if that number is incrementable.
			while [ -e "${2}.backup${iterator}" ]; do iterator=$((iterator+=1)); done

			echo "Backing up $2 to ${2}.backup${iterator}"
			mv "$2" "${2}.backup${iterator}"
		else
			echo "Backing up $2 to ${2}.backup"
			mv "$2" "${2}.backup"
		fi
	fi
}

prompt() {
	[ "$2" = "text" ] && printf "${MAGENTA}PROMPT${NC}: $1" || printf "${MAGENTA}PROMPT${NC}: $1 ($AGREE/$ABORT)"
}

read_char() {
	val=""; read -n1 val; echo $val
}

# See if vim is installed
viminstall() {
	vim=$(command -v vim 2>/dev/null)
	if [ -d "$vim" ] || [ -f "$vim" ]; then
		success "Vim installed"
	else
		info "Vim not installed"
	fi
}

install_dot_file() {
	# ln -s /path/to/existing/file /path/to/the/new/symlink
	# -h in if checks if it's a symbolic link

	dest="$1" # the pointed
	link="$2" # the pointer

	if [ ! -z "$dest" ] || [ ! -z "$link" ]; then
		destcopy="$(basename $dest)"
		sym_link="$(readlink $link)"

		# Pre-emptive check. Would an installation point to the same as existing?
		if [ "$sym_link" = "$dest" ]; then
			info "Skipping $sym_link"
		else
			if [ -d "$dest" ]
			then
				str="Do you want to install the directory ${BOLD}'$destcopy${NC}/'? ($valid more to go)"
			else
				str="Do you want to install the file ${BOLD}'$destcopy${NC}'? ($valid more to go)"
			fi


			prompt "$str"
			x=$(read_char)
			echo ""

			if [ $x = $AGREE ]; then
				[ -d "$link" ] || [ -f "$link" ] && backup 1 "$link";

				k="$(ln -sf $dest $link 2>&1)"
			fi
		fi
	fi
}

install_files()
{
	valid=0

	prompt "Install dotfiles?"
	x=$(read_char)
	echo ""

	if [ $x = $AGREE ]; then
		# Look for files that match *.symlink, loop through and see if we can install it.
		sources=$(find -H "$sourcedir" -maxdepth 2 -name "*.symlink" -not -path '*.git*' | grep -v "$visualfolder")

		if [ ! -z "$sources" ]; then
			# Do a simple count of every install-able. We want to later pass it so we could see "x remaining"
			for src in $sources
			do
				file=$(basename "$src" | sed "s/\.symlink$//") # sed to remove .symlink
				target="$symtarget/.$file"

				if [ "$target" != "$file" ]
				then
					# Installable, increase valid count
					valid=`expr $valid + 1`
				fi
			done
		fi

		# Install.
		# Look for files that match *.symlink, loop through and see if we can install it.
		if [ ! -z "$sources" ]; then
			for src in $sources
			do
				file=$(basename "$src" | sed "s/\.symlink$//") # sed to remove .symlink
				install_dot_file "$src" "$symtarget/.$file"
				# Decrease remaining count
				valid=`expr $valid - 1`
			done
		fi
	fi
}

setup_git_credentials()
{
	verbose=$1

	prompt "[GIT] Install git credentials?"
	install=$(read_char)
	echo ""

	if [ "$install" = $AGREE ]
	then
		[ -f "$sourcedir/gitconfig.local" ] && backup "$sourecdir/gitconfig.local";

		git_local="gitconfig.local.symlink"
		git_local_path="$sourcedir/git/$git_local"

		git_local_sample="gitconfig.local.sample"
		git_local_sample_path="$sourcedir/git/$git_local_sample"

		cp $git_local_sample_path $git_local_path

		prompt "What is your name? First and last name: " "text"
		read -r name

		prompt "What is your email?: " "text"
		read -r email

		prompt "Do you have an github alias? (n for not specified/skip): " "text"
		read -r git_alias

		sed -i "s#name\s*\=#name\ \=\ $name#g" "$git_local_path"

		sed -i "s#email\s*\=#email\ \=\ $email#g" "$git_local_path"

		if [ $git_alias != "n" ]; then
			sed -i "s#user\s*\=#user\ \=\ $git_alias#g" "$git_local_path"
		fi

		ln -sf $git_local_path ${symtarget}/.gitconfig.local
	fi
}

install_visuals()
{
	s=$symtarget
	sd=$sourcedir
	prompt "Do you want to install visuals?"
	ans=$(read_char)
	echo ""

		if [ "$ans" = $AGREE ]; then
		prompt "Do you want to ${BOLD}i3${NC}?"
		ans=$(read_char)
		echo ""

		if [ "$ans" = $AGREE ]; then
			test -d "${s}/.i3" || mkdir "${s}/.i3"
			install_dot_file "${sd}/visuals/i3/config"				"${s}/.i3/config"
			install_dot_file "${sd}/visuals/i3/i3status.conf"	"${s}/.i3/i3status.conf"
		fi

		prompt "Do you want to install ${BOLD}fonts${NC}?"
		ans=$(read_char)
		echo ""
		if [ "$ans" = $AGREE ]; then
			test -d "${s}/.fonts" || mkdir "${s}/.fonts"
			install_dot_file "${sd}visuals/fonts/*" "${s}/.fonts/"
		fi

		prompt "Do you want to install ${BOLD}icons${NC}?"
		ans=$(read_char)
		echo ""
		if [ "$ans" = $AGREE ]; then
			test -d "${s}/.icons" || mkdir "${s}/.icons"
			install_dot_file "${sd}visuals/icons/*" "${s}/.icons/"
		fi

		prompt "Do you want to install ${BOLD}xfce4-terminal-themes${NC}?"
		ans=$(read_char)
		echo ""
		if [ "$ans" = $AGREE ]; then
			test -d "${s}/.local/share/xfce4/terminal/colorschemes/" || mkdir -p "${s}/.local/share/xfce4/terminal/colorschemes/"
			install_dot_file "${sd}visuals/xfce4-terminal/gruvbox-dark.theme" "${s}/.local/share/xfce4/terminal/colorschemes/"
			install_dot_file "${sd}visuals/xfce4-terminal/solarized_dark_high_contrast" "${s}/.local/share/xfce4/terminal/colorschemes/"
		fi

		if [[ "$(uname)" =~ "MINGW" ]]; then
			prompt "Do you want to install ${BOLD}mintty themes?${NC}?"
			ans=$(read_char)
			echo ""
			if [ "$ans" = $AGREE ]; then
				[ ! -f "$souredir/.minttyrc" ] && touch "$sourcedir/.minttyrc"
				cat "${sd}visuals/mintty/gruvbox-dark.minttyrc" >> "$sourcedir/.minttyrc"
			fi
		fi
	fi

}

## MAIN
install_files
install_visuals
setup_git_credentials
