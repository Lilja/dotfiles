#!/bin/bash

input_flag=0
read_from_file_flag=0
help_flag=0
unknown_flag=0
no_prompt_flag=0
shift_argument=0
log_file_name="time_logs"

t1=0
t2=0

function usage {
	echo "Usage: (-r | -i) digit [options]"
	echo "Description. Input two times and subtract them, output to double format. "
	echo "PARAMS: Takes two times with the -i flag, four character long each. Or the -r flag to fetch those from file instead."
	echo "Optional: Third parameter or parameter after -r flag. A number of minutes to exclude from the calculation"
	echo ""
	echo "-h | --help [This will output this text]"
	echo "-i [Read from input arguments]"
	echo "-r [Read from file mode. Will fetch the times from two files called start.txt and end.txt.]"
	echo "-np [ No prompt. At the end of the calculation, you will not be prompted to save your progress to file]"
	echo "Example usage:"
	echo ""
	echo "./script -r 45"
	echo "./script -i 0800 1505 45"
}

while [ "$#" -gt 0 ]
do
	if [ "$1" == "-i" ]
	then
		echo "input flag matched"
		input_flag=1
		t1=$2
		t2=$3
		shift
		shift
	elif [ "$1" == "-r" ]
	then
		echo "read from file matched"
		t1=$(cat start.txt)
		t2=$(cat end.txt)
		read_from_file_flag=1
	elif [ "$1" == "-np" ]
	then
		echo "no prompt flag matched"
		no_prompt_flag=1
	elif [ "$1" == "-h" ] || [ "$1" == "--help" ]
	then
		usage
		exit
	fi

	echo "$@"

	if [ "$#" -gt 0 ]
	then
		shift
	fi
done

function calculate_time
{
	if [ ! -z "$t1" ] || [ ! -z "$t2" ]
	then
		t3m="$1" # Break time, in minutes

		if [ "${t1:0:1}" -eq 0 ] # if first char is 0. like 0900
		then
			initial=2
			t1h=$(echo "${t1:0:2}")
		else
			# Char is 900
			initial=1
			t1h=$(echo "${t1:0:1}")
		fi
		t1m=$(echo "${t1:$initial:4}")

		if [ "${t2:0:1}" -eq 0 ] # if first char is 0. like 0900.
		then
			initial=2
			t2h=$(echo "${t2:0:2}")
		else
			# Char is 900
			initial=1
			t2h=$(echo "${t2:0:1}")
		fi
		t2m=$(echo "${t2:$initial:4}")

		if [ "${#t1}" -eq 4 ] && [ "${#t2}" -eq 4 ]
		then
			if  [ "$t1h" -ge 0 ] ||
				[ "$t1h" -le 23 ] ||
				[ "$t2h" -ge 0 ] ||
				[ "$t2h" -le 23 ]
			then
				# Remove leading zeros
				t1h=${t1h#0}
				t1m=${t1m#0}
				t2h=${t2h#0}
				t2m=${t2m#0}

				# Minimize stuff

				# We want to subtract hours here.
				# 0830 & 1600 => 0000 & 0830
				# 0725 & 1210 => 0000 & 0445

				if [ "$t1m" -gt "$t2m" ]  # 0830, 1600.
				then
					# t2's minute is lesser. Add 60 to it and subtrace t2h by one.
					t2h=$((t2h-=1))
					t2m=$((t2m+60))
				fi # t1m -gt t2m

				# Should be good to go, do the subtraction
				t2h=$((t2h-t1h))
				t2m=$((t2m-t1m))

				# t1h, t1m not relevant any more.
				unset t1h
				unset t1m

				# Fix third argument
				if [ ! -z "$t3m" ] && [ "$t3m" -gt 0 ]
				then
					# Wrap it up with an if-statement checking if t3m/60 is larger than t2h. If so, break is larger than end time.
					tbh=$((t3m/60))
					total_min=$((t2h*60+(t2m)))

					if [ "$t3m" -lt "$total_min" ]
					then
						if [ "$t2m" -gt "$t3m" ] # if there is room to just subtract. (0445 && 45)=>0400
						then
							t2m=$((t2m-t3m))
						else
							# Since t2m is lower than t3m, borrow an hour from t2h and then subtract
							temp=$(echo "$t3m")
							while [ "$t3m" -gt "$t2m" ]
							do
								t2h=$((t2h-=1))
								t2m=$((t2m+60))
							done
							t2m=$((t2m-temp))
						fi # t3m -lt total_min
					fi # t3m -lt total_min
				else
					# if it's null. Just put zero. Will later work with '($t1-$t2 ${t3m}m break)'
					t3m=0
				fi # ! -z t3m && t3m -gt 0

				total_start_minutes=$((10#$t1h*60 + 10#$t1m))
				total_minutes=$((10#$t2h*60 + 10#$t2m))

				dectime=$(awk "BEGIN {print ($t2h+($t2m/60))}")

				echo "Your decimal time is $dectime"

				if [ "$no_prompt_flag" -eq 0 ]
				then
					echo "Do you wish to save this to file? [y/n]"
					save="n"
					read save

					if [ "$save" == "n" ] || [ "$save" == "y" ]
					then
						if [ "$save" == "y" ]
						then
							d=$(date)
							echo "[$d]: $dectime ($t1-$t2 ${t3m}m break)"
							echo "[$d]: $dectime ($t1-$t2 ${t3m}m break)"  >> "$log_file_name"
						else
							d=$(date)
							echo "[$d]: $dectime ($t1-$t2 ${t3m}m break)"
						fi # save == y
					else
						echo "Unknown input. Will not save."
					fi # save == n
				fi # no_prompt_flag -eq 0
			else
				echo "Parameter doesnt' match the following validation: 0<x<23"
			fi # t1h -ge 0 || ... (4 conditions)
		else
			echo "It looks like one of your paramters were not four characters"
		fi # ${#t1} -eq 4 ] && [ ${#t2} -eq 4
	else
		echo "No start time and/or end time supplied"
	fi # ! -z t1 ||  ! -z t2
}
