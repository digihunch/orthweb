
# Orthweb - Orthanc on AWS
 
## Overview

 **[Orthweb](https://github.com/digihunch/orthweb)** helps Orthanc administrators deploy **[Orthanc](https://www.orthanc-server.com/)** on AWS. From your own AWS account, this project automatically sets up the Orthanc server for HTTP and DICOM in 10 minutes.

With Orthanc application shipped in Docker container, the **[Orthweb](https://github.com/digihunch/orthweb)** project orchestrates numerous underlying cloud resources from AWS (e.g. VPC, subnets, Secret Manager, RDS, S3) with an opinionated and consistent configuration towards end-to-end automation, high availability and best-effort security.

## Use case

**Orthweb** demonstrates the idea of infrastructure-as-code, deployment automation and security options to host **Orthanc**. It is however not intended for production. How you can benefit from **Orthweb** depends on your role and goal.

| Your role and goal | How you provision infrastructure for Orthanc | How you install Orthanc |
| ----------- | --------- | ---------- |
| You are a developer, sales, doctor, student, etc. You have your own AWS account, and just want to check out Orthanc website in 15 minutes.| [Orthweb](https://github.com/digihunch/orthweb) project creates its own networking and security layer. | [Orthweb](https://github.com/digihunch/orthweb) project installs Orthanc automatically. |
| You are a healthcare organization, start-up or corporate. Your organization has established [Multiple AWS accounts](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/organizing-your-aws-environment.html) and networking. You want to configure Orthanc in a compliant environment for production. | The infrastructure team configures [landing zone](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/understanding-landing-zones.html) with secure and compliant networking foundation. | The application team configures Orthanc installation, taking [Orthweb](https://github.com/digihunch/orthweb) as a reference. |

For those with Kubernetes skills and complex use cases, check out Orthweb's sister project [Korthweb](https://github.com/digihunch/korthweb) for deployment on Kubernetes.


Follow the rest of this hands-on guide to understand how **Orthweb** works. Skip to the end of the guide for architecture.

## Prerequisite
Whether on Linux, Mac or Windows, you need a command terminal to start deployment.
<details><summary>Required tools</summary>
<p>
* Make sure **[awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)** is installed and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure) so you can connect to your AWS account with as your IAM user (using `Access Key ID` and `Secret Access Key` with administrator privilege). If you will need to SSH to the EC2 instance, you also need to install [session manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html);
* Make sure **Terraform CLI** is [installed](https://learn.hashicorp.com/tutorials/terraform/install-cli). In the Orthweb template, Terraform also uses your IAM credential to [authenticate into AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-credentials-file). 
</p>
</details>
The guide is based on local execution of Terraform commands from MacBook. However, the project can be easily adjusted to work on Windows or even from managed Terraform environment (e.g. Scalr, Terraform Cloud). 

## Preparation
If you already have your own RSA key pair for SSH, or your role does not involve administering the EC2 instance, skip the rest of this section. This section covers the environment variables needed prior to running Terraform command. 

### Secure SSH access
For server administration, you connect to the EC2 instance over SSH. This project mandates [RSA key](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) authentication, and optionally restricts SSH client IP address.

#### RSA key pair for SSH authentication
You need to [create your RSA key pair](https://help.dreamhost.com/hc/en-us/articles/115001736671-Creating-a-new-Key-pair-in-Mac-OS-X-or-Linux). Your public key will be stored as file `~/.ssh/id_rsa.pub` on MacOS or Linux by default. No action is needed if you use default public key location. Orthweb terraform template picks up the file at default path. When provisioning the EC2 instance later, it will tell the server to whitelist this public key. 

If your public key is kept in a non-default file location, you can provide path to public key file in environment variable `TF_VAR_pubkey_path`. If you want to just pass in the public key value, you can provide public key data in the `TF_VAR_pubkey_data` environment variable:
```sh
export TF_VAR_pubkey_data="mockpublickeydatawhichissuperlongdonotputyourprivatekeyherepleaseabcxyzpubkklsss"
```
Terraform template picks up environment variable prefixed with `TF_VAR_` and pass them in as Terraform's [input variable](https://developer.hashicorp.com/terraform/language/values/variables#environment-variables) without the prefix in the name.

#### Limiting SSH client IP
Many admins prefers to restrict access to EC2 instance from a specific range of IP addresses. You can leverage the `cli_cidr_block` variable in Orthweb Terraform template. For example, if you want your public IP the only IP to SSH to the EC2 instances, set environment variable with the following CIDR expression:

> export TF_VAR_cli_cidr_block=$(curl http://checkip.amazonaws.com)/32

Note that if this variable not provided, it defaults to `0.0.0.0/0`, which opens the server's SSH port on the Internet.

### Customize Docker Image
The Orthweb Terraform template comes with working default values for Docker Images. You may override it with your own choice of image or version by declaring environment variable `TF_VAR_DockerImages`.

## Deployment

Now we can start deploying Orthanc. In your command terminal, go to the [`terraform`](https://github.com/digihunch/orthweb/tree/main/terraform) directory and start from there.

First, initialize terraform modules, with `init` command:

> terraform init

The `init` command will initialize Terraform template, download providers, etc. If no error, we can run `plan` command:

> terraform plan

The `plan` command will check current state in the cloud and print out the resources it is going to deploy. If the plan looks good, we can execute the deployment plan, by running:

> terraform apply

In this step Terraform interact with your AWS account to provision the resources and configure the website. You need to say `yes` to the prompt. This process can take as long as 15 minutes due to the amount of resources to be created. Upon successful deployment, the output shall display four entries as output:
|key|example|protocol|purpose|
|--|--|--|--|
|**site_address**|ec2-102-203-105-112.compute-1.amazonaws.com|HTTPS/DICOM-TLS|Business traffic: HTTPS on port 443 and DICOM-TLS on port 11112. Reachable from the Internet.|
|**primary_host**|ec2-user@ec2-44-205-32-174.compute-1.amazonaws.com|SSH|For management traffic: SSH on port 22. Reachable from whitelisted public IPs.|
|s3_bucket|simple-cricket-orthbucket.s3.amazonaws.com|HTTPS-S3| For orthanc to store and fetch images. Access is restricted.|
|db_endpoint|simple-cricket-orthancpostgres.cqfpmkrutlau.us-east-1.rds.amazonaws.com:5432|TLS-POSTGRESQL| For orthanc to index data. Access is restricted.|

The site will come up a couple minutes after the output is printed. We can validate the site with the steps outlined in the sections below. After the evaluation is completed, it is important to remove all the resources because the running resources incurs cost on your AWS bill. To delete resources, use `destroy` command:
> terraform destroy

## User Validation
In this section, we validate the web site through the lens of Orthanc user.

To Validate DICOM capability, we can test with C-ECHO and C-STORE. We can use any DICOM compliant application. For example, [Horos](https://horosproject.org/) on MacOS is a UI-based application. In Preference->Locations, configure a new DICOM nodes with
* Address: the site FQDN
* AE title: ORTHANC
* Port: 11112 (or otherwise configured)

Remember to enable TLS. Then you will be able to verify the node (i.e. C-ECHO) and send existing studies from Horos to Orthanc (C-STORE).

To Validate the the web server, simply visit the site address with the default credential. For example, `https://ec2-102-203-105-112.compute-1.amazonaws.com`. The web browser may flag the site as insecure because Orthweb creats a self-signed certificate during deployment. If you wish to use your own domain name, bring your own certificate.

## Technical Validation
In this section, we cover a few checkpoints from system administrator's perspective, to ensure the system is functional.

### Server Validation

We can connect to the server over SSH. Since we configured IP and public key whitelisting, the following command should just work:
```sh
ssh ec2-user@ec2-44-205-32-174.compute-1.amazonaws.com
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
To emulate DICOM activity, we use [dcm4che3](https://sourceforge.net/projects/dcm4che/files/dcm4che3/), a Java-based open-source utility. Since Orthweb implementation only takes DICOM traffic with TLS enabled, we need to add our site certificate to Java trust store (JKS format). Specifically:

1. On the server, find the .pem file in `/home/ec2-user/orthweb/app/` directory, copy the certificate content (between the lines "BEGIN CERTIFICATE" and "END CERTIFICATE" inclusive), and paste it to a file named `site.crt` on your MacBook.
2. Import the certificate file into a java trust store (e.g. `server.truststore`), with the command below and give it a password, say Password123!
```sh
keytool -import -alias orthweb -file site.crt -storetype JKS -noprompt -keystore server.truststore -storepass Password123!
```
In the next few stpes, the dcm4che utility will trust the certificates imported in this step.

3. Then we can reference this truststore file in C-ECHO and C-STORE. The dcm4che3 utility uses storescu to perform C-ECHO against the server. For example:
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

Orthweb uses Docker Compose to orchestrate multiple Orthanc containers along with an Envoy proxy container. I did not choose ECS due to a [limitation](https://github.com/digihunch/orthweb/issues/1#issuecomment-852669561) and concerns with platform lock-in. To scale up, you may increase the number of replica for Orthanc containers. This scaling model is sufficient for typical Orthanc workload. 

The Orthweb architecture can be illustrated in the diagram below:

![Diagram](resources/Orthweb.png)

The site's IP is associated with an Elastic Network Interface (ENI). It is connected to the primary EC2 instance hosted in availability zone 1. Business traffic (DICOM and HTTP) are routed to the Site IP at port 11112 and 443. Docker damon runs Envoy proxy who listens to those ports. Envoy is a modern proxy implementation with generally better configurability and performance than Nginx. The Envoy proxy, serves two different proxy routes: 
* https on host port 443 -> https on container port 8043
* dicom-tls on host port 11112 -> dicom on container port 4242 
The envoy proxy is configured to spread traffic across three Orthanc containers, with session affinity configured. Each Orthanc container is able to connect to S3 and PostgreSQL database via their respect endpoint in the subnet.

Should availability zone 1 becomes unavailable, system administrator can turn on the secondary EC2 instance in availability zone 2, and associate the ENI with site IP to it. This way we bring availability zone 2 to operation and redirect business traffic to it.


## Security

Orthweb project implements secure configuration as far as it can. For example, it configures a self-signed certificate in the demo. In production deployment however you should bring your own certificates signed by CA. Below are the points of configurations for security compliance:

1. Both DICOM and web traffic are encrypted in TLS. This requires peer DICOM AE to support DICOM TLS in order to connect with Orthanc.
2. PostgreSQL data is encrypted at rest, and the database traffic between Orthanc application and database is encrypted in SSL. The database endpoint is not open to public.
3. The S3 bucket has server side encryption. The traffic in transit between S3 bucket and Orthanc application is encrypted as well. The S3 endpoint is not open to public.
4. The password for database are generated dynamically and stored in AWS Secret Manager in AWS. The EC2 instance is granted access to the secret, which allows the cloud-init script to fetch the secret and launch container with it. 
5. The demo-purpose self-signed X509 certificate is dynamically generated using openssl11 during bootstrapping, in compliance with [Mac requirement](https://support.apple.com/en-us/HT210176).
6. Secret Manager and S3 have their respective VPC interface endpoint in each subnet. Traffic to and from Secret Manager and S3 travels via end points.
7. Secret Manager and S3 have resource-based IAM role to restrict access.

The handling of secret at some points of configurations has room for improvement.
1. Database password is generated at Terraform client and then sent to deployment server to create PostgreSQL. The generated password is also stored in state file of Terraform. To overcome this, we need a) Terraform tells AWS secrets manager to generate a password; and b) it tells other AWS service to resolve the newly created secret. As of May 2021, a) is doable but b) isn't due to a limitation with Terraform
2. Secret management with Docker container: secret are presented to container process as environment variables, instead of file content. As per [this article](https://techbeacon.com/devops/how-keep-your-container-secrets-secure), this is not the best practice.
