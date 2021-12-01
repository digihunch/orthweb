# Orthweb - Orthanc deployment on AWS with Docker
 
## Overview

**[Orthanc](https://www.orthanc-server.com/)** is an open-source application for medical imaging to ingest, store, view and distribute medical images. **[Orthweb](https://github.com/digihunch/orthweb)** is an open-source project for automated infrastructure provisioning on AWS, and automated configuration of Orthanc. The website is ready to serve web and DICOM traffic as soon as deployment is completed.

This project demonstrates the idea of infrastructure-as-code, deployment automation and security configurations in compliance with HIPPA. It does not intend to provide production capacity. For custom deployment towards production and clinical use, please contact the author.

The open-source Orthanc porject does not include the plugin for storing images on S3 bucket. This project also includes the builder for Digi Hunch [custom Orthanc image](https://hub.docker.com/repository/docker/digihunch/orthanc) with the plugin. 

We use Terraform to create infrastructure on AWS, including VPC, subnets, secret manager, managed database (PostgreSQL), an EC2 instance and S3 bucket. The application is hosted in a Docker container on the EC2 instance.

## Prerequisite

Users need their own AWS account (Access Key ID and Secret Access Key with administrator privilege) to deploy this project.  The rest of this instruction is based on local execution of Terraform command from MacOS. Make sure **awscli** is configured and **Terraform CLI** is [installed](https://learn.hashicorp.com/tutorials/terraform/install-cli). There are more than one methods to authenticate Terraform against AWS.  The easiest [setup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-credentials-file) is to use the [credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) for [awscli]((https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)). To connect to the server console, it is also required to [configure](https://help.dreamhost.com/hc/en-us/articles/115001736671-Creating-a-new-Key-pair-in-Mac-OS-X-or-Linux) an SSH key pair. 

## Deployment

From command terminal, go to the [terraform](https://github.com/digihunch/orthweb/tree/main/terraform) directory and execute Terraform command from there.
1. Initialize terraform modules, and plan for deployment, with command:

> terraform init && terraform plan

This command will initialize Terraform template (e.g. download AWS provider) and then plan out the resources to deploy. It should print out the resources about to deploy.

3. Execute the deployment plan, by running:

> terraform apply

In this step Terraform interact with your AWS account to provision the resources and configure the website, which can take as long as 15 minutes. Upon successful deployment, the output displays three entries:
* **hostinfo**: the EC2 host information in the format of ec2-user@ec2-102-203-105-112.compute-1.amazonaws.com
	* ec2-user is the username to SSH to server, refer to advanced validation below for how to connect to the server.
	* The part after the "@" sign is the website FQDN. Refer to basic validation below for how to visit the site.
* **dbinfo**: the PostgreSQL URL and port, in the format of postgresdbinstance.us-east-1.rds.amazonaws.com:5432, only accessible with appropriate permissions;
* **s3bucket**: the URL to the S3 bucket created in the format of bucket-name.s3.amazonaws.com, only accessible with appropriate permissions;

Now that site is up, we can validate the site with the steps outlined in the sections below. Once your demo is completed, you may remove all the resources, with command:
> terraform destroy

## Basic Validation

To Validate DICOM capability, we can test with C-ECHO and C-STORE. We can use any DICOM compliant application. For example, [Horos](https://horosproject.org/) on MacOS is a UI-based application. In Preference->Locations, configure a new DICOM nodes with
* Address: the site FQDN
* AE title: ORTHANC
* Port: 11112 (or otherwise configured)

Remember to enable TLS. Then you will be able to verify the node (i.e. C-ECHO) and send existing studies from Horos to Orthanc (C-STORE).

To Validate the the web server, simply visit the website with the default credential. For example, https://ec2-102-203-105-112.compute-1.amazonaws.com:8042. The web browser might flag the site as insecure with invalid authority. This is due to the use of self-signed certificate in the demo. In a production deployment, you should bring your own DNS name with matching SSL certificate so that web browser will recognize it as secure. 

The basic validation steps are carried out from the perspective of end user. In the next section, I provide some guidelines for advanced validation from the point of IT professional. For application validation, you will need an imaging informatics professional. 

## Advanced Validation
The advanced validation is carried out in four perspectives: Hosting server, DICOM connectivity, Database and Storage. 

### Server Validation
We use SSH protocol with [RSA key](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) authentication to connect to EC2 instance. The terraform template in this project requires public key provided to the input variable named pubkey_data. It uses the key content from  local public key file (~/.ssh/id_rsa.pub). If you prefers explicitly use a different public key data, you can provide it as environment variable before running apply command:
```sh
export TF_VAR_pubkey_data="fakepublickeyabcxyzpubkklsss"
terraform plan
```
This technique is for the convenience of tester, because as the server is provisioned, the user will be able to SSH to the server with a simple SSH command:
```sh
ssh ec2-user@ec2-user@ec2-102-203-105-112.compute-1.amazonaws.com
```
Once logged on, we can check cloud init log:
```sh
sudo tail -F /var/log/cloud-init-output.log
```
Which should say Orthanc has started. The files related to Orthanc deployment are in directory /home/ec2-user/orthweb/app:
* orthanc.json: the Orthanc configuration file
* dicomtls.conf: the Nginx configuration file
* compute-1.amazonaws.com.pem: the file that stores the self-signed certificate and key that are generated for deployment.
* docker-compose.yml: the file that drives Docker

### DICOM Validation
We will use a command-line utility called [dcm4che3](https://sourceforge.net/projects/dcm4che/files/dcm4che3/) as a command-line for DICOM testing. Because TLS is turned on for DICOM traffic, we will also need the automatically generated certificate and convert it to a compatible (JKS) format. 
1. On the server, from the .pem file in /home/ec2-user/orthweb/app/, copy the certificate content (between the lines "BEGIN CERTIFICATE" and "END CERTIFICATE" inclusive), and paste it to a file named site.crt on your MacBook.
2. Import the certificate file int a java trust store, with the command below
```sh
keytool -import -alias orthweb -file site.crt -storetype JKS -keystore server.truststore
```
At this step, it is mandatory to provide password. Let's say it is Password123. We also need to indicate that we trust this certificate.

3. Then we can use this truststore file in C-ECHO and C-STORE. The dcm4che3 utility uses storescu to perform C-ECHO against the server. For example:
```sh
./storescu -c ORTHANC@ec2-102-203-105-112.compute-1.amazonaws.com:11112 --tls12 --tls-aes --trust-store path/to/server.truststore --trust-store-pass Password123
```
The output should read Status code 0 in C-ECHO-RSP, followed by C-ECHO-RQ. For example, the last few lines of the output should read something like:
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

23:21:27,571 INFO  - STORESCU->ORTHANC(1) << A-RELEASE-RQ
23:21:27,571 DEBUG - STORESCU->ORTHANC(1): enter state: Sta7 - Awaiting A-RELEASE-RP PDU
23:21:27,595 INFO  - STORESCU->ORTHANC(1) >> A-RELEASE-RP
23:21:27,596 INFO  - STORESCU->ORTHANC(1): close Socket[addr=ec2-54-174-215-157.compute-1.amazonaws.com/54.174.215.157,port=11112,localport=55608]
23:21:27,599 DEBUG - STORESCU->ORTHANC(1): enter state: Sta1 - Idle
```
4. We can use it to store DICOM part 10 file (usually .dcm extension) to the server.

Note: DICOM traffic is proxied through Nginx. 

### Database Validation


RDS will be accessible from the EC2 instance, on port 5432. To validate by psql client, run:

```sh
psql --host=postgresdbinstance.us-east-1.rds.amazonaws.com --port 5432 --username=myuser --dbname=orthancdb
```
The password can be retrieved from AWS secret.

### Storage Validation

Storage validation can be performed simply by examining the content of S3 bucket. For example on t
```sh
aws s3 ls s3://bucket-name
```
Once studies are sent to Orthanc, the corresponding DICOM file should be stored in this location.










## Custom Orthanc image Builder
why build custom image

##  Architecture

![Diagram](resources/Orthweb.png)

why use nginx proxy



* Why Docker on EC2? The alternative to EC2 is ECS but ECS has limitations. Refer to [this](https://github.com/digihunch/orthweb/issues/1#issuecomment-852669561) comment. For production use, we should put EC2 instances in an autoscaling group behind load balancer. As to Docker vs Kubernetes. First, for large deployment, Kubernetes is a better way to deploy Orthanc. Check out this [Korthweb](https://github.com/digihunch/korthweb) project. However, the complexity and additional layer brought in by Kubernetes may not be worth all the effort, especially for a small deployment. A docker-compose is sufficient for typical Orthanc use case. Check out [this](https://ably.com/blog/no-we-dont-use-kubernetes) article for the case against Kubernetes.
* Why AWS? It doesn't have to. In fact I prefer a provider independent setup. However, we need database as service from cloud provider so the code has to be specific to a cloud provider. Also, I'm more familiar with AWS than other platforms.
* Why PostgreSQL? We can use PostgreSQL to store both patient index and pixel data.
* Why Terraform? Terraform has better modularization support than CloudFormation. It is easier to set up than AWS CDK.

Related project Korthweb.


## Security

### Configurations for security

1. Both DICOM and web traffic are encrypted in TLS
2. PostgreSQL data is encrypted at rest, and the traffic to and from application container is encrypted in transit.
3. The master user and password for database are now generated dynamically, in the secret manager in AWS. The EC2 instance is granted with the role to access the secret. The cloud-init script will be given the private endpoint of secret manager to pull the secret into a file. Docker compose maps the secret file to environment variables inside of container.
4. Since the X509 certificate is self-signed for demo, it is now dynamically generated using openssl11 during bootstrapping, in compliance with [Mac requirement](https://support.apple.com/en-us/HT210176).

Check out this [blog post](https://www.digihunch.com/2021/05/secure-web-application-deployment/) for further details design considerations.

### Known Limitations

The followings are identified as not up to highest security standard. They may not be important for a demo system, but should be addressed for a production system. The **[Korthweb](https://github.com/digihunch/korthweb)** deployment project does not have these limitations.

1. the traffic between nginx container and orthan container is unencrypted. While this is not an issue in the current architecture because the traffic goes through docker bridge, it is advisable to have end-to-end encryption when nginx and orthanc containers may live on different virtual machines.
2. Database password is generated at Terraform client and then sent to deployment server to create PostgreSQL. The generated password is also stored in state file of Terraform. To overcome this, we need a) Terraform tells AWS secrets manager to generate a password; and b) it tells other AWS service to resolve the newly created secret. a) is doable but b) isn't due to a limitation with Terraform
3. Secret management with Docker container: secret are presented to container process as environment variables, instead of file content. As per [this article](https://techbeacon.com/devops/how-keep-your-container-secrets-secure), it is not recommended because environment variable could be leaked out.


## Towards production

TODO: what needs to be done to configure towards production
