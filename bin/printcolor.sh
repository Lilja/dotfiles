#!/bin/bash
usage="Usage: printcolor [-o|-u] [fg|bg] [color] optional:text"
# Takes three args
# 1 = Ordered|unordered
# 2 = If print a foreground or background of the next argument
# 3 = The color to print
# 4 = Optional text

ordered=0
color=$3
test "$1" = "-o" && ordered=1;
test -n "$2" || { echo "$usage" ; exit 1; }
test -n "$3" || { echo "$usage" ; exit 1; }
txt=$4

test $(tput colors) -gt 8 || echo "Tput thinks you only have 8-color support. Is this intended?"

if [ "$2" = "fg" ]; then
	if [ $ordered -eq 1 ]; then
		for i in $(seq 0 7)
		do
			echo -n "$(tput setab $3)$(tput setaf $i)$txt$i"
		done
		echo "$(tput op)"
		for i in $(seq 8 15)
		do
			echo -n "$(tput setab $3)$(tput setaf $i)$txt$i"
		done
		tput op
		echo "$(tput op)"

		count=0
		for i in $(seq 16 231)
		do
			count=$((count+1))
			echo -n "$(tput setab $3)$(tput setaf $i)$txt$i"
			if [ $count -eq 6 ]; then count=0;echo "$(tput op)"; fi
		done

		count=0
		echo
		for i in $(seq 232 255)
		do
			count=$((count+1))
			echo -n "$(tput setab $3)$(tput setaf $i)$txt$i"
			if [ $count -eq 12 ]; then count=0;echo "$(tput op)"; fi
		done
	else
		for i in $(seq 0 8)
		do
			echo -n "$(tput setab $3)$(tput setaf $i)$txt$i"
		done
		tput op
		echo "$(tput op)"

		count=0
		for i in $(seq 8 $(tput colors))
		do
			count=$((count+1))
			echo -n "$(tput setab $3)$(tput setaf $i)$txt$i"
			if [ $count -eq 5 ]; then count=0;echo "$(tput op)"; fi
		done
	fi
else
	if [ "$ordered" -eq 1 ]; then
		for i in $(seq 0 7)
		do
			echo -n "$(tput setab $i)$(tput setaf $3)$txt$i"
		done
		echo "$(tput op)"
		for i in $(seq 8 15)
		do
			echo -n "$(tput setab $i)$(tput setaf $3)$txt$i"
		done
		tput op
		echo

		count=0
		for i in $(seq 16 231)
		do
			count=$((count+1))
			echo -n "$(tput setab $i)$(tput setaf $3)$txt$i"
			if [ $count -eq 6 ]; then count=0;echo "$(tput op)"; fi
		done

		count=0
		echo
		for i in $(seq 232 255)
		do
			count=$((count+1))
			echo -n "$(tput setab $i)$(tput setaf $3)$txt$i"
			if [ $count -eq 12 ]; then count=0;echo "$(tput op)"; fi
		done
	else
		for i in $(seq 0 8)
		do
			echo -n "$(tput setab $i)$(tput setaf $3)$txt$i"
		done
		tput op
		echo

		count=0
		for i in $(seq 8 $(tput colors))
		do
			count=$((count+1))
			echo -n "$(tput setab $i)$(tput setaf $3)$txt$i"
			# if [ $count -eq 5 ]; then count=0;echo; fi
		done
	fi
fi
tput op
echo
