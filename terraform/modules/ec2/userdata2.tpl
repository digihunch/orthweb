#! /bin/bash
echo "Entering userdata2 script"

runuser -l ec2-user -c "
  git clone --depth 1 ${config_repo}
"

runuser -l ec2-user -c '
  DBSecret=$(aws secretsmanager get-secret-value --secret-id ${sec_name} --query SecretString --output text)
  DBUserName=$(echo $DBSecret | jq -r .username)
  DBPassword=$(echo $DBSecret | jq -r .password)
  if [ -n "${site_name}" ]; then
    sed -i "/^SITE_NAME/c\SITE_NAME=${site_name}" orthanc-config/.env
  else
    TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
    ServerComName=`curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/public-hostname`
    sed -i "/^SITE_NAME/c\SITE_NAME=$ServerComName" orthanc-config/.env
  fi
  sed -i "/^ORTHANC_DB_HOST/c\ORTHANC_DB_HOST=${db_address}" orthanc-config/.env
  sed -i "/^ORTHANC_DB_USERNAME/c\ORTHANC_DB_USERNAME=$DBUserName" orthanc-config/.env
  sed -i "/^ORTHANC_DB_PASSWORD/c\ORTHANC_DB_PASSWORD=$DBPassword" orthanc-config/.env
  sed -i "/^KC_DB_HOST/c\KC_DB_HOST=${db_address}" orthanc-config/.env
  sed -i "/^KC_DB_USERNAME/c\KC_DB_USERNAME=$DBUserName" orthanc-config/.env
  sed -i "/^KC_DB_PASSWORD/c\KC_DB_PASSWORD=$DBPassword" orthanc-config/.env
  echo \# S3STORAGE >> orthanc-config/.env
  echo S3_BUCKET=${s3_bucket} >> orthanc-config/.env
  echo S3_REGION=${aws_region} >> orthanc-config/.env
  ${init_command}
' 

echo "Leaving userdata2 script"
