terraform {
  required_version = ">= 1.0"
  
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {
  host = var.docker_host
}

# Network
resource "docker_network" "monitoring" {
  name = "monitoring-network"
  
  labels {
    label = "project"
    value = "monitoring-stack"
  }
}

# Volumes
resource "docker_volume" "prometheus_data" {
  name = "prometheus-data"
}

resource "docker_volume" "grafana_data" {
  name = "grafana-data"
}

resource "docker_volume" "loki_data" {
  name = "loki-data"
}

resource "docker_volume" "alertmanager_data" {
  name = "alertmanager-data"
}

# Prometheus
resource "docker_image" "prometheus" {
  name = "prom/prometheus:latest"
}

resource "docker_container" "prometheus" {
  name  = "prometheus"
  image = docker_image.prometheus.image_id
  
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.monitoring.name
  }
  
  ports {
    internal = 9090
    external = var.prometheus_port
  }
  
  volumes {
    volume_name    = docker_volume.prometheus_data.name
    container_path = "/prometheus"
  }
  
  upload {
    file    = "/etc/prometheus/prometheus.yml"
    content = file("${path.module}/../prometheus/prometheus.yml")
  }
  
  command = [
    "--config.file=/etc/prometheus/prometheus.yml",
    "--storage.tsdb.retention.time=${var.prometheus_retention}",
    "--web.enable-lifecycle"
  ]
  
  labels {
    label = "service"
    value = "prometheus"
  }
}

# Grafana
resource "docker_image" "grafana" {
  name = "grafana/grafana:latest"
}

resource "docker_container" "grafana" {
  name  = "grafana"
  image = docker_image.grafana.image_id
  
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.monitoring.name
  }
  
  ports {
    internal = 3000
    external = var.grafana_port
  }
  
  volumes {
    volume_name    = docker_volume.grafana_data.name
    container_path = "/var/lib/grafana"
  }
  
  env = [
    "GF_SECURITY_ADMIN_PASSWORD=${var.grafana_admin_password}",
    "GF_INSTALL_PLUGINS=grafana-piechart-panel"
  ]
  
  labels {
    label = "service"
    value = "grafana"
  }
  
  depends_on = [
    docker_container.prometheus,
    docker_container.loki
  ]
}

# Loki
resource "docker_image" "loki" {
  name = "grafana/loki:latest"
}

resource "docker_container" "loki" {
  name  = "loki"
  image = docker_image.loki.image_id
  
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.monitoring.name
  }
  
  ports {
    internal = 3100
    external = var.loki_port
  }
  
  volumes {
    volume_name    = docker_volume.loki_data.name
    container_path = "/loki"
  }
  
  upload {
    file    = "/etc/loki/local-config.yaml"
    content = file("${path.module}/../loki/loki-config.yml")
  }
  
  command = ["-config.file=/etc/loki/local-config.yaml"]
  
  labels {
    label = "service"
    value = "loki"
  }
}

# Node Exporter
resource "docker_image" "node_exporter" {
  name = "prom/node-exporter:latest"
}

resource "docker_container" "node_exporter" {
  name  = "node-exporter"
  image = docker_image.node_exporter.image_id
  
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.monitoring.name
  }
  
  ports {
    internal = 9100
    external = var.node_exporter_port
  }
  
  command = [
    "--path.rootfs=/host",
    "--path.procfs=/host/proc",
    "--path.sysfs=/host/sys"
  ]
  
  volumes {
    host_path      = "/"
    container_path = "/host"
    read_only      = true
  }
  
  labels {
    label = "service"
    value = "node-exporter"
  }
}

# Alertmanager
resource "docker_image" "alertmanager" {
  name = "prom/alertmanager:latest"
}

resource "docker_container" "alertmanager" {
  name  = "alertmanager"
  image = docker_image.alertmanager.image_id
  
  restart = "unless-stopped"
  
  networks_advanced {
    name = docker_network.monitoring.name
  }
  
  ports {
    internal = 9093
    external = var.alertmanager_port
  }
  
  volumes {
    volume_name    = docker_volume.alertmanager_data.name
    container_path = "/alertmanager"
  }
  
  upload {
    file    = "/etc/alertmanager/alertmanager.yml"
    content = file("${path.module}/../prometheus/alertmanager.yml")
  }
  
  command = [
    "--config.file=/etc/alertmanager/alertmanager.yml",
    "--storage.path=/alertmanager"
  ]
  
  labels {
    label = "service"
    value = "alertmanager"
  }
}
