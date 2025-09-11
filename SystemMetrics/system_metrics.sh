#!/bin/bash

# System Metrics Collection Script
# This script collects various system metrics and saves them to a file

# Set output file with timestamp
# OUTPUT_FILE="/home/kimaren/Projects/MiniProjects/SystemMetrics/system_metrics_$(date +%Y%m%d_%H%M%S).txt"

# Function to  add sectoin headers
add_section_header() {
    echo "============================================="
    echo "$1"
    echo "============================================="
    echo 
}

# Start creating the metrics file
echo "System Metrics Report"
echo "Generated on: $(date)"
echo 

# System Information
add_section_header "SYSTEM INFORMATION"
echo "Hostname: $(hostname)" 
echo "Kernel Version: $(uname -r)" 
echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Architecture: $(uname -m)" 
echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
echo 

# CPU Information
add_section_header "CPU INFORMATION"
echo "CPU Model: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d':' -f2 | xargs)"
echo "CPU Cores: $(nproc)"
echo "CPU Usage:"
top -bn1 | grep "Cpu(s)"
echo

# Memory Information
add_section_header "MEMORY INFORMATION"
free -h
echo
echo "Memory Usage Percentage:"
echo "$(free | grep Mem | awk '{printf "Used: %.1f%% (%.1fGB/%.1fGB)\n", $3/$2 * 100.0, $3/1024/1024, $2/1024/1024}')"
echo

# Disk Usage
add_section_header "DISK USAGE"
df -h
echo
echo "Disk I/0 Statistics:"
iostat -x 1 1 2>/dev/null || echo "iostat not available (install systat package)"
echo 

# Network Information
add_section_header "NETWORK INFORMATION"
echo "Network Interfaces:"
ip addr show 2>/dev/null | grep -E "^[0-9]+:" | awk '{print $2}' | sed 's/:$//' || ifconfig -a 2>/dev/null | grep -E "^[a-zA-Z0-9]+:" | awk '{print $1}' | sed 's/:$//'
echo 
echo "Network Statistics:"
ss -tuln 2>/dev/null || netstat -tuln 2>/dev/null || echo "Network tools are no available" 
echo

# Process Information
add_section_header "PROCESS INFORMATION"
echo "Running Processes: $(ps aux | wc -l)"
echo
echo "Top 10 CPU-consuming processes:"
ps aux --sort=-%cpu | head -11
echo
echo "Top 10 Memory-consuming processes:"
ps aux --sort=-%mem | head -11
echo

# Load Average
add_section_header "SYSTEM LOAD"
echo "Load Average: $(cat /proc/loadavg)"
echo "Explanation: 1min 5min 15min running/total_processes last_pid"
echo

# Temperature (if available)
add_section_header "SYSTEM TEMPERATURE"
if command -v sensors >/dev/null 2>&1; then
    sensors 2>/dev/null
else
    echo "Temperature sensors not available (install lm-sensors package)"
fi
echo

# Users and Sessions
add_section_header "USER SESSIONS"
who
echo
echo "Last logins:" 
last -n 10
echo

# System Services (if systemctl is available)
add_section_header "SYSTEM SERVICES STATUS"
if command -v systemctl >/dev/null 2>&1; then
    echo "Failed services:"
    systemctl list-units --failed 
    echo
    echo "Active services count: $(systemctl list-units --type=service --state=active | wc -l)"
else
    echo "systemctl not available"
fi
echo 

# Completion message
echo "System metrics report completed at: $(date)"

# Make the script executable and run it
# echo "System metrics have been collected and saved to: $OUTPUT_FILE"
# echo "File size: $(ls -lh "$OUTPUT_FILE" | awk '{print $5}')"
echo ""  
