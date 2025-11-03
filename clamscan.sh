#!/bin/bash

# CONFIGURATION
SCAN_PATHS=("/opt" "/etc" "/var/tmp" "/usr/local/bin" "/home")
LOG_DIR="/var/log/clamav"
TIMESTAMP=$(date +%F_%H-%M-%S)
REPORT_FILE="$LOG_DIR/clamav_scan_report_$TIMESTAMP.log"
SUMMARY_FILE="$LOG_DIR/clamav_summary_$TIMESTAMP.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Update ClamAV signatures
echo "[+] Updating ClamAV signatures..."
freshclam

# Run scans
echo "[+] Starting ClamAV scan..."
for path in "${SCAN_PATHS[@]}"; do
    echo "Scanning: $path" | tee -a "$REPORT_FILE"
    clamscan -r --bell -i "$path" | tee -a "$REPORT_FILE"
done

# Extract summary
echo "[+] Generating summary..."
INFECTED=$(grep "Infected files:" "$REPORT_FILE" | awk '{sum += $3} END {print sum}')
SCANNED=$(grep "Scanned files:" "$REPORT_FILE" | awk '{sum += $3} END {print sum}')
echo "Scan completed at $(date)" > "$SUMMARY_FILE"
echo "Total scanned files: $SCANNED" >> "$SUMMARY_FILE"
echo "Total infected files: $INFECTED" >> "$SUMMARY_FILE"
echo "Full report: $REPORT_FILE" >> "$SUMMARY_FILE"

# Display summary
echo "[+] Summary:"
cat "$SUMMARY_FILE"
