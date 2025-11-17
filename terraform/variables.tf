variable "docker_host" {
  description = "Docker host connection string"
  type        = string
  default     = "unix:///var/run/docker.sock"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "grafana_port" {
  description = "Grafana external port"
  type        = number
  default     = 3000
}

variable "prometheus_port" {
  description = "Prometheus external port"
  type        = number
  default     = 9090
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "30d"
}

variable "loki_port" {
  description = "Loki external port"
  type        = number
  default     = 3100
}

variable "node_exporter_port" {
  description = "Node Exporter external port"
  type        = number
  default     = 9100
}

variable "alertmanager_port" {
  description = "Alertmanager external port"
  type        = number
  default     = 9093
}
