#!/bin/bash

# Configuration
METRICS_SCRIPT="/home/kimaren/Projects/MiniProjects/SystemMetrics/system_metrics.sh"
OUTPUT_FILE="/home/kimaren/Projects/MiniProjects/SystemMetrics/system_metrics_$(date +%Y%m%d_%H%M%S).txt"
EMAIL_ADDRESS="kimarennaidoo@gmail.com"
SUBJECT="System Metrics Report - $(date '+%Y-%m-%d %H:%M')"
LOG_FILE="/home/kimaren/Projects/MiniProjects/SystemMetrics/email_metrics.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" >> "$LOG_FILE"
}

# Function to cleanup and exit
cleanup_and_exit() {
    local exit_code=$1
    if [ -f "$OUTPUT_FILE" ]; then
        rm -f "$OUTPUT_FILE"
        log_message "Cleaned up output file: $OUTPUT_FILE"
    fi
    exit $exit_code
}

# Trap to ensure cleanup on script exit
trap 'cleanup_and_exit $?' EXIT

log_message "Starting system metrics email script"

# Check if metrics script exists and is executable
if [ ! -f "$METRICS_SCRIPT" ]; then
    echo "Error: Metrics script $METRICS_SCRIPT not found" | mail -s "ERROR: Metrics Script Missing" "$EMAIL_ADDRESS"
    log_message "ERROR: Metrics script not found: $METRICS_SCRIPT"
    exit 1
fi

if [ ! -x "$METRICS_SCRIPT" ]; then
    echo "Error: Metrics script $METRICS_SCRIPT is not executable" | mail -s "ERROR: Metrics Script Not Executable" "$EMAIL_ADDRESS"
    log_message "ERROR: Metrics script not executable: $METRICS_SCRIPT"
    exit 1
fi

# Run the system metrics script and capture output
log_message "Running metrics script: $METRICS_SCRIPT"
if ! "$METRICS_SCRIPT" > "$OUTPUT_FILE" 2>&1; then
    echo "Error: Failed to run metrics script $METRICS_SCRIPT" | mail -s "ERROR: Metrics Script Failed" "$EMAIL_ADDRESS"
    log_message "ERROR: Metrics script execution failed"
    exit 1
fi

# Check if output file was created and has content
if [ ! -f "$OUTPUT_FILE" ]; then
    echo "Error: Output file $OUTPUT_FILE was not created" | mail -s "ERROR: No Metrics Output" "$EMAIL_ADDRESS"
    log_message "ERROR: Output file was not created"
    exit 1
fi

if [ ! -s "$OUTPUT_FILE" ]; then
    echo "Warning: Output file $OUTPUT_FILE is empty" | mail -s "WARNING: Empty Metrics Output" "$EMAIL_ADDRESS"
    log_message "WARNING: Output file is empty"
    exit 1
fi

# Email the metrics output
log_message "Sending metrics report to $EMAIL_ADDRESS"
if cat "$OUTPUT_FILE" | mail -s "$SUBJECT" "$EMAIL_ADDRESS"; then
    log_message "Successfully sent metrics report to $EMAIL_ADDRESS"
else
    log_message "ERROR: Failed to send email"
    exit 1
fi

# Cleanup will happen automatically due to the trap
log_message "System metrics email script completed successfully"