#!/bin/bash
# date => hhmm
d=$(date | awk '{print $5}')
d=$(echo "${d:0:5}")
h=$(echo "${d:0:2}")
m=$(echo "${d:3:4}")
echo "$h$m" >> end.txt
