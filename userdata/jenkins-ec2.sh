#!/bin/bash
set -e

# Log everything
exec > /var/log/user-data.log 2>&1

echo "Starting Jenkins setup..."

# Update system
apt update -y

# Install Java
apt install -y openjdk-21-jdk

# Create keyrings directory
mkdir -p /etc/apt/keyrings

# Add Jenkins GPG key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  | tee /etc/apt/keyrings/jenkins-keyring.asc > /dev/null

# Add Jenkins repository (THIS WAS MISSING / WRONG)
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
> /etc/apt/sources.list.d/jenkins.list

# Update again so Jenkins appears
apt update -y

# Install Jenkins
apt install -y jenkins

# Enable and start Jenkins
systemctl enable jenkins
systemctl start jenkins

echo "Jenkins setup completed"
