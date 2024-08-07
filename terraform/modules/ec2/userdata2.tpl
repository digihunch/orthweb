#! /bin/bash
echo "Entering userdata2 script"

# Load environment variable for docker compose
cd /home/ec2-user/orthweb/app
chown ec2-user:ec2-user .env
echo DOCKER_IMAGE_ORTHANC=${orthanc_image} >> .env
echo DOCKER_IMAGE_ENVOY=${envoy_image} >> .env
echo Orthanc configuration will index data in PostgreSQL and store image files in S3 bucket.
echo ORTHANC_CONFIG_FILE=orthanc.json >> .env

# Load app config
echo "Pulling app configuration."
runuser -l ec2-user -c '
  aws configure set region ${aws_region} && \
  (echo "VERBOSE_ENABLED=false") >> .orthanc.env && \
  (echo "TRACE_ENABLED=false") >> .orthanc.env && \
  (echo -n DB_ADDR=;echo ${db_address}) >> .orthanc.env && \
  (echo -n DB_PORT=;echo ${db_port}) >> .orthanc.env && \
  (echo -n DB_USERNAME=;aws secretsmanager get-secret-value --secret-id ${sec_name} --query SecretString --output text | jq -r .username) >> .orthanc.env && \
  (echo -n DB_PASSWORD=;aws secretsmanager get-secret-value --secret-id ${sec_name} --query SecretString --output text | jq -r .password) >> .orthanc.env && \
  (echo -n S3_BUCKET=;echo ${s3_bucket}) >> .orthanc.env && \
  (echo -n S3_REGION=;echo ${aws_region}) >> .orthanc.env
'

echo "Site will be available as ${floating_eip_dns}"

runuser -l ec2-user -c '
  cd /home/ec2-user/orthweb/app && docker-compose up
'

echo "Leaving userdata2 script"
