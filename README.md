# Modern Monitoring Stack

A modernized monitoring and observability stack using **Docker Compose** with the **LGTM** stack (Loki, Grafana, Tempo, Mimir/Prometheus).

## 🚀 What's New

This project has been **completely modernized** from the old Vagrant-based setup:

### Old Stack ❌
- Vagrant (slow, heavy)
- Graphite (outdated)
- StatsD
- Elasticsearch
- Apache

### New Stack ✅
- **Docker Compose / Podman** (fast, lightweight, cloud-native)
- **Prometheus** (modern metrics)
- **Grafana** (beautiful dashboards)
- **Loki** (log aggregation)
- **Node Exporter** (system metrics)
- **Alertmanager** (intelligent alerting)

## 📋 Prerequisites

- Docker & Docker Compose **OR** Podman
- Make (optional, but recommended)
- Git

## 🎯 Quick Start

### Option 1: Docker Compose (Recommended)

```bash
# Clone the repository
git clone https://github.com/ranas-mukminov/StatsVM-Grafana.git
cd StatsVM-Grafana

# Start the monitoring stack
make start

# Or without Make:
docker-compose up -d
```

**Access the services:**
- 🎨 **Grafana**: http://localhost:3000 (admin/admin)
- 📊 **Prometheus**: http://localhost:9090
- 🔔 **Alertmanager**: http://localhost:9093
- 📝 **Loki**: http://localhost:3100

### Option 2: Podman with SystemD (Arch Linux)

Perfect for systemd integration on Arch Linux:

```bash
# Install and configure
make install-podman

# Or manually:
mkdir -p ~/.config/containers/monitoring/{prometheus,loki,grafana/provisioning}
mkdir -p ~/.local/share/containers/monitoring/{prometheus,grafana,loki,alertmanager}

cp -r prometheus/* ~/.config/containers/monitoring/prometheus/
cp -r loki/* ~/.config/containers/monitoring/loki/
cp -r grafana/provisioning ~/.config/containers/monitoring/grafana/

cp systemd/*.{container,network} ~/.config/containers/systemd/

systemctl --user daemon-reload
systemctl --user enable --now monitoring.network
systemctl --user enable --now grafana.service prometheus.service loki.service
```

See [systemd/README.md](systemd/README.md) for detailed instructions.

### Option 3: Kubernetes with Helm

```bash
# Install with Helm
helm install monitoring ./helm/monitoring-stack -n monitoring --create-namespace

# Or with kubectl
kubectl apply -k k8s/
```

### Option 4: Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## 📚 Documentation

- [Podman/SystemD Setup](systemd/README.md)
- [Telegram Bot Exporter Example](examples/telegram-bot-exporter/README.md)
- [Helm Chart Documentation](helm/monitoring-stack/)

## 🛠️ Available Commands

```bash
make help              # Show all available commands
make start             # Start monitoring stack
make stop              # Stop monitoring stack
make restart           # Restart services
make logs              # Show logs from all services
make status            # Show status of all services
make validate          # Validate configuration files
make backup            # Backup Grafana and Prometheus data
make restore           # Restore from backup
make health            # Check health of all services
make deploy-dev        # Deploy development environment
make deploy-prod       # Deploy production environment
make test              # Run integration tests
```

## 📊 Default Dashboards

The stack comes pre-configured with:

- **System Metrics Overview**: CPU, Memory, Disk, Network
- Pre-configured datasources (Prometheus, Loki)
- Alert rules for common issues

## 🔔 Alerting

Built-in alerts for:
- Service health (Grafana, Prometheus, Loki down)
- High CPU usage (>80%)
- High memory usage (>90%)
- Low disk space (<10%)
- High disk I/O wait

## 🔧 Configuration

### Environment Variables

Create a `.env` file:

```bash
GRAFANA_PASSWORD=your_secure_password
GRAFANA_ROOT_URL=http://localhost:3000
```

### Prometheus Retention

Edit `prometheus/prometheus.yml` to adjust:
- Scrape intervals
- Retention periods
- Additional targets

### Custom Dashboards

Add JSON dashboard files to `grafana/provisioning/dashboards/json/`

## 🤖 Telegram Bot Integration

Example Prometheus exporter for Telegram bots included!

```python
from examples.telegram_bot_exporter import TelegramBotMetrics

metrics = TelegramBotMetrics(bot_name='my_bot')
metrics.record_message(chat_type='private', message_type='text')
metrics.record_command('start')
```

See [examples/telegram-bot-exporter/](examples/telegram-bot-exporter/) for details.

## 🏗️ Architecture

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│  Exporters  │───>│  Prometheus  │───>│   Grafana   │
│ (Metrics)   │    │              │    │ (Dashboards)│
└─────────────┘    └──────────────┘    └─────────────┘
                           │                    │
                           v                    v
                   ┌──────────────┐    ┌─────────────┐
                   │     Loki     │───>│Alertmanager │
                   │   (Logs)     │    │  (Alerts)   │
                   └──────────────┘    └─────────────┘
                           ^
                           │
                   ┌──────────────┐
                   │   Promtail   │
                   │(Log Collect) │
                   └──────────────┘
```

## 🔐 Security

- Change default Grafana password
- Use environment variables for secrets
- Configure Alertmanager with proper receivers
- Enable authentication on all services
- Use TLS/SSL in production

## 🚀 CI/CD

GitHub Actions workflow included:
- Validates configurations
- Tests deployment
- Security scanning with Trivy
- Automated builds (when configured)

## 📦 Backup & Restore

```bash
# Backup
make backup

# Restore
make restore
# or
./scripts/restore.sh ./backups/backup-YYYYMMDD_HHMMSS
```

## 🐛 Troubleshooting

### Check service status

```bash
make status
# or
docker-compose ps
```

### View logs

```bash
make logs
# or
docker-compose logs -f grafana
```

### Validate configuration

```bash
make validate
```

### Health check

```bash
make health
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 Migration from Old Setup

If you're migrating from the old Vagrant setup:

1. Backup your old Grafana dashboards
2. Export dashboard JSON from old Grafana
3. Place JSON files in `grafana/provisioning/dashboards/json/`
4. Start new stack with `make start`
5. Dashboards will auto-import

## 🔗 Useful Links

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Podman Quadlet](https://docs.podman.io/en/latest/markdown/podman-systemd.unit.5.html)

## 📄 License

This project is open source and available under the MIT License.

## ✨ Credits

Original project by Ranas Mukminov
Modernized with Docker Compose, Prometheus, and Loki
