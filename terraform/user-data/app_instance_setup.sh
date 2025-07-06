#!/bin/bash
sudo apt update -y

# Install Docker
sudo apt install -y docker.io
sudo usermod -aG docker ubuntu # Assuming default ubuntu user
sudo systemctl start docker
sudo systemctl enable docker

# Install Node Exporter for Prometheus
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvfz node_exporter-1.6.1.linux-amd64.tar.gz
sudo mv node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin
rm -rf node_exporter-1.6.1.linux-amd64.tar.gz node_exporter-1.6.1.linux-amd64

# Create a systemd service for Node Exporter
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

echo "Docker and Node Exporter setup complete!"

# This part will be dynamic, the actual application Docker image name/tag
# will be passed during launch template update. For now, it's a placeholder.
# In a Jenkins pipeline, you'd modify the launch template to include the
# Docker run command with the specific image tag from the build.

# For example, in Jenkinsfile, the user_data would be generated dynamically
# or we'd rely on a separate configuration management tool.
# A simpler approach for the user-data:
# #!/bin/bash
# # ... (docker and node exporter setup) ...
# docker stop myapp || true
# docker rm myapp || true
# docker pull ${image_name}:${image_tag}
# docker run -d --name myapp -p 80:80 ${image_name}:${image_tag}