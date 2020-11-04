#! /bin/bash
echo "Entering custom script"
su ec2-user -c "
  cd /home/ec2-user/
  git init orthweb && cd orthweb
  git remote add origin https://github.com/digihunch/orthweb.git
  git config core.sparsecheckout true
  echo 'docker/*' >> .git/info/sparse-checkout
  git pull --depth=1 origin main 
  cd docker
  sed -i -e 's/host\.docker\.internal/$(cat /tmp/db.host)/g' orthanc.json
  docker-compose up
"
echo "Leaving custom script"
