#!/bin/bash

sourcedir=$(echo "$PWD")
symtarget="$HOME"

# Helper functions
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
NC=$(tput sgr0)
BOLD=$(tput bold)

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
	echo "ln -sf "$dest" "$link" 2>&1"
	ln -s "$dest" "$link" 2>&1
}

prompt_for_install() {
	source_file=$1
	target_file=$2
	$(check_if_file_already_installed $source_file $target_file 2>/dev/null)
	if [[ $? -eq 0 ]]; then
		echo -n "Install ${source_file}? y/n"
		agree_to_install=$(read_char); echo ""
		if [ "$agree_to_install" == "y" ]; then
			install_dot_file "$source_file" "$target_file"
		fi
	else
		echo "Skipped $source_file because it already exists!"
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
	echo "${GREEN}${BOLD}Dotfiles!${NC}"
read -r -d '' files << EOF
zsh/zshrc:.zshrc
zsh/zshenv:.zshenv
zsh/zprofile:.zprofile
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

setup_git_credentials() {
	email=$(git config --get user.email)
	name=$(git config --get user.name)
	github=$(git config --get github.user)
	echo ""
	echo "${GREEN}${BOLD}Git!${NC}"
	if [ ! -z "$email" ] && [ ! -z "$name" ]; then
		str="Current git config: \nName: ${GREEN}${BOLD}$name${NC}\nEmail: ${GREEN}${BOLD}$email${NC}"
		[ ! -z "$github" ] && str="${str}\nGithub user: ${GREEN}${BOLD}$github${NC}"
		echo -e "$str"
	fi
	echo -n "Do you want to configure git? [y/n] "
	install_git=$(read_char); echo ""

	if [ "$install_git" = "y" ]; then
		[ -f "$sourcedir/gitconfig.local" ] && backup "$sourecdir/gitconfig.local";

		git_local="gitconfig.local"
		git_local_path="$sourcedir/git/$git_local"

		git_local_sample="gitconfig.local.sample"
		git_local_sample_path="$sourcedir/git/$git_local_sample"

		cp $git_local_sample_path $git_local_path

		echo "What is your name? First and last name: "
		read -r name

		echo "What is your email?: "
		read -r email

		echo "Do you have an github alias? (n for not specified/skip): "
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
	git submodule init
	git submodule update
	echo ""
	echo "${GREEN}${BOLD}Visuals!${NC}"
	echo -n "Do you want to install visuals? [y/n] "
	ans=$(read_char); echo ""

	if [ "$ans" = "y" ]; then
		prompt_for_install "${sourcedir}/visuals/i3" "${symtarget}/.i3/"
		prompt_for_install "${sourcedir}/visuals/fonts" "${symtarget}/.fonts/"
		prompt_for_install "${sourcedir}/visuals/icons" "${symtarget}/.icons/"
		prompt_for_install "${sourcedir}/visuals/xfce4-terminal/gruvbox-dark.theme" "${symtarget}/.local/share/xfce4/terminal/colorschemes/gruvbox-dark.theme"
		prompt_for_install "${sourcedir}/visuals/xfce4-terminal/solarized_dark_high_contrast" "${symtarget}/.local/share/xfce4/terminal/colorschemes/solarized_dark_high_contrast"

		if [[ "$(uname)" =~ "MINGW" ]]; then
			echo "Do you want to install ${BOLD}mintty themes?${NC}?"
			ans=$(read_char)
			echo ""
			if [ "$ans" = $AGREE ]; then
				[ ! -f "$s/.minttyrc" ] && touch "$s/.minttyrc"
				cat "${sourcedir}/visuals/mintty/gruvbox-dark.minttyrc" >> "$s/.minttyrc"
			fi
		fi
	fi
}

## MAIN
install_files
install_visuals
setup_git_credentials
