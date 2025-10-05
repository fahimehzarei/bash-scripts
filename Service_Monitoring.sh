#!/bin/bash
# File: ~/monitoring/service_monitor_light.sh


SERVICES=("sshd" "nginx")              
LOG_DIR="$HOME/monitoring/logs"
LOGFILE="$LOG_DIR/service_monitor.log"
EMAIL="daftar.home@gmail.com"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Creating directories if they do not exist
mkdir -p "$LOG_DIR"

# start log
echo "=== $DATE - Service Monitor Start ===" >> "$LOGFILE"

# check service
for service in "${SERVICES[@]}"; do
    status=$(systemctl is-active "$service" 2>/dev/null)
    if [ "$status" == "inactive" ]; then
        echo "$DATE - ALERT: $service is DOWN" >> "$LOGFILE"
        systemctl restart "$service" 2>>"$LOGFILE"
        sleep 2
        new_status=$(systemctl is-active "$service" 2>/dev/null)
        if [ "$new_status" == "active" ]; then
            echo "$DATE - $service restarted successfully" >> "$LOGFILE"
            echo "$service restarted successfully on $(hostname) at $DATE" \
                | mail -s "NOTICE: $service restarted" "$EMAIL"
        else
            echo "$DATE - FAILED to restart $service" >> "$LOGFILE"
            echo "$service could NOT be restarted on $(hostname) at $DATE" \
                | mail -s "ALERT: $service failed to restart" "$EMAIL"
        fi
    else
        echo "$DATE - OK: $service is running" >> "$LOGFILE"
    fi
done

echo "=== $DATE - Service Monitor End ===" >> "$LOGFILE"
echo "" >> "$LOGFILE"
