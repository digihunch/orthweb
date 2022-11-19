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
runuser -l ec2-user -c 'aws configure set region ${aws_region}'
runuser -l ec2-user -c '(echo "VERBOSE_ENABLED=false") >> .orthanc.env'
runuser -l ec2-user -c '(echo "TRACE_ENABLED=false") >> .orthanc.env'
runuser -l ec2-user -c '(echo -n DB_ADDR=;echo ${db_address}) >> .orthanc.env'
runuser -l ec2-user -c '(echo -n DB_PORT=;echo ${db_port}) >> .orthanc.env'
runuser -l ec2-user -c '(echo -n DB_USERNAME=;aws secretsmanager get-secret-value --secret-id ${sec_name} --query SecretString --output text --endpoint-url https://${sm_endpoint} | jq -r .username) >> .orthanc.env'
runuser -l ec2-user -c '(echo -n DB_PASSWORD=;aws secretsmanager get-secret-value --secret-id ${sec_name} --query SecretString --output text --endpoint-url https://${sm_endpoint} | jq -r .password) >> .orthanc.env'
runuser -l ec2-user -c '(echo -n S3_ENDPOINT=;echo ${s3_endpoint} | sed "s/^*/bucket/") >> .orthanc.env'
runuser -l ec2-user -c '(echo -n S3_BUCKET=;echo ${s3_bucket}) >> .orthanc.env'
runuser -l ec2-user -c '(echo -n S3_REGION=;echo ${aws_region}) >> .orthanc.env'

echo "Leaving userdata2 script"
