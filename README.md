# orthcloud

The provider section assumes credentials stored in ~/.aws/credentials under default profile. To initialize, use aws configure with keys.

* terraform init

* terraform apply

* terraform destroy

expctation:
web service available
http://url:8042
imaging data available at 
ORTHANC@url:4242

to do:
1. configure connectivity to RDS postgres backend
2. network segmentation and security group hardening
3. investigate private link to rds
4. certs and entryption of payload and http


https://book.orthanc-server.com/index.html
psql --host=localhost --port 5432 --username=myuser --dbname=orthancdb
