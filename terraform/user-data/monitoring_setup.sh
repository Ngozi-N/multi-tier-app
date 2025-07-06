#!/bin/bash
sudo apt update -y

# Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu # Assuming default ubuntu user
sudo systemctl start docker
sudo systemctl enable docker

# Create directories for Prometheus and Grafana configurations
mkdir -p /opt/prometheus/config /opt/prometheus/data /opt/grafana/data /opt/grafana/provisioning/dashboards /opt/grafana/provisioning/datasources

# Copy Prometheus configuration (assuming it will be placed later by Jenkins/manual)
# For initial setup, we'll create a basic one. This will be updated later.
sudo bash -c 'cat <<EOF > /opt/prometheus/config/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"] # Monitoring server itself

# The following targets will be dynamically added or added via file_sd_configs later
# - job_name: "jenkins"
#   static_configs:
#     - targets: ["<JENKINS_PRIVATE_IP>:9100"] # Replace with Jenkins IP and Node Exporter port
# - job_name: "frontend"
#   static_configs:
#     - targets: ["<FRONTEND_PRIVATE_IP>:9100"]
# - job_name: "backend"
#   static_configs:
#     - targets: ["<BACKEND_PRIVATE_IP>:9100"]
EOF'

# Copy Grafana data source configuration
sudo bash -c 'cat <<EOF > /opt/grafana/provisioning/datasources/datasource.yml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
    access: proxy
    isDefault: true
    version: 1
    editable: true
EOF'

# Deploy Prometheus and Grafana using Docker Compose (or just run directly)
# For simplicity, we'll run them directly for now. In production, use compose.
# Prometheus
sudo docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /opt/prometheus/config/prometheus.yml:/etc/prometheus/prometheus.yml \
  -v /opt/prometheus/data:/prometheus \
  prom/prometheus:latest

# Grafana
sudo docker run -d \
  --name grafana \
  -p 3000:3000 \
  -v /opt/grafana/data:/var/lib/grafana \
  -v /opt/grafana/provisioning/datasources:/etc/grafana/provisioning/datasources \
  -v /opt/grafana/provisioning/dashboards:/etc/grafana/provisioning/dashboards \
  grafana/grafana:latest

# Install Node Exporter on the monitoring server itself
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin
rm -rf node_exporter-1.6.1.linux-amd64.tar.gz node_exporter-1.6.1.linux-amd64

sudo useradd --no-create-home --shell /bin/false node_exporter
sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter

sudo bash -c 'cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

echo "Prometheus, Grafana, and Node Exporter setup complete!"