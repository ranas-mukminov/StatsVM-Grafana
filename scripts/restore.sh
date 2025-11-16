#!/bin/bash

# Restore script for monitoring stack
# This script restores Grafana dashboards and Prometheus data from backup

set -e

BACKUP_DIR="${BACKUP_DIR:-./backups}"

# Check if backup path is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <backup-path>"
    echo ""
    echo "Available backups:"
    ls -1d "$BACKUP_DIR"/backup-* 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_PATH="$1"

# Check if backup exists
if [ ! -d "$BACKUP_PATH" ]; then
    echo "Error: Backup directory not found: $BACKUP_PATH"
    exit 1
fi

echo "Starting restore process..."
echo "Restoring from: $BACKUP_PATH"
echo ""

# Display backup manifest if available
if [ -f "$BACKUP_PATH/manifest.txt" ]; then
    echo "Backup details:"
    cat "$BACKUP_PATH/manifest.txt"
    echo ""
fi

# Confirm restore
read -p "Are you sure you want to restore from this backup? [y/N] " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restore cancelled."
    exit 1
fi

# Stop services before restore
echo "Stopping services..."
docker-compose down

# Restore Grafana data
if [ -f "$BACKUP_PATH/grafana-backup.tar.gz" ]; then
    echo "Restoring Grafana data..."
    docker-compose up -d grafana
    sleep 5
    docker cp "$BACKUP_PATH/grafana-backup.tar.gz" grafana:/tmp/grafana-backup.tar.gz
    docker exec grafana tar xzf /tmp/grafana-backup.tar.gz -C /var/lib/grafana
    docker exec grafana rm /tmp/grafana-backup.tar.gz
    docker-compose restart grafana
    echo "✓ Grafana restore complete"
else
    echo "⚠ Grafana backup not found, skipping..."
fi

# Restore Prometheus data
if [ -f "$BACKUP_PATH/prometheus-backup.tar.gz" ]; then
    echo "Restoring Prometheus data..."
    docker-compose up -d prometheus
    sleep 5
    docker cp "$BACKUP_PATH/prometheus-backup.tar.gz" prometheus:/tmp/prometheus-backup.tar.gz
    docker exec prometheus tar xzf /tmp/prometheus-backup.tar.gz -C /prometheus
    docker exec prometheus rm /tmp/prometheus-backup.tar.gz
    docker-compose restart prometheus
    echo "✓ Prometheus restore complete"
else
    echo "⚠ Prometheus backup not found, skipping..."
fi

# Restore Loki data
if [ -f "$BACKUP_PATH/loki-backup.tar.gz" ]; then
    echo "Restoring Loki data..."
    docker-compose up -d loki
    sleep 5
    docker cp "$BACKUP_PATH/loki-backup.tar.gz" loki:/tmp/loki-backup.tar.gz
    docker exec loki tar xzf /tmp/loki-backup.tar.gz -C /loki
    docker exec loki rm /tmp/loki-backup.tar.gz
    docker-compose restart loki
    echo "✓ Loki restore complete"
else
    echo "⚠ Loki backup not found, skipping..."
fi

# Restore configuration files
if [ -f "$BACKUP_PATH/config-backup.tar.gz" ]; then
    echo "Restoring configuration files..."
    read -p "This will overwrite current configuration files. Continue? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        tar xzf "$BACKUP_PATH/config-backup.tar.gz"
        echo "✓ Configuration restore complete"
    else
        echo "⚠ Configuration restore skipped"
    fi
else
    echo "⚠ Configuration backup not found, skipping..."
fi

# Start all services
echo ""
echo "Starting all services..."
docker-compose up -d

echo ""
echo "✓ Restore completed successfully!"
echo ""
echo "Services should be available at:"
echo "  - Grafana: http://localhost:3000"
echo "  - Prometheus: http://localhost:9090"
echo "  - Alertmanager: http://localhost:9093"
