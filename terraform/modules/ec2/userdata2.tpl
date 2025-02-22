#! /bin/bash
echo "Entering userdata2 script"

runuser -l ec2-user -c "
  git clone --depth 1 ${config_repo}
"

runuser -l ec2-user -c '
  DBSecret=$(aws secretsmanager get-secret-value --secret-id ${sec_name} --query SecretString --output text)
  DBUserName=$(echo $DBSecret | jq -r .username)
  DBPassword=$(echo $DBSecret | jq -r .password)
  ConfigDir=repo_name=$(basename "${config_repo}" .git)

  if [ -n "${site_name}" ]; then
    sed -i "/^SITE_NAME/c\SITE_NAME=${site_name}" $ConfigDir/.env
  else
    TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
    ServerComName=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname`
    sed -i "/^SITE_NAME/c\SITE_NAME=$ServerComName" $ConfigDir/.env
  fi
  sed -i "/^ORTHANC_DB_HOST/c\ORTHANC_DB_HOST=${db_address}" $ConfigDir/.env
  sed -i "/^ORTHANC_DB_USERNAME/c\ORTHANC_DB_USERNAME=$DBUserName" $ConfigDir/.env
  sed -i "/^ORTHANC_DB_PASSWORD/c\ORTHANC_DB_PASSWORD=$DBPassword" $ConfigDir/.env
  sed -i "/^KC_DB_HOST/c\KC_DB_HOST=${db_address}" $ConfigDir/.env
  sed -i "/^KC_DB_USERNAME/c\KC_DB_USERNAME=$DBUserName" $ConfigDir/.env
  sed -i "/^KC_DB_PASSWORD/c\KC_DB_PASSWORD=$DBPassword" $ConfigDir/.env
  echo \# S3STORAGE >> $ConfigDir/.env
  echo S3_BUCKET=${s3_bucket} >> $ConfigDir/.env
  echo S3_REGION=${aws_region} >> $ConfigDir/.env

  cd $ConfigDir
  ${init_command}
' 

## Configure Docker daemon

if [ "${cw_docker_log}" == "true" ]; then
  cat <<EOF >/etc/docker/daemon.json
{
  "log-driver": "awslogs",
  "log-opts": {
    "awslogs-region": "${aws_region}",
    "awslogs-group": "/${resource_prefix}/orthweb/containers"
  }
}
EOF
fi

systemctl restart docker
echo "Leaving userdata2 script"