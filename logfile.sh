#!/bin/bash
logfile="/var/log/auth.log"
senderEmail="yourEmail@gmail.com"
nowDate=$(date '+%Y-%m-%d %H:%M:%S')

# check logfile to exist
if [ ! -f "$logfile" ]; then
    echo "$nowDate : log file not found"
    exit 1
fi

# Unsuccessful log
failcount=$(sudo grep "Failed password" $logfile | wc -l)

# Send email if there was an unsuccessful attempt
if [ $failcount -gt 0 ]; then
    echo "$nowDate : $failcount failed login attempts" | mail -s "Failed Login Alert" $senderEmail
else
    echo "$nowDate : no failed login attempts"

fi
