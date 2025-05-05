#!/bin/bash

# Configuration
LOG_FILE="/var/log/app_monitor.log"
ALERT_EMAIL="lancerajayi@yahoo.com"
CPU_THRESHOLD=80
MEM_THRESHOLD=90
DISK_THRESHOLD=85
APP_NAME="my_application"

# Function: Check if application is running
check_app_status() {
    if pgrep -x "$APP_NAME" > /dev/null; then
        echo "$(date): $APP_NAME is running." >> "$LOG_FILE"
    else
        echo "$(date): ERROR - $APP_NAME is NOT running!" | tee -a "$LOG_FILE"
        echo "Alert: $APP_NAME is not running" | mail -s "Application Alert" "$ALERT_EMAIL"
    fi
}

# Function: Check CPU usage
check_cpu_usage() {
    CPU_LOAD=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    if (( CPU_LOAD > CPU_THRESHOLD )); then
        echo "$(date): High CPU usage detected: $CPU_LOAD%" | tee -a "$LOG_FILE"
        echo "CPU Alert: Usage at $CPU_LOAD%" | mail -s "CPU Alert" "$ALERT_EMAIL"
    fi
}

# Function: Check memory usage
check_memory_usage() {
    MEM_USED=$(free | grep Mem | awk '{print $3/$2 * 100.0}' | cut -d. -f1)
    if (( MEM_USED > MEM_THRESHOLD )); then
        echo "$(date): High Memory usage detected: $MEM_USED%" | tee -a "$LOG_FILE"
        echo "Memory Alert: Usage at $MEM_USED%" | mail -s "Memory Alert" "$ALERT_EMAIL"
    fi
}

# Function: Check disk usage
check_disk_usage() {
    DISK_USED=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    if (( DISK_USED > DISK_THRESHOLD )); then
        echo "$(date): High Disk usage detected: $DISK_USED%" | tee -a "$LOG_FILE"
        echo "Disk Alert: Usage at $DISK_USED%" | mail -s "Disk Alert" "$ALERT_EMAIL"
    fi
}

# Function: Log rotation
rotate_logs() {
    if [ -f "$LOG_FILE" ]; then
        mv "$LOG_FILE" "${LOG_FILE}_$(date +%F_%T)"
        touch "$LOG_FILE"
    fi
}

# Main script execution
echo "Starting Application Monitoring..." >> "$LOG_FILE"
rotate_logs
check_app_status
check_cpu_usage
check_memory_usage
check_disk_usage

echo "Monitoring completed at $(date)" >> "$LOG_FILE"
