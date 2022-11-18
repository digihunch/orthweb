#! /bin/bash
echo "Entering userdata1 script"
yum update -y
yum install postgresql docker git jq openssl11 -y

# Configure docker
usermod -a -G docker ec2-user   
# this allows non-root user to run docker cli command but only takes effect after current user session

# Tell docker bridge to use a address pool than 172.17.x.x 
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

# Configure docker-compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# configure self-signed certificate
ComName=`curl -s http://169.254.169.254/latest/meta-data/public-hostname|cut -d. -f2-`
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
