# OrthWeb - an open-source Orthanc deployment (medical imaging application)

Orthweb is a medical imaging PoC deployment on Amazon Web Service, based on  **Orthanc**, open-source project to ingest, store, view and distribute medical images.
# Prerequisite
* AWS account required permission
* AWS cli configured on the client (see [instruction](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html))
* terraform configured on the client (see [instruction](https://learn.hashicorp.com/tutorials/terraform/install-cli))

# Application

The application is provided by [Orthanc - DICOM Server](https://www.orthanc-server.com/), an open-source **DICOM server**. They [release](https://www.orthanc-server.com/download.php) in all common platforms, including [Docker image](https://hub.docker.com/u/jodogne/). The source code are available [here](https://hg.orthanc-server.com/). **DICOM** is a standard under ISO that defines how medical imaging data are exchanged between healthcare informatics systems. It involves DICOM Upper Layer Protocol, an OSI layer 7 protocol to allow data exchange over TCP/IP network. It also includes definition of file format, commonly referred to as DICOM Part 10 file in healthcare IT.

The Orthanc application receives medical imaging data from devices in DICOM protocol. It also allows clinical users to view images through web browser. This Orthweb project includes the application in Docker and an example of Infrastructure as Code that hosts the environment.


# Infrastructure

The infrastructure is provisioned from AWS (Amazon Web Services), in Terraform. Terraform is an infrastructure as code tool that support multiple public cloud vendors, **AWS** being one of the popular providers. Here are the most basic commands in Terraform:

To initialize terraform template, run:
> terraform init

To view resources to be created, run:
> terraform plan

To execute the template, run:
> terraform apply

To reclaim the resources
> terraform destroy

To remove a single resource (e.g. ec2 instance) and dependent
> terraform destroy -target aws_instance.orthweb

To re-create a single resource (e.g. ec2 instance) 
> terraform apply -target aws_instance.orthweb

To start provisioning resources, an AWS credential with sufficient privileges must be provided. More information about permissions are provided [here](https://www.terraform.io/docs/cloud/users-teams-organizations/permissions.html). The user only needs programatic access, with its Access Key ID and Secret access key retrievable on the client where terraform is executed. You should also configure local aws-cli environment by running:
> aws configure

Terraform's AWS provider is built with AWS SDK, therefore it automatically picks up local AWS environment, including the credentials, and region.

The Terraform template creates a virtual private cloud (VPC), a subnet, an EC2 instance. It also creates an RDS instance for PostgreSQL database as data store to index patient, exam data as well as storing images. Below is a diagram of the key components.

![Diagram](resources/Orthweb.png)

The bootstrap script of EC2 instance provisions Docker environment and load up the Docker image. This sample project provides a minimally functional stack without high availability setup and with only basic security setups. A self-signed X509 certificate (along with private key :) for browser and DICOM traffic.  Once the instance is launched, the public DNS name of the EC2 instance and RDS instances are printed. Functional validation can be attempted from the followings:

* Web service is available at: https://orthweb.ec2.url:8042 with a self-signed sample certificate which may triger a warning at browser. Since Orthanc natively support SSL/TLS, there is no reverse proxy involved. Nginx as reverse proxy is a good alternative to terminate TLS traffic, which is used for DICOM traffic. To log on, default credential is orthanc/orthanc (as indicated in [Orthanc Book](https://book.orthanc-server.com/index.html)). 
* DICOM entry point is available at ORTHANC@orthweb.ec2.url:11112. Nginx is used to terminate SSL and proxy incoming traffic to upstream at port 4242, Orthanc's unentrypted DICOM port. This is because [TLS encryption is not supported](https://book.orthanc-server.com/faq/security.html) as of Orthanc 1.8. Peer application entity (AE) must encrypt DICOM traffic across the Internet.
* RDS will be accessible from the EC2 instance, on port 5432. To validate by psql client, run:
>psql --host=localhost --port 5432 --username=myuser --dbname=orthancdb

To disable HTTPS, set SslEnabled to false in orthanc.json. The terraform template in the example only creates one EC2 instance for simplicity. In reality it can be placed in autoscaling group.
 
The application UI provides very intuitive visual components to open an exam, and preview instances (images). It also supports the ability to save DICOM studies as part 10 files. [Orthanc Book](https://book.orthanc-server.com/index.html) is the official resource in regard with the configuration, customization and implementation of Orthanc. 

# Architecture Q & A

* Why Orthanc? Orthanc is an open-source, application released in containers.
* Why EC2? Because of limitations with ECS. Refer to [this](https://github.com/digihunch/orthweb/issues/1#issuecomment-852669561) comment. The best way to build operation environment is Kubernetes.
* Why PostgreSQL? In this configuration we use PostgreSQL to store both patient index and pixel data. S3 plugin is a commercial product not available to public and not straightforward to build.
* Why Terraform? Terraform has better modularization support than CloudFormation. It is easier to set up than AWS CDK.
* Why Docker? This POC does not include complex orchestration. A docker-compose suffices for the use case. Or Kubernetes cluster should be used for advanced orchestration.
* Why AWS? It doesn't have to. In fact I prefer a provider independent setup. However, we need database as service from cloud provider so the code has to be specific to a cloud provider.


# Security
Check out [this post](https://www.digihunch.com/2021/05/secure-web-application-deployment/) for more details.

Configuration
1. Both DICOM and web traffic are encrypted in TLS
2. PostgreSQL data is encrypted at rest, and the traffic to and from application container is encrypted in transit.
3. The master user and password for database are now generated dynamically, in the secret manager in AWS. The EC2 instance is granted with the role to access the secret. The cloud-init script will be given the private endpoint of secret manager to pull the secret into a file. Docker compose maps the secret file to environment variables inside of container.
4. Since the X509 certificate is self-signed for demo, it is now dynamically generated using openssl11 during bootstrapping, in compliance with [Mac requirement](https://support.apple.com/en-us/HT210176).

Vulnerabilities
1. the traffic between nginx container and orthan container is unencrypted
2. Database password is generated at Terraform client and then sent to deployment server to create PostgreSQL. The generated password is also stored in state file of Terraform. To overcome this, we need a) Terraform tells AWS secrets manager to generate a password; and b) it tells other AWS service to resolve the newly created secret. a) is doable but b) isn't due to a limitation with Terraform
3. Secret management with Docker container: secret are presented to container process as environment variables, instead of file content. As per [this article](https://techbeacon.com/devops/how-keep-your-container-secrets-secure), it is not recommended because environment variable could be leaked out.
