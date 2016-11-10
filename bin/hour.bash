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
		brutto[$i]=0
		netto[$i]=0
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
	hour_plain=0
	vacation_replacement_payment=0
	lunch_replacement_payment=0

	for month in "${!months[@]}"
	do
		hours=${monthly[${months[$month]}]}
		if [ -z "${monthly[${months[$month]}]}" ]
		then
			hours=0
		fi

		month_name=${months[$month]}
		echo "-----------------"
		echo "Month: $month_name. Monthly hours: $hours"

		hour_plain=$((112*$hours))
		percentage=12
		total=100
		vacation_replacement_payment=$(awk "BEGIN {print ($percentage/$total)}") 
		vacation_replacement_payment=$(awk "BEGIN {print ($vacation_replacement_payment*$hour_plain)}" )
		lunch_replacement_payment=$(awk "BEGIN {print (5.68*$hours) }" )

		brutto[$month]=$(awk "BEGIN { print ($hour_plain+$vacation_replacement_payment+$lunch_replacement_payment) }")

		echo "hour: $hour_plain"
		echo "vacation: $vacation_replacement_payment"
		echo "lunch: $lunch_replacement_payment"
		echo "Total: ${brutto[$month]}"
	done

}

function brutto_to_netto
{
	# Tax = 33 %
	tax=33

	# float results = OriginalValue - (OriginalValue * Percent / 100)
	for month in "${!brutto[@]}"
	do
		month_hour=${brutto[$month]}
		netto[$month]=$(awk "BEGIN { print ($month_hour - ($month_hour * $tax / 100) ) }")
		echo "Brutto:${brutto[$month]}.	Netto:${netto[$month]}" 
	done

}

function total_brutto_and_netto
{
	total_brutto=0
	total_netto=0

	for month in "${!brutto[@]}"
	do
		total_brutto=$(awk "BEGIN {print ($total_brutto+${brutto[$month]}) }")
		total_netto=$(awk "BEGIN {print ($total_netto+${netto[$month]}) }")
	done

	echo "Total brutto: $total_brutto	Total Netto: $total_netto"
}

function main
{
	init
	prompt_user
	hours_to_brutto_pay
	brutto_to_netto
	total_brutto_and_netto

	while [ "$#" -gt 0 ]
	do
		log=$(echo "$1" | grep -oP "\-((v)){3}") # match "-" and "v" 3 or more times(just cut off after 3)
	done

	

}

main "$@"
