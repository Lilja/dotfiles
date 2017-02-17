#!/bin/sh

sourcedir=$(echo "$PWD")
symtarget="$HOME"

ININSTALL="-u"
INSTALL="-i"
AGREE="y"
ABORT="n"

usage()
{
	echo "Usage:"
	echo "	./setup | -u"
	echo ""
	echo "-h | --help | Display this message"
	echo "-u | uninstallation"
	echo "-v | verbose output(or as much as available)"
	echo ""
	echo "Example: ./install.sh | Installs everything, ask for each item/section."
	echo "Example: ./install.sh -u | Uninstalls everything that points to $sourcedir, ask for each item/section."

}

# Helper functions
if [ -f "$sourcedir/dotbin.symlink/colors.sh" ]
then
	. "$sourcedir/dotbin.symlink/colors.sh"
else
	echo "Warning. Colors.sh could not be found"
fi

success() {
	if [ ! -z "${GREEN}" ]; then echo "${GREEN}OK${NC}: $1"; fi
}

fail() {
	if [ ! -z "${RED}" ]; then echo "${RED}FAIL${NC}: $1"; fi
	exit
}

info() {
	if [ ! -z "${BLUE}" ]; then echo "${BLUE}INFO${NC}: $1"; fi
}

warning() {
	if [ ! -z "${YELLOW}" ]; then echo "${YELLOW}WARNING${NC}: $1"; fi
}

prompt() {
	if [ ! -z "${MAGNETA}" ]
	then
		if [ "$2" = "text" ]
		then
			echo "${MAGNETA}PROMPT${NC}: $1"
		else
			echo "${MAGNETA}PROMPT${NC}: $1 ($AGREE/$ABORT)"
		fi
	fi
}

read_char() {
	stty -icanon -echo
	eval "$1=\$(dd bs=1 count=1 2>/dev/null)"
	stty icanon echo
}

# See if vim is installed
viminstall() {
	vim=$(command -v vim 2>/dev/null)
	if [ -d "$vim" ] || [ -f "$vim" ]
	then
		success "Vim installed"
	else
		info "Vim not installed"
	fi
}

uninstall_dot_files()
{
	info "[DOTFILES] Uninstalling dotfiles"
	local verbose=$1
	local wd=$(echo "$PWD")
	local no_ln=$2
	pushd "$symtarget" > /dev/null

	# Get all dotfiles in symtarget
	var=$(ls -al | awk '{print $9}' | grep  "^\." | tail -n+3) # there might be a better way to do this. ls -al, get $9(file names) grep for a dot in the begining

	test $verbose -eq 1 && info "The following dotfiles has been found '$(echo $var | tr '\n' ' ')'"

	target=""

	for file in $var
	do
		test $verbose -eq 1 && info "checking '$file'"
		target=$(ls -al "$file" | awk '{print $11}')
		is_target_dotfile_repo=$(echo "$target" | grep "$sourcedir") # if the symlink of the current dotfile links to "*../dotfiles/*"

		if [ ! -z "$target" ] && [ "$target" = "$is_target_dotfile_repo" ]
		then
			prompt "Unlink '$file'?"
			read_char ans
			echo ""

			if [ "$ans" = $AGREE ]
			then
				success "Unlinking $file which pointed to $target"
				unlink "$file"
			fi
		else
			test "$verbose" -eq 1 && info "File was not in dotfile repo"

		fi # ! -z $target
	done

	cd "$wd"
}

install_dot_file() {
	# ln -s /path/to/existing/file /path/to/the/new/symlink
	# -h in if checks if it's a symbolic link

	local dest="$1" # the pointed
	local link="$2" # the pointer
	local mode="$3"
	local verbose="$4"
	local valid="$5"
	local target_exists=0

	if [ ! -z "$dest" ] || [ ! -z "$link" ]
	then
		destcopy=$(basename $dest)

		str=""
		if [ -d "$dest" ]
		then
			str="Do you want to install the directory '$destcopy/'? ($valid more to go)"
		else
			str="Do you want to install the file '$destcopy'? ($valid more to go)"
		fi

		prompt "$str"
		read_char x
		echo ""

		if [ "$x" = $AGREE ]
		then
			# Check if the link exists, if it's a file or symlink.
			if test -h "$link"
			then
				sym_link=$(readlink "$link")

				if [ "$sym_link" = "$dest" ] # would an installation point to the same as existing?
				then
					info "Skipping '$dest' because the existing link would link to same post-install"
					return 1
				else
					# if the file exists and we do not want to skip install it, follow the procedure:
					if [ $target_exists -eq 1 ] && [ $skip -eq 0 ]
					then
						info "There seems like '$link' is already an existing symbolic link and does not link to ${sourcedir}."
						info "What would you like to do?"
						info "[o] overwrite(remove '$link') [s] skip [a] abort(quit) [b] backup(backup old and create new)"

						read_char ans
						echo ""

						case $ans in
							o)
								unlink "$link"
								k=$(ln -sf $dest $link 2>&1)

								if [ -z "$k" ]
								then
									success "Created symbolic link '$link' which points to '$dest' ($valid more to go)"
								else
									info "Error setting the symbolic link for '$dest' which would point to '$link'"
								fi
							;;
							s)
								return 1
							;;
							b)
								if [ -f "${link}.backup${iterator}" ]
								then
									iterator=0

									# if there already is a file with .backup0, .backup1 ... .backup[n] and so on, try to figure out if that number is incrementable.
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
							;;
							s)
								return 1
							;;
							a|*)
								fail "Aborted"
							;;
						esac

					fi # if target exists,
				fi
			fi
		fi
	fi

}

install_files()
{
	verbose="$1"
	valid=0

	info "[DOTFILES] Installing dotfiles"

	# Look for files that match *.symlink, loop through and see if we can install it.
	sources=$(find -H "$sourcedir" -maxdepth 2 -name "*.symlink" -not -path '*.git*')
	if [ ! -z "$sources" ]
	then
		for src in $sources
		do
			file=$(basename "$src" | sed "s/\.symlink$//") # sed to remove .symlink
			target="$symtarget/.$file"
			if [ "$target" != "$file" ]
			then
				valid=`expr $valid + 1`
			fi
		done
	fi

	# Look for files that match *.symlink, loop through and see if we can install it.
	sources=$(find -H "$sourcedir" -maxdepth 2 -name "*.symlink" -not -path '*.git*')
	if [ ! -z "$sources" ]
	then
		for src in $sources
		do
			file=$(basename "$src" | sed "s/\.symlink$//") # sed to remove .symlink
			install_dot_file "$src" "$symtarget/.$file" "$mode" "$verbose" "$valid" "$no_ln"
			valid=`expr $valid - 1`
		done
	fi
}

setup_git_credentials()
{
	verbose=$1
	proceed=1
	skip_link=0

	prompt "[GIT] Install git credentials?"
	read_char install
	echo ""

	if [ "$install" = $AGREE ]
	then
		git_local="gitconfig.local.symlink"
		git_local_path="$sourcedir/git/$git_local"

		git_local_sample="gitconfig.local.sample"
		git_local_sample_path="$sourcedir/git/$git_local_sample"

		if  [ -f "$git_local_path" ] || [ "$mode" = "-f" ]
		then
			# See if the is already initialized stuff in $git_local_path
			content=$(cat "$git_local_path")

			name=$(echo "$content" | grep "name\s*=\s*" | sed 's/^[^\=]*=//g' | xargs)

			email=$(echo "$content" | grep "email\s*=\s*" | sed 's/^[^\=]*=//g' | xargs)

			github_alias=$(echo "$content" | grep "user\s*=\s*" | sed 's/^[^\=]*=//g' | xargs)

			if [ ! -z "$name" ] || [ ! -z "$email" ] || [ ! -z "$github_alias" ]
			then
				str="Current credentials: name: '$name', email: '$email', github alias: '${github_alias}'"
				str="${str}. Would you like to change it?"

				prompt "$str"
				read_char x

				if [ "$x" = $AGREE ]
				then
					proceed=1
					skip_link=1
				else
					proceed=0
				fi
			else
				proceed=1
			fi
		fi

		if [ -f "$git_local_sample_path" ] && [ "$proceed" -eq 1 ]
		then
			name=""
			email=""
			website=""
			git_alias=""

			if [ "$mode" = $FORCE ]
			then
				info "[GIT] Setting up git credentials"
			fi
			prompt "What is your name? First and last name." "text"
			read -r name
			test "$verbose" -eq 1 && info "name set to $name"

			prompt "What is your email?" "text"
			read -r email
			test "$verbose" -eq 1 && info "email set to $email"

			prompt "Do you have an github alias?" "text"
			read -r git_alias
			test "$verbose" -eq 1 && info "git_alias set to $git_alias"

			# replace
			# "name = " with "name = $name"
			# and
			# "email = " with "email = $email"
			# into a new file called .gitconfig.local

			cp "$git_local_sample_path" "$git_local_path"
			line=$(cat "$git_local_path" | sed "s/name\s*\=/name\ \=\ $name/g")
			echo "$line" > "$git_local_path" # paste content of variable in gitconfig

			line=$(cat "$git_local_path" | sed "s/email\s*\=/email\ \=\ $email/g")
			echo "$line" > "$git_local_path" # paste content of variable in gitconfig

			if [ "$git_alias" != $ABORT ]
			then
				line=$(cat "$git_local_path" | sed "s/user\s*\=/user\ \=\ $git_alias/g")
				echo "$line" > "$git_local_path" # paste content of variable in gitconfig
			fi

			if [ "$skip_link" -eq 0 ]
			then
				install_dot_file "$git_local_path" "$symtarget/.gitconfig.local" " " " " 0 "$no_ln"
			fi
		else
			if [ "$proceed" -eq 1 ]
			then
				info "Skipped making git credentials because the sample file could not be found."
			else
				info "Skipping git setup per request"
			fi
		fi
	else
		if [ -f "$git_local_path" ]
		then
			info "Skipping git setup because there is another .local file. Run script with -f flag overwrite things."
		elif [ -f "$git_local_sample_path" ]
		then
			warning "Skipping git setup because .gitconfig.local doesn't exist"
		else
			info "Skipping git setup per request"
		fi
	fi # if install = $agree
}

uninstall_git_config()
{
	# local verbose=$1
	info "[GIT] Uninstall git configs"
	gitconf_local_symlink="$sourcedir/git/gitconfig.local.symlink"

	if [ -f "$gitconf_local_symlink" ]
	then
		prompt "Remove gitconfig.local?"
		read_char u
		echo ""

		if [ "$u" = $AGREE ]
		then
			rm "$gitconf_local_symlink"

			if [ ! -f "$gitconf_local_symlink" ]
			then

				link=$(readlink "$symtarget/.gitconfig.local")
				unlink "$symtarget/.gitconfig.local"

				success "Removed $gitconf_local_symlink"
			fi
		fi
	fi

}

## MAIN
main()
{
	choice="install"
	verbose=0

	for var in "$@"
	do
		case "$var"
		in
			-v|-vv|-vvv)
				info "Verbose mode toggled"
				verbose=1
			;;
			-u)
				choice="uninstall"
			;;
			-h|--help|*)
				usage
				exit
			;;
		esac
	done

	case "$choice" in
	install)
		install_files "$verbose"
		setup_git_credentials "$verbose"
	;;
	uninstall)
		uninstall_dot_files "$verbose"
		uninstall_git_config "$verbose"
	;;
	*)
		usage
		exit
	;;
	esac
}

# run main(call it)
main "$@"
