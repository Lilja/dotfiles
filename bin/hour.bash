#!/bin/bash

declare -A options

options[help_flag]=0
options[unknown_flag]=0
options[log_level]=0
options[config_file]="$HOME/.config/hour/config"

declare -A user_variables
months=()
declare -A monthly

function months_of_the_year
{
	i=0
	max=12
	start_date="1970"

	while [ "$i" -lt "$max" ]
	do
		i_c=$((i+1))
		month=$(date "+%h" "-d ${start_date}-${i_c}-01")
		monthly[$month]=0
		months[$i]=$month
		i=$i_c
	done
}


function file_finder
{
	ret=0
	if [ -f "${options[config_file]}" ]
	then
		ret=1
	fi

	echo $ret
}

function read_config 
{
	file=$(file_finder)
	if [ "$file" -eq 1 ]
	then
		for i in $(cat "${options[config_file]}" | grep -o "^[^#]*")
		do
			variable=$(echo "$i" | grep -oP "^.*?(?=\=)")
			value=$(echo "$i" | grep -oP "(?<=\=).*?$")
			user_variables[$variable]=$value
		done 
	fi
	
}

function init
{
	read_config
	months_of_the_year

}

function prompt_user
{
	echo "About to loop"
	for month in "${months[@]}"
	do
		echo "Worked hours for $month: "
		read -e val
		monthly[$month]=$val
		
	done
}

function hours_to_brutto_pay
{
	
}

function main
{
	init
	prompt_user

	while [ "$#" -gt 0 ]
	do
		log=$(echo "$1" | grep -oP "\-((v)){3}") # match "-" and "v" 3 or more times(just cut off after 3)
	done

	

}

main "$@"
