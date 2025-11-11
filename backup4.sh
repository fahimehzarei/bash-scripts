#!/bin/bash

# ==========================
# SSH Backup & Transfer Script (with source/destination info)

# ==========================

# === Configuration ===
SOURCE_DIR="/home/username/testdata"       # Folder to back up
BACKUP_DIR="/home/username/backups"        # Local backup folder
REMOTE_USER="vagrant"
REMOTE_HOST="255.255.255.255"               # Destination server (Server B)
REMOTE_DIR="/home/username/received_backup"
LOG_FILE="/home/username/backup.log"

# === Timestamp ===
DATE=$(date +'%Y-%m-%d_%H-%M-%S')
BACKUP_FILE="backup_${DATE}.tar.gz"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_FILE}"

# === Identify current host ===
CURRENT_HOST=$(hostname)
echo "----------------------------------------" >> "$LOG_FILE"
echo "[$(date)] Running on host: ${CURRENT_HOST}" >> "$LOG_FILE"
echo "[$(date)] Backup source: ${SOURCE_DIR}" >> "$LOG_FILE"
echo "[$(date)] Remote target: ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}" >> "$LOG_FILE"

# === Ensure backup folder exists ===
mkdir -p "$BACKUP_DIR"

# === Create compressed backup ===
echo "[$(date)] Creating backup archive..." >> "$LOG_FILE"
tar -czf "$BACKUP_PATH" -C "$SOURCE_DIR" . >> "$LOG_FILE" 2>&1

# === Verify backup file ===
if [ ! -f "$BACKUP_PATH" ]; then
    echo "[$(date)] ❌ Error: Backup file not created!" >> "$LOG_FILE"
    exit 1
fi

# === Transfer backup to remote server ===
echo "[$(date)] Transferring backup to ${REMOTE_HOST}..." >> "$LOG_FILE"
rsync -avz -e "ssh -o StrictHostKeyChecking=no" "$BACKUP_PATH" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/" >> "$LOG_FILE" 2>&1

# === Cleanup old backups (older than 7 days) ===
find "$BACKUP_DIR" -type f -mtime +7 -name "*.tar.gz" -exec rm {} \;

# === Done ===
echo "[$(date)] ✅ Backup complete: ${BACKUP_FILE}" >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"
