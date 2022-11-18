
# Orthweb - Orthanc in Docker on AWS
 
## Overview

**[Orthanc](https://www.orthanc-server.com/)** is an open-source application to ingest, store, display and distribute medical images. **[Orthweb](https://github.com/digihunch/orthweb)** is an open-source deployment project to automatically configure Orthanc and associated resources on AWS. When the deployment is completed, the website is ready to serve both web and DICOM traffic.

We use Terraform to create infrastructure on AWS, including VPC, subnets, secret manager, managed database (PostgreSQL), an EC2 instance and S3 bucket. For simplicity, the application is hosted in a Docker container running on a EC2 instance.

## Use case

Orthweb project demonstrates the idea of infrastructure-as-code, deployment automation and security configurations. It provisions just enough resources for demo, and is not intended for production use. 

How you can use this project depends on your role and goal:

| Your role and goal | How you provision infrastructure for Orthanc | How you install Orthanc |
| ----------- | --------- | ---------- |
| You are an individual developer, student or other party with interest. You have a single AWS account as sandbox and want to quickly check out Orthanc with minimum configuration effort.| [Orthweb](https://github.com/digihunch/orthweb) project creates dedicated VPC and subnets with secure configuration | [Orthweb](https://github.com/digihunch/orthweb) project configures Orthanc installation automatically. |
| You are a healthcare organization, start-up or corporate. Your organization has established [Multiple AWS accounts](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/organizing-your-aws-environment.html) and networking. You want to configure Orthanc in a secure and compliant environment. | The infrastructure team configures [landing zone](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/understanding-landing-zones.html) with secure and compliant networking foundation. | The application team configures Orthanc installation, taking [Orthweb](https://github.com/digihunch/orthweb) project as a reference. |

## Prerequisite

You need your own AWS IAM user (Access Key ID and Secret Access Key with administrator privilege) to deploy this project.  The rest of this instruction is based on local execution of Terraform command. All the steps were tested on MacBook. With adjustment however, the project also work on Windows and from Terraform Cloud.

Make sure **awscli** is configured and **Terraform CLI** is [installed](https://learn.hashicorp.com/tutorials/terraform/install-cli). There are more than one methods to authenticate Terraform against AWS.  The easiest [setup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-credentials-file) is to use the [credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) for [awscli]((https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)). To authenticat yourself to the EC2 instance over, it is also required to [configure](https://help.dreamhost.com/hc/en-us/articles/115001736671-Creating-a-new-Key-pair-in-Mac-OS-X-or-Linux) and use an RSA key pair. 

## Preparation

From command terminal, go to the [terraform](https://github.com/digihunch/orthweb/tree/main/terraform) directory and execute Terraform command from there. This section covers the environment variables needed prior to executing Terraform command. 

### Customize Docker Image

By default input variable `DockerImages` is set to the image refernce for Orthanc and Envoy. You may override it with your own choice of image or version by providing environment variable `TF_VAR_DockerImages`. You can leave this variable undefined unless you have your own choice of Docker images.

### Secure SSH access
You need to connect to the EC2 instance (server) for administrative work over SSH. This project helps you secure the SSH access by limiting the incoming IP address, and configuring RSA key authentication.

#### Limiting SSH client IP

When running terraform command, the value of environment variable `TF_VAR_cli_cidr_block` will be passed to input variable `cli_cidr_block` of Terraform. This is for you to optionally restrict access to EC2 instance from a specified range of IP addresses. For example, if you want your public IP the only IP to connect to the server via SSH, set it to your public IP with /32.

> export TF_VAR_cli_cidr_block=$(curl http://checkip.amazonaws.com)/32

If this variable not provided, Terraform will default it to default CIDR value of 0.0.0.0/0) and the server's SSH port is wide open.

#### RSA key pair for SSH authentication
We use SSH protocol with [RSA key](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) authentication. So when provisioning the server, the Terraform template will tell the server to whitelist your public key. You can provide your public key data in one of the two ways:

You can provide public key data in environment variable:
```sh
export TF_VAR_pubkey_data="mockpublickeydatawhichissuperlongdonotputyourprivatekeyherepleaseabcxyzpubkklsss"
```
The value will be passed to input variable `pubkey_data`. This is helpful when Terraform executes from a machine different than your SSH client.

Alternatively, you can provide path to public key file in variable `pubkey_path`. If not provided, the Terraform template uses default path for public key file (~/.ssh/id_rsa.pub on MacOS or Linux). If you run Terraform and SSH CLI from the same host, you can just [create SSH key pair](https://support.atlassian.com/bitbucket-cloud/docs/set-up-an-ssh-key/) and leave both variables above undefined.

## Deployment
With the preparatory work done, we can deploy Orthanc in a couple commands:

First, initialize terraform modules, and plan for deployment, with command:

> terraform init
> terraform plan

The first command will initialize Terraform template (e.g. download AWS provider). The second command plans out the resources to deploy, and prints them out.

Second, execute the deployment plan, by running:

> terraform apply

In this step Terraform interact with your AWS account to provision the resources and configure the website, which can take as long as 15 minutes. You need to say `yes` to the prompt. Upon successful deployment, the output displays three entries:
* **hostinfo**: the EC2 host information in the format of ec2-user@ec2-102-203-105-112.compute-1.amazonaws.com
	* ec2-user is the username to SSH to server, refer to advanced validation below for how to connect to the server.
	* The part after the "@" sign is the website FQDN. Refer to basic validation below for how to visit the site.
* **dbinfo**: the PostgreSQL URL and port, in the format of postgresdbinstance.us-east-1.rds.amazonaws.com:5432, which is not publicly accessible;
* **s3bucket**: the URL to the S3 bucket created in the format of bucket-name.s3.amazonaws.com, only accessible with appropriate IAM permissions;

Now that site is up, we can validate the site with the steps outlined in the sections below. 

Last, once your demo is completed, you may remove all the resources, with command:
> terraform destroy

## Basic Validation

To Validate DICOM capability, we can test with C-ECHO and C-STORE. We can use any DICOM compliant application. For example, [Horos](https://horosproject.org/) on MacOS is a UI-based application. In Preference->Locations, configure a new DICOM nodes with
* Address: the site FQDN
* AE title: ORTHANC
* Port: 11112 (or otherwise configured)

Remember to enable TLS. Then you will be able to verify the node (i.e. C-ECHO) and send existing studies from Horos to Orthanc (C-STORE).

To Validate the the web server, simply visit the website with the default credential. For example, https://ec2-102-203-105-112.compute-1.amazonaws.com:443. The web browser might flag the site as insecure with invalid authority. This is due to the use of self-signed certificate in the demo. In a production deployment, you should bring your own DNS name with matching SSL certificate so that web browser will recognize it as secure. 

The basic validation steps are carried out from the perspective of end user. In the next section, I provide some guidelines for advanced validation from the point of IT professional. For application validation, you will need an imaging informatics professional. 

## Advanced Validation
The advanced validation is carried out in four perspectives: Hosting server, DICOM connectivity, Database and Storage. 

### Server Validation

We can connect to the server over SSH. Since we configured IP and public key whitelisting, the following command should just work:
```sh
ssh ec2-user@ec2-user@ec2-102-203-105-112.compute-1.amazonaws.com
```
Once logged on, we can check cloud init log:
```sh
sudo tail -F /var/log/cloud-init-output.log
```
Which should say Orthanc has started. The files related to Orthanc deployment are in directory /home/ec2-user/orthweb/app:
* orthanc.json: the Orthanc configuration file
* envoy.yaml: the Envoy configuration file
* compute-1.amazonaws.com.pem: the file that stores the self-signed certificate and key that are generated for deployment.
* docker-compose.yml: the file that drives Docker

### DICOM Validation
We will use a command-line utility called [dcm4che3](https://sourceforge.net/projects/dcm4che/files/dcm4che3/) for DICOM testing. Because Orthanc requires TLS with DICOM traffic, and dcm4che is a Java application, we will also need to pull out the automatically generated certificate and convert it to a compatible (JKS) format for dcm4che to use.
1. On the server, from the .pem file in /home/ec2-user/orthweb/app/, copy the certificate content (between the lines "BEGIN CERTIFICATE" and "END CERTIFICATE" inclusive), and paste it to a file named site.crt on your MacBook.
2. Import the certificate file int a java trust store, with the command below and give it a password, say Password123!
```sh
keytool -import -alias orthweb -file site.crt -storetype JKS -noprompt -keystore server.truststore -storepass Password123!
```
The server.truststore file is JKS format for storescu, the dcm4che utility in Java, to use in the next step.

3. Then we can use this truststore file in C-ECHO and C-STORE. The dcm4che3 utility uses storescu to perform C-ECHO against the server. For example:
```sh
./storescu -c ORTHANC@ec2-102-203-105-112.compute-1.amazonaws.com:11112 --tls12 --tls-aes --trust-store server.truststore --trust-store-pass Password123!
```
The output should read Status code 0 in C-ECHO-RSP, followed by C-ECHO-RQ. For example, the output should contain some important lines such as:
```
23:21:27,506 INFO  - STORESCU->ORTHANC(1) << 1:C-ECHO-RQ[pcid=1
  cuid=1.2.840.10008.1.1 - Verification SOP Class
  tsuid=1.2.840.10008.1.2 - Implicit VR Little Endian]
23:21:27,534 DEBUG - STORESCU->ORTHANC(1) << 1:C-ECHO-RQ Command:
(0000,0002) UI [1.2.840.10008.1.1] AffectedSOPClassUID
(0000,0100) US [48] CommandField
(0000,0110) US [1] MessageID
(0000,0800) US [257] CommandDataSetType

23:21:27,570 INFO  - STORESCU->ORTHANC(1) >> 1:C-ECHO-RSP[pcid=1, status=0H
  cuid=1.2.840.10008.1.1 - Verification SOP Class
  tsuid=1.2.840.10008.1.2 - Implicit VR Little Endian]
23:21:27,570 DEBUG - STORESCU->ORTHANC(1) >> 1:C-ECHO-RSP Command:
(0000,0002) UI [1.2.840.10008.1.1] AffectedSOPClassUID
(0000,0100) US [32816] CommandField
(0000,0120) US [1] MessageIDBeingRespondedTo
(0000,0800) US [257] CommandDataSetType
(0000,0900) US [0] Status
```
4. We can use it to store DICOM part 10 file (usually .dcm extension) to the server, using storescu again:
```sh
./storescu -c ORTHANC@ec2-102-203-105-112.compute-1.amazonaws.com:11112 --tls12 --tls-aes --trust-store server.truststore --trust-store-pass Password123! MYFILE.DCM
```
The output log should contain the following:
```
22:02:19,529 DEBUG - STORESCU->ORTHANC(1): enter state: Sta6 - Association established and ready for data transfer
Connected to ORTHANC in 392ms
22:02:19,532 INFO  - STORESCU->ORTHANC(1) << 1:C-STORE-RQ[pcid=7, prior=0
  cuid=1.2.840.10008.5.1.4.1.1.12.1 - X-Ray Angiographic Image Storage
  iuid=1.3.12.2.1107.5.4.3.321890.19960124.162922.29 - ?
  tsuid=1.2.840.10008.1.2.4.50 - JPEG Baseline (Process 1)]
22:02:19,547 DEBUG - STORESCU->ORTHANC(1) << 1:C-STORE-RQ Command:
(0000,0002) UI [1.2.840.10008.5.1.4.1.1.12.1] AffectedSOPClassUID
(0000,0100) US [1] CommandField
(0000,0110) US [1] MessageID
(0000,0700) US [0] Priority
(0000,0800) US [0] CommandDataSetType
(0000,1000) UI [1.3.12.2.1107.5.4.3.321890.19960124.162922.29] AffectedSOPInst

22:02:19,549 DEBUG - STORESCU->ORTHANC(1) << 1:C-STORE-RQ Dataset sending...
22:02:22,160 DEBUG - STORESCU->ORTHANC(1) << 1:C-STORE-RQ Dataset sent
22:02:22,449 INFO  - STORESCU->ORTHANC(1) >> 1:C-STORE-RSP[pcid=7, status=0H
  cuid=1.2.840.10008.5.1.4.1.1.12.1 - X-Ray Angiographic Image Storage
  iuid=1.3.12.2.1107.5.4.3.321890.19960124.162922.29 - ?
  tsuid=1.2.840.10008.1.2.4.50 - JPEG Baseline (Process 1)]
22:02:22,449 DEBUG - STORESCU->ORTHANC(1) >> 1:C-STORE-RSP Command:
(0000,0002) UI [1.2.840.10008.5.1.4.1.1.12.1] AffectedSOPClassUID
(0000,0100) US [32769] CommandField
(0000,0120) US [1] MessageIDBeingRespondedTo
(0000,0800) US [257] CommandDataSetType
(0000,0900) US [0] Status
(0000,1000) UI [1.3.12.2.1107.5.4.3.321890.19960124.162922.29] AffectedSOPInst
```
C-STORE-RSP status 0 indicates successful image transfer, and the image is viewable from web portal. 

### Database Validation

RDS will be accessible from the EC2 instance, on port 5432. The database URL and password can be retrieved using AWS CLI command. Their values are also kept in file /home/ec2-user/.orthanc.env during initialization. To validate by psql client, run:
```sh
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
You may not be able to interpret the content without the database schema. It is also not recommended to edit the tables directly bypassing the application logic.

### Storage Validation

Storage validation can be performed simply by examining the content of S3 bucket. Once studies are sent to Orthanc, the corresponding DICOM file should appear in the S3 bucket. For example, we can run the following AWS CLI command from the EC2 instance:
```sh
aws s3 ls s3://bucket-name
2021-12-02 18:54:41     525848 87719ef0-cbb1-4249-a0ac-e68356d97a7a.dcm
```
The bucket is not publicly assissible and is protected by bucket policy configured during resource provisioning.

##  Architecture

The architecture can be illustrated in the diagram below:

![Diagram](resources/Orthweb.png)

Orthweb is built on AWS as cloud platform, and uses Docker on EC2 to host application. The alternative to EC2 is ECS but ECS has some [limitations](https://github.com/digihunch/orthweb/issues/1#issuecomment-852669561). Docker on EC2 is sufficient for typical imaging workload. [This](https://ably.com/blog/no-we-dont-use-kubernetes) blog discusses how Docker on EC2 in Autoscaling group suits the need of most workloads without the complexity of Kubernetes. Orthweb has a sibling project [Korthweb](https://github.com/digihunch/korthweb) under development, which deploys Orthanc on Kubernetes platform.

Originally, Orthanc did not support DICOM traffic over TLS. So Orthweb used Nginx as a reverse proxy to terminate TLS traffic. Now Orthanc does have DICOM TLS support but it is not straightforward to configure. Orthweb also uses Envoy proxy instead of Nginx for better performance. Envoy acts as reverse proxy for both web traffic (https->https) and DICOM traffic (dicom tls -> dicom), with static configuration.

## Security

Orthweb project implements secure configuration as far as it can. For example, it configures a self-signed certificate in the demo. In production deployment however you should bring your own certificates signed by CA. Below are the points of configurations for security compliance:

1. Both DICOM and web traffic are encrypted in TLS. This requires peer DICOM AE to support DICOM TLS in order to connect with Orthanc.
2. PostgreSQL data is encrypted at rest, and the database traffic between Orthanc application and database is encrypted in SSL. The database endpoint is not open to public.
3. The S3 bucket has server side encryption. The traffic in transit between S3 bucket and Orthanc application is encrypted as well. The S3 endpoint is not open to public.
4. The password for database are generated dynamically and stored in AWS Secret Manager in AWS. The EC2 instance is granted access to the secret, which allows the cloud-init script to fetch the secret and launch container with it. 
5. The demo-purpose self-signed X509 certificate is dynamically generated using openssl11 during bootstrapping, in compliance with [Mac requirement](https://support.apple.com/en-us/HT210176).

The handling of secret at some points of configurations has room for improvement.
1. Database password is generated at Terraform client and then sent to deployment server to create PostgreSQL. The generated password is also stored in state file of Terraform. To overcome this, we need a) Terraform tells AWS secrets manager to generate a password; and b) it tells other AWS service to resolve the newly created secret. As of May 2021, a) is doable but b) isn't due to a limitation with Terraform
2. Secret management with Docker container: secret are presented to container process as environment variables, instead of file content. As per [this article](https://techbeacon.com/devops/how-keep-your-container-secrets-secure), this is not the best practice.