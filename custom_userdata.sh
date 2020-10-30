#! /bin/bash
echo "Entering custom script"
su ec2-user -c "
  cd /home/ec2-user/
  git clone https://github.com/digihunch/orthdock.git
  cd /home/ec2-user/orthdock/
  docker-compose up
"
echo "Leavingcustom script"
