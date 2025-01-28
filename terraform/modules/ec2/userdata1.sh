#! /bin/bash
echo "Entering userdata1 script"
### Install required packages and SSM agent.
yum update -y
yum install -y git make docker jq postgresql16

# Configure Docker Compose V2 as a docker plugin so we can run docker compose subcommand
mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

usermod -a -G docker ec2-user   
systemctl restart docker          ## Configure Docker daemon
chmod 666 /var/run/docker.sock    ## Allow non-root user to run docker cli 

# Install yq
curl -SL https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -o /usr/bin/yq
chmod +x /usr/bin/yq

echo "Leaving userdata1 script"
