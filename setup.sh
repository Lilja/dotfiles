#!/bin/sh

sourcedir=$(echo "$PWD")
symtarget="$HOME"

ASK="-a"
TEST="--test"
FORCE="-f"
ININSTALL="-u"
INSTALL="-i"
AGREE="y"
ABORT="n"

usage()
{
	echo "Usage:"
	echo "	./setup -a | -a | --test | -u"
	echo ""
	echo "-h | --help | Display this message"
	echo "-i or no flags | Regular installation"
	echo "-u | uninstallation"
	echo "-a | careful install. Prompt for installation before every element is installed"
	echo "--test | Unit tests"
	echo "-f | Force install. Will ovewrite things and not backup."
	echo "-v | verbose output(or as much as available)"
	echo ""
	echo "Example: ./install.sh - | Installs everything, without asking."
	echo "Example: ./install.sh -a  | Installs everything, ask for each item."
	echo "Example: ./install.sh -u -a | Uninstalls everything that points to $sourcedir, ask for each item."
	echo "Example: ./install.sh --test | Testing for support."

}

# Helper functions
if [ -f "$sourcedir/dotbin.symlink/colors.sh" ]
then
	. "$sourcedir/dotbin.symlink/colors.sh"
else
	echo "Warning. Colors.sh could not be found"
fi

success() {
	if [ ! -z "${GREEN}" ]
	then
		echo "${GREEN}OK${NC}: $1"
	fi
}

fail() {
	if [ ! -z "${RED}" ]
	then
		echo "${RED}FAIL${NC}: $1"
	fi
	exit
}

info() {
	if [ ! -z "${BLUE}" ]
	then
		echo "${BLUE}INFO${NC}: $1"
	fi
}

warning() {
	if [ ! -z "${YELLOW}" ]
	then
		echo "${YELLOW}WARNING${NC}: $1"
	fi
}

prompt()
{
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
	local mode="$1"
	local verbose=$2
	local wd=$(echo "$PWD")
	local no_ln=$3
	cd "$symtarget"

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
		then # match
			if [ "$mode" = $ASK ]
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
				success "Unlinking $file which pointed to $target"
				unlink "$file"
			fi # no ask mode, just delete
		else
			test "$verbose" -eq 1 && info "File was not in dotfile repo"

			# are we running no_ln mode? Is the files in target directory copied instead of linked?
			if [ $no_ln -eq 1 ]
			then
				if [ -f "$file" ]
				then
					# We are. Check if there is a file with the same hash in the dotfile repo. Sure this means
					# that it's ours to delete.

					k=$(find "$sourcedir" | grep "$file" | xargs sha1sum)
					file_name_arr=$(echo "$source_file" | awk '{print $1}')
					hash_arr=$(echo "$source_file" | awk '{print $1}')

					iterator=0
					n_iterator=1
					len=$(echo "$k" | wc -l)

					while [ $iterator -lt $len ]
					do
						line=$(echo "$k" | head -n+"${n_iterator}" | tail -n1)
						source_file_hash=$(echo "$line" | awk '{print $1}')
						source_file_name=$(echo "$line" | awk '{print $2}')
						current_file_hash=$(sha1sum "$file" | awk '{print $1}')

						if [ "$source_file_hash" = "$current_file_hash" ]
						then
							# info "$source_file"
							info "$file_p $source_p"
							prompt "File ${symtarget}/${file}(${current_file_hash}) has the same hash value as ${source_file_name}. Delete ${symtarget}/${file}(${source_file_hash})?"
							read_char x

							if [ $x = $AGREE ]
							then
								rm "$file"
							fi
						fi
						((iterator+=1))
						((n_iterator+=1))
					done
				fi


			fi
		fi # ! -z $target
	done

	cd "$wd"
}

uninstall_shell_specifics()
{
	mode="$1"
	verbose="$2"
	# look through ${shell}rc and see for every line with source if the directory is pointing to our directory.
	shell=$(basename $SHELL)

	if [ "$mode" = $ASK ]
	then
		info "[SHELL] Assuming youre running $shell"
		prompt "Uninstall .${shell}rc sources to dotfile repo?"
		read_char cont
		if [ "$cont" = $AGREE ]
		then
			content=$(grep -v "\. $sourcedir/${shell}/" "$symtarget/.${shell}rc") #> "$symtarget/.${shell}rc"
			cp /dev/null "$sourcedir/.${shell}rc"
			echo "$content" >> "$symtarget/.${shell}rc"
			success "Uninstalled .${shell}rc sources that linked to dotfile repo"
		fi
	fi

}

install_dot_file() {
	# ln -s /path/to/existing/file /path/to/the/new/symlink
	# -h in if checks if it's a symbolic link

	local dest="$1" # the pointed
	local link="$2" # the pointer
	local mode="$3"
	local verbose="$4"
	local valid="$5"
	local no_ln=$6
	local target_exists=0
	local same_diff=0
	local type_of_file=-1 # 0=symlink, 1=file, 2=directory
	local dest_type_of_file=-1 # 0=symlink, 1=file, 2=directory

	if [ ! -z "$dest" ] || [ ! -z "$link" ]
	then
		install=0
		skip=0
		backup=0

		# First, check if we even want to install the thing. If the user has -a flag that is.
		if [ "$mode" = $ASK ]
			then
				x=""
				destcopy=$dest

				destcopy=$(basename $destcopy)
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
					install=1
				else
					install=0
				fi
			fi

		# Test the dest file, what type of target is it?
		if [ -f "$dest" ]
		then
			dest_type_of_file=1
		elif [ -d "$dest" ]
		then
			dest_type_of_file=2
		fi
		# Check if the link exists, if it's a file or symlink.

		if test -h "$link"
		then
			sym_link=$(readlink "$link")
			type_of_file=0 # symlink
			target_exists=1

			if [ "$sym_link" = "$dest" ] # would an installation point to the same as existing?
			then
				info "Skipping '$dest' because the existing link would link to same post-install"
				target_exists=1
				skip=1
			fi
		elif [ $no_ln -eq 1 ]
		then
			if [ -e "$link" ]
			then
				target_exists=1

				if [ -f "$link" ]
				then
					type_of_file=1 # file
				else
					type_of_file=2 # directory
				fi

				# find if we can find the diff of the file, directories can't have sha1sum.
				if [ $type_of_file -eq 1 ]
				then
					# Take the hash sums, cut out the first column, then take the unique of that. If it's the same, the wc -l will return 1. 2 if not.
					file_diff=$(sha1sum "$link" "$dest" | awk '{print $1}' | uniq | wc -l)


					if [ $file_diff -eq 1 ]
					then
						info "Skipping '$dest' because the file has the same hash."
						same_diff=1
						skip=1
					else
						link_diff=$(sha1sum "$link")
						dest_diff=$(sha1sum "$dest")
						same_diff=0
					fi
				else
					same_diff=-1
				fi
			fi
		fi

		# if the file exists and we do not want to skip install it, follow the procedure:
		if [ $target_exists -eq 1 ] && [ $skip -eq 0 ] && [ $install -eq 1 ]
		then
			if [ $type_of_file -eq 2 ]
			then
				info "Not-implemented-yet"
				skip=1
			else
				msg="an existing symbolic link"
				if [ $type_of_file -eq 1 ]
				then
					msg="an existing file"
				elif [ $type_of_file -eq 2 ]
				then
					msg="an existing directory"
				fi
				info "There seems like '$link' is already $msg and does not link to ${sourcedir}. What would you like to do?"
				if [ ! -z "$link_diff" ]
				then
					info "$link_diff"
					info "$dest_diff"
				fi
				info "[o] overwrite(remove old) [s] skip [a] abort [b] backup(backup old and create new)"

				read_char ans
				echo ""

				case $ans in
					o)
						install=1
					;;
					a)
						fail "Aborted"
					;;
					s)
						skip=1
					;;
					b)
						backup=1
						install=1
					;;
				esac
			fi
		fi

		if [ "$skip" -eq 0 ]
		then
			if [ "$backup" -eq 1 ]
			then
				if [ -f "${link}.backup${iterator}" ]
				then
					iterator=0

					# if there already is a file with .backup0 and so on, try to figure out if that number is incrementable.
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


			if [ $target_exists -eq 1 ]
			then
				if [ "$same_diff" -eq 1 ]
				then
					info "The file '$link' is already installed and contains the same diff, skipping."
					install=0
				else
					if [ $install -eq 1 ]
					then
						if [ $type_of_file -eq 1 ]
						then
							rm "$link"
							info "Removed '$link'"
						else
							rm -r "$link"
							info "Removed '$link'"
						fi
					fi
				fi
			fi

			if [ "$install" -eq 1 ]
			then
				msg=""
				k=""
					if [ $no_ln -eq 1 ]
					then
						if [ $dest_type_of_file -eq 1 ]
						then
							msg="Copied file"
							k=$(cp $dest $link 2>&1)
						elif [ $dest_type_of_file -eq 2 ]
						then
							msg="Copied directory"
							info ": $dest $link"
							k=$(cp -r $dest $link 2>&1)
						fi
					else
						msg="Created symbolic link"
						k=$(ln -sf $dest $link 2>&1)
					fi

				if [ -z "$k" ]
				then
					success "$msg '$link' which points to '$dest' ($valid more to go)"
				else
					case "$dest_type_of_target" in
					0)
						info "Error setting the symbolic link for '$dest' which would point to '$link'"
					;;
					1)
						info "Error copying the file '$dest' which would point to '$link'"
					;;
					2)
						info "Error copying the directory '$dest' which would point to '$link'"
					;;
					esac
				fi
			fi
		fi # if skip -eq 0
	fi
}

install_files()
{
	info "[DOTFILES] Installing dotfiles"
	mode="$1"
	verbose="$2"
	no_ln="$3"
	viminstall
	valid=0

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
	else
		warning "No sources in $sourcedir"
	fi
}

setup_git_credentials()
{
	mode=$1
	verbose=$2
	no_ln=$3
	proceed=1
	skip_link=0

	if [ "$mode" != $FORCE ]
	then
		prompt "[GIT] Install git credentials?"
		read_char install
		echo ""
	else
		install="$AGREE"
	fi

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

			if [ ! -z "$name" ] || [ ! -z "$email" ]
			then
				str="Current credentials: name: '$name', email: '$email'"
				if [ ! -z "$github_alias" ]
				then
					str="$str, github alias: '${github_alias}'"
				fi
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
		elif [ "$proceed" -eq 0 ]
		then
			info "Skipping git setup per request"
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
	info "[GIT] Uninstall git configs"
	mode="$1"
	proceed=1
	gitconf_local_symlink="$sourcedir/git/gitconfig.local.symlink"

	if [ -f "$gitconf_local_symlink" ]
	then
		if [ "$mode" = $ASK ]
		then
			prompt "Remove gitconfig.local?"
			read_char u
			echo ""
			if [ "$u" = $AGREE ]
			then
				proceed=1
			else
				proceed=0
			fi
		fi
	else
		proceed=0
	fi

	if [ "$proceed" -eq 1 ]
	then
		rm "$gitconf_local_symlink"

		if [ ! -f "$gitconf_local_symlink" ]
		then
			success "Removed $gitconf_local_symlink"

			link=$(readlink "$symtarget/.gitconfig.local")

			if [ ! -z "$link" ] && [ ! -f "$link" ]
			then
				if [ "$mode" = $ASK ]
				then
					info "The deleted '$gitconf_local_symlink' is symlinked at '$symtarget/.gitconfig.local'. Remove bad symlink?"
					read_char k
					if [ "$k" = $AGREE ]
					then
						unlink "$symtarget/.gitconfig.local"
					fi
				else
					unlink "$symtarget/.gitconfig.local"
				fi
			fi
		else
			warning "Error removing $gitconf_local_symlink"
		fi
	fi

}

install_shell_specific()
{
	mode="$1"
	verbose=$2

	shell=$(basename $SHELL)

	info "[SHELL] Assuming you're running '$shell'"
	# if there is $shell stuff in sourcedir, try to install it. If not, don't bother.
	if [ -d "$sourcedir/$shell/" ]
	then
		if [ "$mode" != $FORCE ] || [ -z "$mode" ]
		then
			prompt "Install shell specific items?"
			read_char install
			echo ""
		else
			info "Installing shell specific items"
			install=$AGREE
		fi

		if [ "$install" = $AGREE ]
		then
			list=$(find -H "$sourcedir/$shell/" -maxdepth 1 | tail -n+2)
			test "$verbose" -eq 1 && info "List: '$list'"

			for item in $list
			do
				test "$verbose" -eq 1 && info "Loop ran for $item"
				is_sourced=$(cat "$symtarget/.${shell}rc" | grep "\. $item")
				test "$verbose" -eq 1 && info "is_sourced=$is_sourced"

				if [ -z "$is_sourced" ] # empty varible means it isn't sourced
				then
					if [ "$mode" = $ASK ]
					then
						prompt "Source '$item' to ${shell}rc?"
						read_char i
						echo ""
						if [ "$i" = $AGREE ]
						then
							echo ". $item" >> "$symtarget/.${shell}rc"
							success "$item sourced to ${shell}rc"
						fi
					else
						echo ". $item" >> "$symtarget/.${shell}rc"
						success "$item sourced to ${shell}rc"
					fi
				else
					info "'$item' already installed in ${shell}rc"
				fi
			done

		fi
	else
		info "Skipped uninstall since there is not $shell folder in $sourcedir"
	fi
}

test_dependencies()
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
	if [ -f "$sourcedir/dotbin.symlink/colors.sh" ]
	then
		success "Colors.sh exists"
	else
		fail "Warning. colors.bash could not be found"
	fi
}


## MAIN
main()
{
	setting=""
	choice="install"
	verbose=0
  no_ln=0

	for var in "$@"
	do
		case "$var"
		in
			-f)
				info "Force matched"
				choice="install"
				setting="-f"
			;;
			-a)
				setting="-a"
			;;
			--test)
				choice="test"
			;;
			-v|-vv|-vvv)
				info "Verbose mode toggled"
				verbose=1
      ;;
      --no-ln)
        info "Will not use 'ln', fallback to 'cp'"
        no_ln=1
			;;
			-u)
				choice="uninstall"
			;;
			-h|--help)
				usage
				exit
			;;
			*)
				usage
				exit
			;;
		esac
	done

	case "$choice" in
	install)
		if [ "$setting" = $FORCE ]
		then
			info "Forcfully installing. This action might remove old dotfiles on your system. Proceed? [y/n]"
			read -r p
			if [ "$p" = $AGREE ]
			then
				install_files "-f" "$verbose" "$no_ln"
				setup_git_credentials "-f" "$verbose" "$no_ln"
				install_shell_specific "-f" "$verbose" "$no_ln"
			else
				info "Aborted"
			fi
		else
			install_files "$setting" "$verbose" "$no_ln"
			setup_git_credentials "$setting" "$verbose" "$no_ln"
			install_shell_specific "$setting" "$verbose" "$no_ln"
		fi
	;;
	test)
		info "Running tests"
		test_dependencies
	;;
	uninstall)
		uninstall_dot_files "$setting" "$verbose" "$no_ln"
		uninstall_git_config "$setting" "$verbose"
		uninstall_shell_specifics "$setting" "$verbose"
	;;
	*)
		usage
		exit
	;;
	esac
}

# run main(call it)
main "$@"
