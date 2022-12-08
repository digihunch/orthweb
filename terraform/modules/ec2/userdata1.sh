#! /bin/bash
echo "Entering userdata1 script"
## Install required packages and SSM agent.
yum update -y
yum install postgresql docker git jq openssl11 -y
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm

## Configure Docker daemon
usermod -a -G docker ec2-user   
# this allows non-root user to run docker cli command but only takes effect after current user session

# Tell docker bridge to use an address pool other than 172.17.x.x, which is in conflict with our VPC's CIDR
cat << EOF > /etc/docker/daemon.json
{
  "default-address-pools":
  [
    {"base":"10.10.0.0/16","size":24}
  ]
}
EOF

systemctl restart docker
chmod 666 /var/run/docker.sock

## Configure Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## Create new user in line with the envoy user in envoy proxy's image
groupadd -g 101 envoy
useradd envoy -u 101 -g 101 -m
runuser -l envoy -c "
  setfacl -m u:ec2-user:rx /home/envoy
"
# we create a directroy on host with owner's uid/gid identical to the uid/gid of main process in envoy container. This will allow us to map host directory for container to write logs to a host directory (in addition to stdout). We also set ACL to allow ec2-user on the host to read/execute in envoy user's directory, for the convenience of ec2-user.

## configure self-signed certificate for compute-1.amazonaws.com
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
ComName=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname|cut -d. -f2-`

openssl11 req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/private.key -out /tmp/certificate.crt -subj /C=CA/ST=Ontario/L=Waterloo/O=Digihunch/OU=Imaging/CN=$ComName/emailAddress=info@digihunch.com -addext extendedKeyUsage=serverAuth -addext subjectAltName=DNS:orthweb.digihunch.com,DNS:$ComName

runuser -l ec2-user -c " 
  cd /home/ec2-user/ && git init orthweb && cd orthweb && \
  git remote add origin https://github.com/digihunch/orthweb.git && \
  git config core.sparsecheckout true && \
  echo 'app/*' >> .git/info/sparse-checkout && \
  git pull --depth=1 origin main 
"
cd /home/ec2-user/orthweb/app
cat /tmp/private.key /tmp/certificate.crt > $ComName.pem && rm /tmp/private.key /tmp/certificate.crt
chown ec2-user:ec2-user $ComName.pem
echo SITE_KEY_CERT_FILE=$ComName.pem > .env


echo "Leaving userdata1 script"
