#!/bin/bash
# Script: all_services_monitor.sh
# Description: Display service status, save to log, and mark Down services

# Log file path
LOGFILE="/var/log/services_status.log"

# Colors for terminal output
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Temporary files for sorting
active_tmp=$(mktemp)
down_tmp=$(mktemp)   # Includes inactive and failed services

# Get the list of all services
services=$(systemctl list-unit-files --type=service --no-pager --no-legend | awk '{print $1}')

# Check each service and store in the appropriate temporary file
for service in $services; do
    status=$(systemctl is-active $service 2>/dev/null)
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    line="$timestamp : $service : $status"

    if [[ "$status" == "active" ]]; then
        echo -e "$line" >> $active_tmp
    else
        # Considered Down (inactive or failed)
        echo -e "$line [DOWN]" >> $down_tmp
    fi
done

# Display output in terminal
echo -e "===== Services Status: $(date) =====\n"

cat $active_tmp | while read l; do echo -e "${GREEN}$l${RESET}"; done
cat $down_tmp | while read l; do echo -e "${RED}$l${RESET}"; done

# Save all output to log file
cat $active_tmp >> $LOGFILE
cat $down_tmp >> $LOGFILE

# Remove temporary files
rm -f $active_tmp $down_tmp