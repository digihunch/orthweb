## Overview
In this section we connect to database and S3 storage for additional points of validation.

## Database validation

The PostgreSQL RDS instance is accessible only from the EC2 instance on port 5432. You can get the database URL and credential from file `/home/ec2-user/.orthanc.env`. To validate by psql client, run:

```sh
sudo amazon-linux-extras enable postgresql14
sudo yum install postgresql
psql --host=postgresdbinstance.us-east-1.rds.amazonaws.com --port 5432 --username=myuser --dbname=orthancdb
```

Then you are in the PostgreSQL command console and can check the tables using SQL, for example:

```sh
orthancdb=> \dt;
                List of relations
 Schema |         Name          | Type  | Owner
--------+-----------------------+-------+--------
 public | attachedfiles         | table | myuser
 public | changes               | table | myuser
 public | deletedfiles          | table | myuser
 public | deletedresources      | table | myuser
 public | dicomidentifiers      | table | myuser
 public | exportedresources     | table | myuser
 public | globalintegers        | table | myuser
 public | globalproperties      | table | myuser
 public | maindicomtags         | table | myuser
 public | metadata              | table | myuser
 public | patientrecyclingorder | table | myuser
 public | remainingancestor     | table | myuser
 public | resources             | table | myuser
 public | serverproperties      | table | myuser
(14 rows)

orthancdb=> select * from attachedfiles;
 id | filetype |                 uuid                 | compressedsize | uncompressedsize | compressiontype |         uncompressedhash         |          compressedhash          | revision
----+----------+--------------------------------------+----------------+------------------+-----------------+----------------------------------+----------------------------------+----------
  4 |        1 | 87719ef0-cbb1-4249-a0ac-e68356d97a7a |         525848 |           525848 |               1 | bd07bf5f2f1287da0f0038638002e9b1 | bd07bf5f2f1287da0f0038638002e9b1 |        0
(1 row)
```

This is as far as we can go in terms of validating database. Without the schema document, we are not able to interpret the content. It is also not recommended to tamper with the tables directly bypassing the application.

## Storage Validation

Storage validation can be performed simply by examining the content of S3 bucket. Once studies are sent to Orthanc, the corresponding DICOM file should appear in the S3 bucket. For example, we can run the following AWS CLI command from the EC2 instance:


```sh
aws s3 ls s3://bucket-name
2021-12-02 18:54:41     525848 87719ef0-cbb1-4249-a0ac-e68356d97a7a.dcm
```

The bucket is not publicly assissible and is protected by bucket policy configured during resource provisioning.