#!/bin/bash
# date => hhmm
h=$(date +"%H")
m=$(date +"%M")
echo "$h$m" >> start.txt
