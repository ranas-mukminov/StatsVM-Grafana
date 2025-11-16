# Podman Quadlet SystemD Integration

This directory contains Podman Quadlet unit files for running the monitoring stack with SystemD.

## Prerequisites

- Podman 4.4+
- SystemD with Quadlet support

## Installation

1. Create configuration directories:

```bash
mkdir -p ~/.config/containers/monitoring/{prometheus,loki,grafana/provisioning}
mkdir -p ~/.local/share/containers/monitoring/{prometheus,grafana,loki,alertmanager}
```

2. Copy configuration files:

```bash
cp -r prometheus/* ~/.config/containers/monitoring/prometheus/
cp -r loki/* ~/.config/containers/monitoring/loki/
cp -r grafana/provisioning ~/.config/containers/monitoring/grafana/
```

3. Copy Quadlet unit files:

```bash
# For user services
mkdir -p ~/.config/containers/systemd/
cp systemd/*.{container,network} ~/.config/containers/systemd/

# OR for system services (requires root)
sudo mkdir -p /etc/containers/systemd/
sudo cp systemd/*.{container,network} /etc/containers/systemd/
```

4. Reload SystemD and start services:

```bash
# For user services
systemctl --user daemon-reload
systemctl --user enable --now monitoring.network
systemctl --user enable --now prometheus.service
systemctl --user enable --now loki.service
systemctl --user enable --now node-exporter.service
systemctl --user enable --now alertmanager.service
systemctl --user enable --now grafana.service

# OR for system services
sudo systemctl daemon-reload
sudo systemctl enable --now monitoring.network
sudo systemctl enable --now prometheus.service
sudo systemctl enable --now loki.service
sudo systemctl enable --now node-exporter.service
sudo systemctl enable --now alertmanager.service
sudo systemctl enable --now grafana.service
```

## Managing Services

### Check status

```bash
systemctl --user status grafana.service
systemctl --user status prometheus.service
systemctl --user status loki.service
```

### View logs

```bash
journalctl --user -u grafana.service -f
journalctl --user -u prometheus.service -f
```

### Restart services

```bash
systemctl --user restart grafana.service
systemctl --user restart prometheus.service
```

### Stop services

```bash
systemctl --user stop grafana.service prometheus.service loki.service
```

### Enable auto-start at boot

```bash
loginctl enable-linger $USER
```

## Auto-updates

The containers are configured with `AutoUpdate=registry` which means they will automatically update when you run:

```bash
podman auto-update
```

You can set up a systemd timer for automatic updates:

```bash
systemctl --user enable --now podman-auto-update.timer
```

## Accessing Services

- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- Loki: http://localhost:3100

## Customization

Edit the `.container` files to customize:
- Ports
- Volumes
- Environment variables
- Resource limits

After changes, reload SystemD:

```bash
systemctl --user daemon-reload
systemctl --user restart <service>.service
```

## Troubleshooting

### Check container status

```bash
podman ps -a
```

### Inspect container

```bash
podman inspect grafana
```

### View container logs

```bash
podman logs grafana
```

### Remove and recreate

```bash
systemctl --user stop grafana.service
podman rm grafana
systemctl --user start grafana.service
```
