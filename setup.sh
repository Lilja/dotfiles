#!/bin/bash

sourcedir=$(echo "$PWD")
symtarget="$HOME"
CODE_DIR=$symtarget/code

# Helper functions
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
NC=$(tput sgr0)
BOLD=$(tput bold)
DOTFILE_COPY=0

failure() {
    printf "    ${RED}[✖] $1${NC}\n"
}
success() {
    printf "    ${GREEN}[✔]${NC} $1\n"
}
ask() {
    printf "    ${YELLOW}$1${NC} (y/n) "
}
success_ask() {
    printf "\33[2K\\r    ${GREEN}[✔]${NC} $1\\n"
}
failure_ask() {
    printf "\\r    ${RED}[✖]${NC}$1\n"
}

print_msg() {
	echo -e "\t$1"
}

print_header() {
	echo ""
	echo "${GREEN}${BOLD}$1${NC}"
	echo ""
}

boldify_dotfile() {
    echo "${BOLD}$1${NC}" | sed "s#$symtarget#${NC}&${BOLD}#" | sed "s#dotfiles#${NC}&${BOLD}#"
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

read_char() {
	val=""; read -n1 val; echo $val
}

install_dot_file() {
	# ln -s /path/to/existing/file /path/to/the/new/symlink
	# -h in if checks if it's a symbolic link

	dest="$1" # the pointed
	link="$2" # the pointer

	if [ -d "$link" ] || [ -f "$link" ]; then
		backup 1 "$link";
	fi
    if [ $DOTFILE_COPY -eq 0 ]; then
        local temp=$(ln -s "$dest" "$link" 2>&1)
        code=$?
	else
		if [ -d "$link" ]; then
			local temp=$(cp -r "$link" "$dest")
			code=$?
		elif [ -f "$link" ]; then
			local temp=$(cp "$link" "$dest")
			code=$?
		fi
    fi

	if [ $code -eq 0 ]; then
		success_ask "$(boldify_dotfile $dest) →  $(boldify_dotfile $link)"
	else
		failure_ask "$(boldify_dotfile $dest) →  $(boldify_dotfile $link)"
	fi
}

prompt_for_install() {
	source_file=$1
	target_file=$2
	$(check_if_file_already_installed $source_file $target_file 2>/dev/null)
	if [[ $? -eq 0 ]]; then
		ask "Install $(boldify_dotfile ${source_file})"
		agree_to_install=$(read_char)
		if [ "$agree_to_install" == "y" ]; then
			install_dot_file "$source_file" "$target_file"
		fi
	else
		success "$(boldify_dotfile $source_file) → $(boldify_dotfile $target_file)"
	fi
}

check_if_file_already_installed() {
	dest="$1"
	link="$2"
	if [ ! -z "$dest" ] || [ ! -z "$link" ]; then
		destcopy="$(basename $dest)"
		sym_link="$(readlink $link)"

		if [ "$sym_link" = "$dest" ]; then exit 1
		else exit 0
	  fi
	fi
}

install_files()
{
	print_header "Dotfiles"
read -r -d '' files << EOF
zsh/zshrc:.zshrc
zsh/zshenv:.zshenv
zsh/zprofile:.zprofile
vim/vim:.vim
vim/vimrc:.vimrc
git/gitconfig:.gitconfig
git/gitconfig.local:.gitconfig.local
git/gitignore:.gitignore_global
dotbin/:.dotbin
EOF
	for f in $files; do
		source_file=$(echo "$f" | grep -o '.*:' | sed 's#:$##')
		target_file=$(echo "$f" | grep -o ':.*' | sed 's#^:##')
		prompt_for_install "$sourcedir/$source_file" "$symtarget/$target_file"
	done
}

create_code_dir() {
    print_header "Create code directory"
    if [ ! -d "$CODE_DIR" ]; then
        mkdir "$CODE_DIR"
        success "Creating folder '$CODE_DIR'"
    else
        success "$CODE_DIR already created"
    fi

}

setup_git_credentials() {
	email=$(git config user.email)
	name=$(git config user.name)
	github=$(git config github.user)
	print_header "Git configuration"

	if [ ! -z "$email" ] && [ ! -z "$name" ]; then
		str="    Current git config: \n    Name: ${GREEN}${BOLD}$name${NC}\n    Email: ${GREEN}${BOLD}$email${NC}"
		[ ! -z "$github" ] && str="${str}\n    Github user: ${GREEN}${BOLD}$github${NC}"
		echo -e "$str\n"
	fi

	ask "Do you want to configure Git?"
	install_git=$(read_char);

	if [ "$install_git" = "y" ]; then
		[ -f "$sourcedir/gitconfig.local" ] && backup "$sourecdir/gitconfig.local";

		git_local="gitconfig.local"
		git_local_path="$sourcedir/git/$git_local"

		git_local_sample="gitconfig.local.sample"
		git_local_sample_path="$sourcedir/git/$git_local_sample"

		cp $git_local_sample_path $git_local_path

		echo "    What is your name? First and last name: "
		read -r name

		echo "    What is your email?: "
		read -r email

		echo "    Do you have an github alias? (n for not specified/skip): "
		read -r git_alias

		sed -i "s#name\s*\=#name\ \=\ $name#g" "$git_local_path"
		sed -i "s#email\s*\=#email\ \=\ $email#g" "$git_local_path"

		if [ $git_alias != "n" ]; then
			sed -i "s#user\s*\=#user\ \=\ $git_alias#g" "$git_local_path"
		fi

		ln -sf $git_local_path ${symtarget}/.gitconfig.local
	else
		echo ""
	fi
}

create_local_files() {
	echo ""
	echo "${GREEN}${BOLD}Local files${NC}"
	echo ""
	zshrc="$symtarget/.zshrc.local"
	if [ ! -e "$zshrc" ]; then
		success "Creating $(boldify_dotfile $zshrc)"
		printf "" >> "$zshrc"
	else
		success "$(boldify_dotfile $zshrc) already created"
	fi
	vimrc="$symtarget/.vimrc.local"
	if [ ! -e "$vimrc" ]; then
		success "Creating $vimrc"
		printf "" >> "$vimrc"
	else
		success "$(boldify_dotfile $vimrc) already created"
	fi
}

install_visuals()
{
	git submodule init
	git submodule update
	print_header "Visuals"
	ask "Do you want to install visuals?"
	ans=$(read_char)

	if [ "$ans" = "y" ]; then
		prompt_for_install "${sourcedir}/visuals/i3" "${symtarget}/.i3/"
		prompt_for_install "${sourcedir}/visuals/fonts" "${symtarget}/.fonts/"
		prompt_for_install "${sourcedir}/visuals/icons" "${symtarget}/.icons/"
		prompt_for_install "${sourcedir}/visuals/xfce4-terminal/gruvbox-dark.theme" "${symtarget}/.local/share/xfce4/terminal/colorschemes/gruvbox-dark.theme"
		prompt_for_install "${sourcedir}/visuals/xfce4-terminal/solarized_dark_high_contrast" "${symtarget}/.local/share/xfce4/terminal/colorschemes/solarized_dark_high_contrast"

		if [[ "$(uname)" =~ "MINGW" ]]; then
			ask "Do you want to install ${BOLD}mintty themes?${NC}"
			ans=$(read_char)
			if [ "$ans" = $AGREE ]; then
				[ ! -f "$s/.minttyrc" ] && touch "$s/.minttyrc"
				cat "${sourcedir}/visuals/mintty/gruvbox-dark.minttyrc" >> "$s/.minttyrc"
			fi
		fi
	else
		echo ""
	fi
}

supply_distinfo() {
	print_header "Distro information"

	echo -n "    ${BOLD}Git: ${NC}" && git --version
	echo -n "    ${BOLD}Ssh: ${NC}" && ssh -V
	echo -n "    ${BOLD}Bash: ${NC}" && bash --version | head -n1
	echo -n "    ${BOLD}Zsh: ${NC}" && zsh --version
}

ssh_configuration() {
	print_header "SSH"

	if [ ! -z "${SSH_AUTH_SOCK:foo}" ]; then
		success "${BOLD}SSH-agent${NC} is working and forwards keys"
	else
		failure "${BOLD}SSH-agent${NC} does not seem to work"
	fi

	pub_ssh=$(ls "$HOME"/.ssh/*.pub 2>/dev/null)
	if [ ! -z "$pub_ssh" ]; then
		echo ""
		echo "    Your ssh-key(s):"
		while read key; do
			echo -n "    * " && ssh-keygen -E md5 -lf "$key"
		done <<< "$pub_ssh"
	fi
	echo ""
	ask "Do you want to install an ssh key?"
	ans=$(read_char)
	echo ""

	if [ "$ans" = "y" ]; then
		echo ""
		echo "    Creating a key 4096 byte RSA key"
		echo "    Enter an e-mail address or something to this link this key to"
		read -r comment
		ssh-keygen -t rsa -b 4096 -C "$comment"
	fi
}

install_from_git_and_symlink() {
	#1 = git repo
	#2 = path/to/binary/file/is/localed/in/git/repo
	#3 = path/to/where/git/repo/can/be/installed/on/disk
	#4 = installation/path/on/local/system/like/usr/bin
	git_repo_url=$1
	path_to_bin=$2
	git_repo_installation_path=$3
	path_to_install=$4
	binary_program=$(basename $1)

	if ! which "$binary_program" &>/dev/null; then
	    if [ -e "$path_to_install" ]; then
			success "$binary_program is installed but not in ${BOLD}\$PATH${NC}"
		else
			ask "Install $binary_program?"
			ans=$(read_char)
			if [ "$ans" = "y" ]; then
				if [ ! -d "$git_repo_installation_path" ]; then
					(git clone "$git_repo_url" "$git_repo_installation_path")
				fi
				if [ ! -e "$path_to_install" ]; then
					ln -s "$git_repo_installation_path/$path_to_bin" "$path_to_install"
				fi

				if [ $? -eq 0 ]; then
					success_ask "$binary_program successfully installed"
				else
					failure_ask "$binary_program failed to install"
				fi
			fi
		fi
	else
		success "$binary_program already installed"
	fi

}

install_bin() {
  print_header "Binaries"
  install_from_git_and_symlink "https://github.com/lilja/timelog" "bin/timelog" "$CODE_DIR/timelog" "$PWD/bin/timelog"
}

## MAIN
if [ "$1" = "cp" ]; then
    DOTFILE_COPY=1
fi
install_files
install_visuals
setup_git_credentials
create_local_files
create_code_dir
supply_distinfo
ssh_configuration
install_bin
echo ""
