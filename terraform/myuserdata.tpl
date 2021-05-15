#! /bin/bash
echo "Entering script myuserdata"
yum update -y
yum install postgresql docker git jq -y

# Configure docker
usermod -a -G docker ec2-user   
# this allows non-root user to run docker cli command but only takes effect after current user session
systemctl restart docker
chmod 666 /var/run/docker.sock
docker swarm init


# Configure docker-compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose


# Load app config
echo "local user"
runuser -l ec2-user -c 'aws configure set region ${aws_region}'
runuser -l ec2-user -c 'echo sm_endpoint ${sm_endpoint}'
runuser -l ec2-user -c 'echo sec_name ${sec_name}'

runuser -l ec2-user -c 'echo ${db_endpoint} | docker config create db_ep -'
runuser -l ec2-user -c 'aws secretsmanager get-secret-value --secret-id ${sec_name} --query SecretString --output text --endpoint-url https://${sm_endpoint} | jq -r .username | docker secret create db_un -'
runuser -l ec2-user -c 'aws secretsmanager get-secret-value --secret-id ${sec_name} --query SecretString --output text --endpoint-url https://${sm_endpoint} | jq -r .password | docker secret create db_pw -'

echo "Leaving script myuserdata"
