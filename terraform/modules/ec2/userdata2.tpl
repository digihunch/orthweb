#! /bin/bash
echo "Entering userdata2 script"

runuser -l ec2-user -c '
  DBSecret=$(aws secretsmanager get-secret-value --secret-id ${sec_name} --query SecretString --output text)
  DBUserName=$(echo $DBSecret | jq -r .username)
  DBPassword=$(echo $DBSecret | jq -r .password)
  sed -i "/^SITE_NAME/c\SITE_NAME=${floating_eip_dns}" orthanc-config/.env
  sed -i "/^ORTHANC_DB_HOST/c\ORTHANC_DB_HOST=${db_address}" orthanc-config/.env
  sed -i "/^ORTHANC_DB_USERNAME/c\ORTHANC_DB_USERNAME=$DBUserName" orthanc-config/.env
  sed -i "/^ORTHANC_DB_PASSWORD/c\ORTHANC_DB_PASSWORD=$DBPassword" orthanc-config/.env
  sed -i "/^KC_DB_HOST/c\KC_DB_HOST=${db_address}" orthanc-config/.env
  sed -i "/^KC_DB_USERNAME/c\KC_DB_USERNAME=$DBUserName" orthanc-config/.env
  sed -i "/^KC_DB_PASSWORD/c\KC_DB_PASSWORD=$DBPassword" orthanc-config/.env
  echo \# S3STORAGE >> orthanc-config/.env
  echo S3_BUCKET=${s3_bucket} >> orthanc-config/.env
  echo S3_REGION=${aws_region} >> orthanc-config/.env
' 

echo "Leaving userdata2 script"
