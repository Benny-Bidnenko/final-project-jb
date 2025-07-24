#!/bin/bash

# Update the system
yum update -y

# Install Docker
yum install -y docker

# Start Docker service
systemctl start docker
systemctl enable docker

# Add user to docker group
usermod -a -G docker ${username}

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create symlink for docker compose command
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Install Docker Compose plugin (for newer syntax)
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Verify installations
docker --version
docker-compose --version
docker compose version

# Create a test file to verify the installation completed
echo "Docker installation completed on $(date)" > /home/${username}/docker_install_complete.txt
chown ${username}:${username} /home/${username}/docker_install_complete.txt

# Log installation completion
echo "$(date): Docker and Docker Compose installation completed successfully" >> /var/log/user-data.log
