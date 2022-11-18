#! /bin/bash
echo "Entering userdata3 script"

runuser -l ec2-user -c "
  cd /home/ec2-user/orthweb/app && docker-compose up
"
echo "Leaving userdata3 script"
