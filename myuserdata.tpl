#! /bin/bash
echo "Entering script myuserdata"
sudo yum update -y
sudo yum install postgresql docker git -y
sudo usermod -a -G docker ec2-user   # this allows non-root user to run docker cli command but only takes effect after current user session
sudo systemctl start docker
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "Leaving script myuserdata"
