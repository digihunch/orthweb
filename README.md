# OrthWeb - Orthanc deployment in Docker on AWS

## Overview

**[Orthanc](https://www.orthanc-server.com/)** is an open-source application for medical imaging, allowing users to ingest, store, view and distribute medical images. **Orthweb** is a cloud deployment project for Orthanc on Amazon Web Services (AWS). The project automatically deploys required resources on AWS. As soon as the deployment is completed, the website is ready to serve web and DICOM traffic.

This deployment environment is for developers or for demo. For an operation-friendly deployment, please check out the **[Korthweb](https://github.com/digihunch/korthweb)** project for deployment on Kubernetes. In this Orthweb project, we use Terraform to create cloud infrastructure as code, including public and private networks, secret manager, managed database (PostgreSQL), and an EC2 instance (i.e. Virtual Machine). The initialization process of the EC2 instance configures Docker, and uses the docker compose file in this repository to launch the site.

## Prerequisite

We can execute deployment locally (e.g. from Laptop) or remotely (e.g. from Terraform Cloud, if you have an account). This instruction assumes local execution but either way requires programatic access to AWS account with appropriate [privilege](https://www.terraform.io/docs/cloud/users-teams-organizations/permissions.html) (e.g. Administrator). For local execution, we use Terraform client (aka [Terraform CLI](https://www.terraform.io/docs/cli/commands/index.html)), with *hashicorp/aws* [provider]((https://registry.terraform.io/providers/hashicorp/aws/latest/docs)). There are multiple ways to manage connectivity. One way is to share [credentials file](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with **awscli** as discussed [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-credentials-file). To set up credential for awscli, see this [instruction](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).
.

## Steps

We use a standard local-execution workflow for Terraform, starting from the terraform directory:

1. Initialize terraform modules, by running:

> terraform init

2. View resources to create, by running:

> terraform plan

3. Execute the deployment, by running:

> terraform apply

Upon successful deployment, the console output displays the DNS name of the EC2 instance. You will be able to access the website at <https://ec2-ip-address-public-dns.amazonaws.com:8042>, and be able to send DICOM studies to port 4242.

If you do not need the resource at the end of testing, to remove all the resources, run:
> terraform destroy

## Connect to the Server

Although the website is up at the end of deployment, for many reasons, you might want to connect to the EC2 instance in SSH. EC2 instance manages SSH authentication by (RSA key pairs)[https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html]: we give it our public key  prior to provisioning, and later SSH to it with our private key as identity. This project assumes users have their own RSA key pair, and employs a technique to upload user's public key, either by providing key text directly, or by specifying the location of the file that stores key text. The former option overrides the latter. In other words, if the *public_key* variable is specified, then the *local_pubkey_file* variable is ignored. 

In general, there are [a number of ways](https://www.terraform.io/docs/language/values/variables.html#assigning-values-to-root-module-variables) to specify a variable in Terraform code. For example, to specify public key content as the value of variable *public_key*, we can pass it in as command argument:

```sh
terraform plan -var public_key="fakepublickeyabcxyzpubkklsss"
terraform apply -var public_key="fakepublickeyabcxyzpubkklsss"
```

We can also assign value to *public_key* variable, by setting environment variable with specific name prior to running terraform command as below. This can be used when running terraform script from Terraform Cloud.

```sh
export TF_VAR_public_key="fakepublickeyabcxyzpubkklsss"
terraform plan
```

Alternatively, we can specify the location of the file that stores the public key text, to variable *local_pubkey_file*

```sh
terraform plan -var local_pubkey_file="/tmp/public.key"
```
The default value for *public_key* is null, and the default value for *local_pubkey_file* is ~/.ssh/id_rsa.pub. Therefore, if you do not specify either of the variables above, then the Terraform code attempts to fetch public key text from ~/.ssh/id_rsa.pub file, which is the default location of public key by OpenSSH. Because of this setup, the Terraform project should work off the shelf for users with default OpenSSH configuration, without having to provide public key explicitly.


## About Orthanc DICOM server

The source code of Orthanc is available [here](https://hg.orthanc-server.com/). The [release](https://www.orthanc-server.com/download.php) is available in common platforms, including [Docker image](https://hub.docker.com/u/jodogne/), which is used in this project.

**DICOM** is a standard under ISO that defines how medical imaging data are exchanged between healthcare informatics systems. It involves DICOM Upper Layer Protocol, an OSI layer 7 protocol to allow data exchange over TCP/IP network. It also includes definition of file format, commonly referred to as DICOM Part 10 file in healthcare IT.

The Orthanc application receives medical imaging data from devices in DICOM protocol. It also allows clinical users to view images through web browser. This Orthweb project includes the application in Docker and an example of Infrastructure as Code that hosts the environment.

![Diagram](resources/Orthweb.png)

The bootstrap script of EC2 instance provisions Docker environment and load up the Docker image. This sample project provides a minimally functional stack without high availability setup and with only basic security setups. A self-signed X509 certificate (along with private key :) for browser and DICOM traffic.  Once the instance is launched, the public DNS name of the EC2 instance and RDS instances are printed. Functional validation can be attempted from the followings:

* Web service is available at: <https://orthweb.ec2.url:8042> with a self-signed sample certificate which may triger a warning at browser. Since Orthanc natively support SSL/TLS, there is no reverse proxy involved. Nginx as reverse proxy is a good alternative to terminate TLS traffic, which is used for DICOM traffic. To log on, default credential is orthanc/orthanc (as indicated in [Orthanc Book](https://book.orthanc-server.com/index.html)).
* DICOM entry point is available at ORTHANC@orthweb.ec2.url:11112. Nginx is used to terminate SSL and proxy incoming traffic to upstream at port 4242, Orthanc's unentrypted DICOM port. This is because [TLS encryption is not supported](https://book.orthanc-server.com/faq/security.html) as of Orthanc 1.8. Peer application entity (AE) must encrypt DICOM traffic across the Internet.
* RDS will be accessible from the EC2 instance, on port 5432. To validate by psql client, run:

>psql --host=localhost --port 5432 --username=myuser --dbname=orthancdb

To disable HTTPS, set SslEnabled to false in orthanc.json. The terraform template in the example only creates one EC2 instance for simplicity. In reality it can be placed in autoscaling group.

The application UI provides very intuitive visual components to open an exam, and preview instances (images). It also supports the ability to save DICOM studies as part 10 files. [Orthanc Book](https://book.orthanc-server.com/index.html) is the official resource in regard with the configuration, customization and implementation of Orthanc.

## Architecture Q & A

* Why Docker on EC2? The alternative to EC2 is ECS but ECS has limitations. Refer to [this](https://github.com/digihunch/orthweb/issues/1#issuecomment-852669561) comment. For production use, we should put EC2 instances in an autoscaling group behind load balancer. As to Docker vs Kubernetes. First, for large deployment, Kubernetes is a better way to deploy Orthanc. Check out this [Korthweb](https://github.com/digihunch/korthweb) project. However, the complexity and additional layer brought in by Kubernetes may not be worth all the effort, especially for a small deployment. A docker-compose is sufficient for typical Orthanc use case. Check out [this](https://ably.com/blog/no-we-dont-use-kubernetes) article for the case against Kubernetes.
* Why AWS? It doesn't have to. In fact I prefer a provider independent setup. However, we need database as service from cloud provider so the code has to be specific to a cloud provider. Also, I'm more familiar with AWS than other platforms.
* Why PostgreSQL? We can use PostgreSQL to store both patient index and pixel data.
* Why Terraform? Terraform has better modularization support than CloudFormation. It is easier to set up than AWS CDK.

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
