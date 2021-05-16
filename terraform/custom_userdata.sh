#! /bin/bash
echo "Entering custom script"
ComName=`curl -s http://169.254.169.254/latest/meta-data/public-hostname|cut -d. -f2-`
echo Hey$ComName
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/private.key -out /tmp/certificate.crt -subj /C=CA/ST=Ontario/L=Waterloo/O=Digihunch/OU=Imaging/CN=$ComName/emailAddress=info@digihunch.com

runuser -l ec2-user -c " 
  cd /home/ec2-user/ && git init orthweb && cd orthweb && \
  git remote add origin https://github.com/digihunch/orthweb.git && \
  git config core.sparsecheckout true && \
  echo 'docker/*' >> .git/info/sparse-checkout && \
  git pull --depth=1 origin main 
"
cd /home/ec2-user/orthweb/docker
cat /tmp/private.key /tmp/certificate.crt > $ComName.pem && rm /tmp/private.key /tmp/certificate.crt
chown ec2-user:ec2-user $ComName.pem
sed -i -e 's/sample\.localhost\.pem/'$ComName'.pem/g' docker-compose.yml

runuser -l ec2-user -c "
  cd /home/ec2-user/orthweb/docker && docker-compose up
"

echo "Leaving custom script"
