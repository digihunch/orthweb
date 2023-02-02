#! /bin/bash
echo "Entering userdata1 script"
## Install required packages and SSM agent.
yum update -y
yum install docker git jq openssl11 -y
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

runuser -l ec2-user -c " 
  cd /home/ec2-user/ && git init orthweb && cd orthweb && \
  git remote add origin https://github.com/digihunch/orthweb.git && \
  git config core.sparsecheckout true && \
  echo 'app/*' >> .git/info/sparse-checkout && \
  git pull --depth=1 origin main 
"
cd /home/ec2-user/orthweb/app

## configure self-signed certificate for compute-1.amazonaws.com
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
IssuerComName=issuer.orthweb.digihunch.com
ServerComName=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname|cut -d. -f2-`
ClientComName=dcmclient.orthweb.digihunch.com

# Generate a key pair for Test CA. Generate the certificate for Test CA by self-signing its own public key
openssl11 req -x509 -sha256 -newkey rsa:4096 -days 365 -nodes -subj /C=CA/ST=Ontario/L=Waterloo/O=Digihunch/OU=Imaging/CN=$IssuerComName/emailAddress=info@digihunch.com -keyout /tmp/ca.key -out /tmp/ca.crt

# Generate a key pair for the (DICOM) server. Generate the certificate for the server by signing its public key with Test CA's private key
openssl11 req -new -newkey rsa:4096 -nodes -subj /C=CA/ST=Ontario/L=Waterloo/O=Digihunch/OU=Imaging/CN=$ServerComName/emailAddress=orthweb@digihunch.com -addext extendedKeyUsage=serverAuth -addext subjectAltName=DNS:orthweb.digihunch.com,DNS:$IssuerComName -keyout /tmp/server.key -out /tmp/server.csr
openssl11 x509 -req -sha256 -days 365 -in /tmp/server.csr -CA /tmp/ca.crt -CAkey /tmp/ca.key -set_serial 01 -out /tmp/server.crt
cat /tmp/server.key /tmp/server.crt /tmp/ca.crt > $ServerComName.pem 

chown ec2-user:ec2-user $ServerComName.pem
echo SITE_KEY_CERT_FILE=$ServerComName.pem > .env

# Generate a key pair for the (DICOM) client. Generate the certificate for the client by signing its public key with Test CA's private key
openssl11 req -new -newkey rsa:4096 -nodes -subj /C=CA/ST=Ontario/L=Waterloo/O=Digihunch/OU=Imaging/CN=$ClientComName/emailAddress=dcmclient@digihunch.com -keyout /tmp/client.key -out /tmp/client.csr
openssl11 x509 -req -sha256 -days 365 -in /tmp/client.csr -CA /tmp/ca.crt -CAkey /tmp/ca.key -set_serial 01 -out /tmp/client.crt

# The client key and certificate will be used by client only.
chown ec2-user:ec2-user /tmp/*.crt /tmp/*.key


echo "Leaving userdata1 script"
