## Overview

Orthanc handles sensitive data and therefore must be hosted on secure platforms. The motive of **Orthweb** project is to accelerate Orthanc deployment on the AWS cloud platform. The Orthweb project includes:

1. A prescriptive architecture optimized for hosting Orthanc. The architecture is opinionated but suitable for most of the small installations. The architecture is discussed in this document in the Architecture section.

2. An Infrastructure-as-code template for end-to-end deploy of Orthanc, aka. the **Orthanc Terraform template** available in the [orthweb](https://github.com/digihunch/orthweb) GitHub repository.

3. A prescriptive Orthanc configuration with automation available in the [orthanc-config](https://github.com/digihunchinc/orthanc-config) GitHub repository.

The specific deployment process in the AWS cloud can vary significantly from organization to organization, depending on the operation model of IT infrastructure. As a result, it is encouraged that you take the effort to integrate the resources in **Orthweb** with your organization's own deployment process.

## Use case

If you have an AWS account but without networking infrastructure for Orthanc, you may use the template in [Orthweb](https://github.com/digihunch/orthweb) to build the infrastructure. Then you may use the configuration in [orthanc-config](https://github.com/digihunchinc/orthanc-config) to automatically configure Orthanc. 

If your organization assigns your team with an AWS account and existing networking infrastructure, then you have to create your own virtual machine and install Orthanc. You can use **Orthweb** as a reference implementation to understand how the application interact with underlying cloud resources.

Orthweb assumes that the user has their own account with administrator access. Orthweb creates its own networking layer in order to seamlessly deploy the opinionated architecture. Orthanc cannot be directly deployed to restricted accounts with pre-created networking layer. 

## Toolings

Orthweb selects numerous open-source tools. Here is the rational behind the choice of some platforms and tools.

**Terraform** is a widely used infrastructure-as-code software tool for most common cloud platforms. Terraform templates are written in Hashicorp Configuration Language(HCL), which strikes a good balance between declarativeness and level of abstraction.

**Docker Compose** is a simple way to host container workload. Orthweb does not use [Amazon ECS](https://aws.amazon.com/ecs/) due to a [limitation](https://github.com/digihunch/orthweb/issues/1#issuecomment-852669561) and concerns about being locked into a cloud platform. The way **Orthweb** hosts orthanc within EC2 instances also works with other Linux servers, be it physical or virtual. 

**PostgreSQL** is the choice of database amongst all the database engines that Orthanc supports. It is feature rich and supports analytical workloads. Nearly all cloud platforms supports PostgreSQL engine in their managed database offerings. In AWS, the project creates an RDS instance with PostgreSQL engine.

**Nginx Proxy** is a widely adopted reverse proxy to handle web and DICOM requests. **Orthweb** adopted Envoy Proxy from 2022 to 2024, but eventually switched to Nginx as the default reverse proxy because it is the main choice in the Orthanc user community.

**Amazon S3** is a scalable, feature-rich object storage platform well integrated with other AWS cloud services. Orthanc supports S3 as storage for DICOM objects.