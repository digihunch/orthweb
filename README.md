# OrthWeb - Orthanc deployment in Docker on AWS

## Overview
**[Orthanc](https://www.orthanc-server.com/)** is an open-source application for medical imaging, allowing users to ingest, store, view and distribute medical images. **Orthweb** is a cloud deployment project for Orthanc on Amazon Web Services (AWS). The project automatically deploys required resources on AWS. As soon as the deployment is completed, the website is ready to serve web and DICOM traffic.

This deployment environment is for developers or for demo. For an operation-friendly deployment, please check out the **[Korthweb](https://github.com/digihunch/korthweb)** project for deployment on Kubernetes. In this Orthweb project, we use Terraform to create cloud infrastructure as code, including public and private networks, secret manager, managed database (PostgreSQL), and an EC2 instance (i.e. Virtual Machine). The initialization process of the EC2 instance configures Docker, and uses the docker compose file in this repository to launch the site.

## Prerequisite
We can execute deployment locally (e.g. from your Laptop) or remotely (e.g. from Terraform Cloud). Either way requires programatic access to AWS account with sufficient [privilege](https://www.terraform.io/docs/cloud/users-teams-organizations/permissions.html) (e.g. Administrator) to provision the resources involved. For local execution, we need: 
* **awsli** configured on the laptop (see [instruction](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)) to ensure connectivity to AWS, which will be used by Terraform.
* **terraform** configured on the laptop (see [instruction](https://learn.hashicorp.com/tutorials/terraform/install-cli)). Terraform supports multiple public cloud vendors. We use Terraform to drive AWS deployment by specifying *hashicorp/aws* as provider.

## Steps

We use a standard local-execution workflow for Terraform, starting from the terraform directory:

1. Initialize terraform modules, by running:
> terraform init
2. View resources to create, by running:
> terraform plan
3. Execute the deployment, by running:
> terraform apply

Upon successful deployment, the deployment output the DNS name of the EC2 instance. You will be able to access the website at https://ec2-ip-address-public-dns.amazonaws.com:8042, and be able to send DICOM studies to port 4242.

If you do not need the resource at the end of testing, to remove all the resources, run:
> terraform destroy

## Orthanc DICOM server

The source code of Orthanc is available [here](https://hg.orthanc-server.com/). The [release](https://www.orthanc-server.com/download.php) is available in common platforms, including [Docker image](https://hub.docker.com/u/jodogne/), which is used in this project.

**DICOM** is a standard under ISO that defines how medical imaging data are exchanged between healthcare informatics systems. It involves DICOM Upper Layer Protocol, an OSI layer 7 protocol to allow data exchange over TCP/IP network. It also includes definition of file format, commonly referred to as DICOM Part 10 file in healthcare IT.

The Orthanc application receives medical imaging data from devices in DICOM protocol. It also allows clinical users to view images through web browser. This Orthweb project includes the application in Docker and an example of Infrastructure as Code that hosts the environment.

![Diagram](resources/Orthweb.png)

The bootstrap script of EC2 instance provisions Docker environment and load up the Docker image. This sample project provides a minimally functional stack without high availability setup and with only basic security setups. A self-signed X509 certificate (along with private key :) for browser and DICOM traffic.  Once the instance is launched, the public DNS name of the EC2 instance and RDS instances are printed. Functional validation can be attempted from the followings:

* Web service is available at: https://orthweb.ec2.url:8042 with a self-signed sample certificate which may triger a warning at browser. Since Orthanc natively support SSL/TLS, there is no reverse proxy involved. Nginx as reverse proxy is a good alternative to terminate TLS traffic, which is used for DICOM traffic. To log on, default credential is orthanc/orthanc (as indicated in [Orthanc Book](https://book.orthanc-server.com/index.html)). 
* DICOM entry point is available at ORTHANC@orthweb.ec2.url:11112. Nginx is used to terminate SSL and proxy incoming traffic to upstream at port 4242, Orthanc's unentrypted DICOM port. This is because [TLS encryption is not supported](https://book.orthanc-server.com/faq/security.html) as of Orthanc 1.8. Peer application entity (AE) must encrypt DICOM traffic across the Internet.
* RDS will be accessible from the EC2 instance, on port 5432. To validate by psql client, run:
>psql --host=localhost --port 5432 --username=myuser --dbname=orthancdb

To disable HTTPS, set SslEnabled to false in orthanc.json. The terraform template in the example only creates one EC2 instance for simplicity. In reality it can be placed in autoscaling group.
 
The application UI provides very intuitive visual components to open an exam, and preview instances (images). It also supports the ability to save DICOM studies as part 10 files. [Orthanc Book](https://book.orthanc-server.com/index.html) is the official resource in regard with the configuration, customization and implementation of Orthanc. 

## Architecture Q & A

* Why Orthanc? Orthanc is an open-source, application released in containers.
* Why EC2? Because of limitations with ECS. Refer to [this](https://github.com/digihunch/orthweb/issues/1#issuecomment-852669561) comment. A better way to build operation environment is Kubernetes, check out this [Korthweb](https://github.com/digihunch/korthweb) project.
* Why PostgreSQL? In this configuration we use PostgreSQL to store both patient index and pixel data. S3 plugin is a commercial product not available to public and not straightforward to build.
* Why Terraform? Terraform has better modularization support than CloudFormation. It is easier to set up than AWS CDK.
* Why Docker? This POC does not include complex orchestration. A docker-compose suffices for the use case. Or Kubernetes cluster should be used for advanced orchestration. The [Korthweb](https://github.com/digihunch/korthweb) project gives a template to create cluster in EKS.
* Why AWS? It doesn't have to. In fact I prefer a provider independent setup. However, we need database as service from cloud provider so the code has to be specific to a cloud provider.

## Security

### Configurations for security
1. Both DICOM and web traffic are encrypted in TLS
2. PostgreSQL data is encrypted at rest, and the traffic to and from application container is encrypted in transit.
3. The master user and password for database are now generated dynamically, in the secret manager in AWS. The EC2 instance is granted with the role to access the secret. The cloud-init script will be given the private endpoint of secret manager to pull the secret into a file. Docker compose maps the secret file to environment variables inside of container.
4. Since the X509 certificate is self-signed for demo, it is now dynamically generated using openssl11 during bootstrapping, in compliance with [Mac requirement](https://support.apple.com/en-us/HT210176).

Check out this [blog post](https://www.digihunch.com/2021/05/secure-web-application-deployment/) for further details design considerations.

### Known Limitations
The followings are identified as not up to highest security standard. They may not be important for a demo system, but should be addressed for a production system. The **[Korthweb](https://github.com/digihunch/korthweb)** deployment project does not have these limitations.
1. the traffic between nginx container and orthan container is unencrypted
2. Database password is generated at Terraform client and then sent to deployment server to create PostgreSQL. The generated password is also stored in state file of Terraform. To overcome this, we need a) Terraform tells AWS secrets manager to generate a password; and b) it tells other AWS service to resolve the newly created secret. a) is doable but b) isn't due to a limitation with Terraform
3. Secret management with Docker container: secret are presented to container process as environment variables, instead of file content. As per [this article](https://techbeacon.com/devops/how-keep-your-container-secrets-secure), it is not recommended because environment variable could be leaked out.
