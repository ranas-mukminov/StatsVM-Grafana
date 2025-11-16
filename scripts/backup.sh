#!/bin/bash

# Backup script for monitoring stack
# This script backs up Grafana dashboards and Prometheus data

set -e

BACKUP_DIR="${BACKUP_DIR:-./backups}"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/backup-$DATE"

echo "Starting backup process..."
echo "Backup directory: $BACKUP_PATH"

# Create backup directory
mkdir -p "$BACKUP_PATH"

# Backup Grafana data
echo "Backing up Grafana data..."
if docker ps | grep -q grafana; then
    docker exec grafana tar czf /tmp/grafana-backup.tar.gz -C /var/lib/grafana . 2>/dev/null || true
    docker cp grafana:/tmp/grafana-backup.tar.gz "$BACKUP_PATH/grafana-backup.tar.gz"
    docker exec grafana rm /tmp/grafana-backup.tar.gz
    echo "✓ Grafana backup complete"
else
    echo "⚠ Grafana container not running, skipping..."
fi

# Backup Prometheus data
echo "Backing up Prometheus data..."
if docker ps | grep -q prometheus; then
    docker exec prometheus tar czf /tmp/prometheus-backup.tar.gz -C /prometheus . 2>/dev/null || true
    docker cp prometheus:/tmp/prometheus-backup.tar.gz "$BACKUP_PATH/prometheus-backup.tar.gz"
    docker exec prometheus rm /tmp/prometheus-backup.tar.gz
    echo "✓ Prometheus backup complete"
else
    echo "⚠ Prometheus container not running, skipping..."
fi

# Backup Loki data
echo "Backing up Loki data..."
if docker ps | grep -q loki; then
    docker exec loki tar czf /tmp/loki-backup.tar.gz -C /loki . 2>/dev/null || true
    docker cp loki:/tmp/loki-backup.tar.gz "$BACKUP_PATH/loki-backup.tar.gz"
    docker exec loki rm /tmp/loki-backup.tar.gz
    echo "✓ Loki backup complete"
else
    echo "⚠ Loki container not running, skipping..."
fi

# Backup configuration files
echo "Backing up configuration files..."
tar czf "$BACKUP_PATH/config-backup.tar.gz" \
    prometheus/ \
    loki/ \
    grafana/provisioning/ \
    docker-compose*.yml \
    2>/dev/null || true
echo "✓ Configuration backup complete"

# Create backup manifest
cat > "$BACKUP_PATH/manifest.txt" << EOF
Backup created: $(date)
Hostname: $(hostname)
Backup contents:
- Grafana data
- Prometheus data
- Loki data
- Configuration files
EOF

echo ""
echo "✓ Backup completed successfully!"
echo "Backup location: $BACKUP_PATH"
echo ""

# Cleanup old backups (keep last 7 days)
echo "Cleaning up old backups..."
find "$BACKUP_DIR" -type d -name "backup-*" -mtime +7 -exec rm -rf {} \; 2>/dev/null || true
echo "✓ Cleanup complete"

# Optional: Upload to remote storage
# Uncomment and configure for your cloud storage
# if command -v aws &> /dev/null; then
#     echo "Uploading to S3..."
#     aws s3 sync "$BACKUP_PATH" "s3://your-bucket/monitoring-backups/backup-$DATE/"
#     echo "✓ Upload complete"
# fi

echo ""
echo "Backup summary:"
du -sh "$BACKUP_PATH"
