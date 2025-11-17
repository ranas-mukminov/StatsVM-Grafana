# Migration Guide: From Vagrant to Docker Compose

This guide helps you migrate from the old Vagrant-based setup to the new modern Docker Compose stack.

## 🔄 What Changed

### Architecture Changes

| Old Stack | New Stack | Benefits |
|-----------|-----------|----------|
| Vagrant | Docker Compose / Podman | Faster, lighter, cloud-native |
| Graphite | Prometheus | Modern metrics, better querying |
| StatsD | Prometheus Exporters | Native integration |
| Elasticsearch | Loki | Simpler, log-focused |
| Apache | Not needed | Services are containerized |

### Port Changes

| Service | Old Port | New Port |
|---------|----------|----------|
| Grafana | 80 | 3000 |
| Graphite | 80 | N/A (replaced by Prometheus on 9090) |
| Elasticsearch | 9200 | N/A (replaced by Loki on 3100) |
| StatsD | 8125 | N/A (use Prometheus exporters) |

## 📋 Migration Steps

### Step 1: Backup Your Old Data

If you have existing Grafana dashboards on the old system:

```bash
# SSH into old Vagrant VM
vagrant ssh

# Export dashboards (manual export via Grafana UI recommended)
# Or backup the SQLite database
sudo cp /opt/graphite/storage/graphite.db ~/graphite-backup.db
```

### Step 2: Export Grafana Dashboards

1. Log into old Grafana at http://grafana.dev
2. Go to each dashboard
3. Click "Share" → "Export" → "Save to file"
4. Save all dashboard JSON files

### Step 3: Stop Old Vagrant VM

```bash
vagrant halt
# Optional: remove VM completely
vagrant destroy
```

### Step 4: Install New Stack

```bash
# Clone or update repository
git pull origin main

# Start new stack
docker compose up -d

# Or with Make
make start
```

### Step 5: Import Old Dashboards

1. Access new Grafana at http://localhost:3000 (admin/admin)
2. Go to Dashboards → Import
3. Upload each saved dashboard JSON
4. Update data sources to use Prometheus instead of Graphite

### Step 6: Migrate Metrics Collection

#### From StatsD to Prometheus

**Old way (StatsD):**
```bash
echo "accounts.authentication.login.attempted:1|c" | nc -w0 -u 192.168.56.108 8125
```

**New way (Prometheus with bot exporter):**
```python
from prometheus_client import Counter

login_attempts = Counter('login_attempts_total', 'Login attempts')
login_attempts.inc()
```

See [examples/telegram-bot-exporter/](examples/telegram-bot-exporter/) for detailed examples.

## 🔄 Query Translation Guide

### Graphite to Prometheus

| Graphite Query | Prometheus Equivalent |
|----------------|----------------------|
| `stats.counts.app.requests` | `rate(app_requests_total[5m])` |
| `stats.timers.app.response_time.mean` | `avg(app_response_time_seconds)` |
| `aliasByNode(stats.*.count, 1)` | Use labels: `{app="name"}` |

### Common Conversions

**CPU Usage:**
```promql
# Prometheus
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Memory Usage:**
```promql
# Prometheus
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100
```

**Network Traffic:**
```promql
# Prometheus
rate(node_network_receive_bytes_total[5m])
```

## 🎯 New Features Available

### 1. Alerting

The new stack has built-in alerting:

```yaml
# Add custom alerts in prometheus/alerts/
- alert: HighErrorRate
  expr: rate(errors_total[5m]) > 10
  for: 5m
  annotations:
    summary: "High error rate detected"
```

### 2. Log Aggregation with Loki

```bash
# Query logs via Grafana or CLI
logcli query '{job="app"}'
```

### 3. Multiple Deployment Options

- Docker Compose (development)
- Podman with SystemD (production on Arch Linux)
- Kubernetes with Helm
- Terraform for infrastructure as code

### 4. Automated Backups

```bash
# Backup all data
make backup

# Restore from backup
make restore
```

## 🔧 Configuration Migration

### Environment Variables

Create a `.env` file based on `.env.example`:

```bash
cp .env.example .env
# Edit .env with your settings
```

### Custom Dashboards

Place your dashboard JSON files in:
```
grafana/provisioning/dashboards/json/
```

They will be automatically imported on startup.

## 🐛 Troubleshooting

### Services Won't Start

```bash
# Check logs
make logs

# Check individual service
docker compose logs grafana
```

### Old Port Conflicts

If you still have Vagrant running:
```bash
vagrant halt
# or
vagrant destroy
```

### Data Not Showing

1. Check Prometheus targets: http://localhost:9090/targets
2. Verify data sources in Grafana
3. Ensure exporters are configured correctly

### Performance Issues

The new stack is much lighter, but if you have issues:

```bash
# Check resource usage
docker stats

# Adjust retention in prometheus/prometheus.yml
storage.tsdb.retention.time=15d  # Reduce if needed
```

## 📚 Additional Resources

- [Prometheus Query Documentation](https://prometheus.io/docs/prometheus/latest/querying/basics/)
- [Grafana Dashboard Best Practices](https://grafana.com/docs/grafana/latest/dashboards/)
- [Loki Query Language](https://grafana.com/docs/loki/latest/logql/)

## 💬 Getting Help

If you encounter issues:

1. Check the logs: `make logs`
2. Run health checks: `make health`
3. Validate configs: `make validate`
4. Review the [README.md](README.md)
5. Open an issue on GitHub

## ✅ Verification Checklist

After migration, verify:

- [ ] All services are running: `docker compose ps`
- [ ] Grafana is accessible: http://localhost:3000
- [ ] Prometheus is scraping targets: http://localhost:9090/targets
- [ ] Dashboards are imported and working
- [ ] Alerts are configured
- [ ] Backups are scheduled
- [ ] Old Vagrant VM is stopped/removed

## 🎉 Next Steps

1. Customize dashboards for your use case
2. Set up alerting notifications
3. Configure backup automation
4. Explore Loki for log aggregation
5. Consider deploying to production with Kubernetes or Podman
