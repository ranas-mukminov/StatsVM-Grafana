output "grafana_url" {
  description = "Grafana URL"
  value       = "http://localhost:${var.grafana_port}"
}

output "prometheus_url" {
  description = "Prometheus URL"
  value       = "http://localhost:${var.prometheus_port}"
}

output "alertmanager_url" {
  description = "Alertmanager URL"
  value       = "http://localhost:${var.alertmanager_port}"
}

output "loki_url" {
  description = "Loki URL"
  value       = "http://localhost:${var.loki_port}"
}

output "network_name" {
  description = "Docker network name"
  value       = docker_network.monitoring.name
}
