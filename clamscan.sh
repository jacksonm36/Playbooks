#!/bin/bash

# ─── CONFIG ─────────────────────────────────────────────────────────────
SCAN_PATHS=(
  "/opt"
  "/etc"
  "/var/tmp"
  "/usr/local/bin"
  "/home"
  "/tmp"           # Common drop zone for malware
  "/dev/shm"       # Shared memory, often abused for in-memory payloads
  "/root"          # Privileged user home
)
LOG_DIR="/var/log/clamav"
HOSTNAME=$(hostname)
TIMESTAMP=$(date +%F_%H-%M-%S)
REPORT_FILE="$LOG_DIR/scan_${HOSTNAME}_$TIMESTAMP.log"
SUMMARY_FILE="$LOG_DIR/summary_${HOSTNAME}_$TIMESTAMP.log"

# ─── PREP ───────────────────────────────────────────────────────────────
mkdir -p "$LOG_DIR"
echo "[+] Host: $HOSTNAME" | tee "$SUMMARY_FILE"
echo "[+] Timestamp: $TIMESTAMP" | tee -a "$SUMMARY_FILE"
echo "[+] Updating ClamAV signatures..." | tee -a "$SUMMARY_FILE"
freshclam >> "$SUMMARY_FILE" 2>&1

# ─── SCAN ───────────────────────────────────────────────────────────────
echo "[+] Starting scan..." | tee -a "$SUMMARY_FILE"
TOTAL_INFECTED=0
TOTAL_SCANNED=0

for path in "${SCAN_PATHS[@]}"; do
    echo "[*] Scanning $path..." | tee -a "$REPORT_FILE"
    clamscan -r -i "$path" >> "$REPORT_FILE"
    
    INFECTED=$(grep "Infected files:" "$REPORT_FILE" | tail -1 | awk '{print $3}')
    SCANNED=$(grep "Scanned files:" "$REPORT_FILE" | tail -1 | awk '{print $3}')
    
    echo "→ $path: $SCANNED scanned, $INFECTED infected" | tee -a "$SUMMARY_FILE"
    TOTAL_INFECTED=$((TOTAL_INFECTED + INFECTED))
    TOTAL_SCANNED=$((TOTAL_SCANNED + SCANNED))
done

# ─── SUMMARY ────────────────────────────────────────────────────────────
echo "[+] Final Summary:" | tee -a "$SUMMARY_FILE"
echo "Total scanned files: $TOTAL_SCANNED" | tee -a "$SUMMARY_FILE"
echo "Total infected files: $TOTAL_INFECTED" | tee -a "$SUMMARY_FILE"
echo "Full report: $REPORT_FILE" | tee -a "$SUMMARY_FILE"

# ─── OPTIONAL NOTIFY ────────────────────────────────────────────────────
# mail -s "ClamAV Scan Report from $HOSTNAME" you@example.com < "$SUMMARY_FILE"
