#! /bin/bash
echo "Entering userdata1 script"
### Install required packages and SSM agent.
yum update -y
yum install docker git jq -y

# Configure Docker Compose V2 as a docker plugin so we can run docker compose subcommand
mkdir -p /usr/local/lib/docker/cli-plugins/
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

usermod -a -G docker ec2-user   
systemctl restart docker          ## Configure Docker daemon
chmod 666 /var/run/docker.sock    ## Allow non-root user to run docker cli 

### Create new user in line with the envoy user in envoy proxy's image. Then we create a directroy on host with owner's uid/gid identical
### to the uid/gid of main process in envoy container. This will allow us to map host directory for container to write logs to a host directory (in addition to stdout). 
### We also set ACL to allow ec2-user on the host to read/execute in envoy user's directory, for the convenience of ec2-user.
#groupadd -g 101 envoy
#useradd envoy -u 101 -g 101 -m
#runuser -l envoy -c "
#  setfacl -m u:ec2-user:rx /home/envoy
#"
#
#
runuser -l ec2-user -c "
  cd ~
  git clone --depth 1 https://github.com/digihunchinc/orthanc-config.git
  cd orthanc-config
"
#cd /home/ec2-user/orthweb/app
#
### configure self-signed certificate for compute-1.amazonaws.com
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`

ServerComName=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname|cut -d. -f2-`



echo "Leaving userdata1 script"
