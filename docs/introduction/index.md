## Overview

Orthanc handles sensitive data and must be hosted on secure platforms. The motive of Orthweb project is to accelerate Orthanc deployment on AWS. The Orthweb project includes:

1. A prescriptive architecture optimized for hosting Orthanc. The architecture is opinionated but suitable for most of the small installations. The architecture is discussed in this document in a separate section.

2. An Infrastructure-as-code template for end-to-end deploy of Orthanc, aka. the **Orthanc Terraform template**

The specific deployment process in the AWS cloud can vary significantly from organization to organization, depending on the operation model of IT infrastructure. As a result, it is encouraged that you take **Orthweb** as a reference with your organization's own deployment process.

## Use case

If you have an AWS account but without networking infrastructure for Orthanc, you may use [Orthweb](https://github.com/digihunch/orthweb) to build the infrastructure and automatically configure Orthanc. 

If your organization assigns your team with an AWS account and existing networking infrastructure, then you have to create your own virtual machine and install Orthanc. You can use **Orthweb** as a reference implementation to understand how the application interact with underlying cloud resources.

Orthweb assumes that the user has their own account with administrator access. Orthweb creates its own networking layer in order to seamlessly deploy the opinionated architecture. Orthanc cannot be directly deployed to restricted accounts with pre-created networking layer. 

## Toolings

Orthweb selects numerous open-source tools. Here is the rational behind the choice of some platforms and tools.

**Docker Compose** is a simple way to host container workload. Orthweb does not use [Amazon ECS](https://aws.amazon.com/ecs/) due to a [limitation](https://github.com/digihunch/orthweb/issues/1#issuecomment-852669561) and concerns about being locked into a cloud platform. The way **Orthweb** hosts orthanc within EC2 instances also works with other Linux servers, be it physical or virtual. 

**PostgreSQL** is the choice of database amongst all the database engines that Orthanc supports. It is feature rich and supports analytical workloads. Nearly all cloud platforms supports PostgreSQL engine in their managed database offerings.

**Envoy Proxy** is a modern reverse proxy to handle web and DICOm requests. Originally, **Orthweb** started with Nginx proxy. Lately Orthweb deprecated Nginx in favour of Envoy for performance and consistency with Istio Ingress configuration in [Korthweb](https://github.com/digihunch/korthweb) that are Envoy-based.

**Terraform** is a widely used infrastructure-as-code software tool for most common cloud platforms. Terraform templates are written in Hashicorp Configuration Language(HCL), which strikes a good balance between declarativeness and level of abstraction.