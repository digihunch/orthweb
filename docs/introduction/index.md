## Overview

While Orthanc is a powerful open-source medical imaging application, it supports a variety of deployment options. Some users are overloaded with choices. The motive of Orthweb project is to accelerate Orthanc deployment. Orthweb is both:

1. A prescriptive architecture optimized for hosting Orthanc, aka. the **Orthweb architecture**

2. A Infrastructure-as-code artifact for end-to-end automated configuration of Orthanc, aka. the **Orthanc Terraform template**

The **Orthweb architecture**, which is discussed in a separate section, is opinionated but suitable for most of the small installations. The **Orthweb project** demonstrates the idea of infrastructure-as-code, deployment automation and security configurations. However, you should not take it as is for production. 

The specific deployment process in the AWS cloud can vary significantly from organization to organization, depending on the operation model of IT infrastructure. As a result, it is encouraged that you take **Orthweb** as a reference with your organization's own deployment process.

## Use case

Here are the two typical user profiles, and how they can benefit from Orthweb: 

| User profile | Infrastructure Provisioning | Orthanc Installation |
| ----------- | --------- | ---------- |
| Developer, sales, doctor, student, etc, with their own AWS sandbox accounts, who  want to build an Orthanc website real quick.| [Orthweb](https://github.com/digihunch/orthweb) project creates its own networking and security layer. | [Orthweb](https://github.com/digihunch/orthweb) project installs Orthanc automatically. |
| Healthcare organization, start-up or corporates with their own established [cloud foundation](https://docs.aws.amazon.com/whitepapers/latest/organizing-your-aws-environment/organizing-your-aws-environment.html), who want to install Orthanc on top of it. | The infrastructure team deploys [landing zone](https://docs.aws.amazon.com/prescriptive-guidance/latest/migration-aws-environment/understanding-landing-zones.html) with secure and compliant networking foundation. | The application team configures computing resource and with Orthanc installation, using [Orthweb](https://github.com/digihunch/orthweb) as a reference. |

Orthweb assumes that the user starts with a Sandbox account with administrator access. Orthweb creates its own networking layer in order to seamlessly deploy the opinionated architecture. Orthanc cannot be directly deployed to restricted accounts with pre-created networking layer. 

## Toolings

When it comes to tools, Orthweb is prescriptive but all tools are open-source. Here is the rational behind the choice of some platforms and tools.

**Docker Compose** is a simple way to host container workload. Orthweb does not use [Amazon ECS](https://aws.amazon.com/ecs/) due to a [limitation](https://github.com/digihunch/orthweb/issues/1#issuecomment-852669561) and concerns about being locked into a cloud platform. The way **Orthweb** hosts orthanc within EC2 instances also works with other Linux servers, be it physical or virtual. 

**PostgreSQL** is the choice of database amongst all the database engines that Orthanc supports. It is feature rich and supports analytical workloads. Nearly all cloud platforms supports PostgreSQL engine in their managed database offerings.

**Envoy Proxy** is a modern reverse proxy to handle web and DICOm requests. Originally, **Orthweb** started with Nginx proxy. Lately Orthweb deprecated Nginx in favour of Envoy for performance and consistency with Istio Ingress configuration in [Korthweb](https://github.com/digihunch/korthweb) that are Envoy-based.

**Terraform** is a widely used infrastructure-as-code software tool for most common cloud platforms. Terraform templates are written in Hashicorp Configuration Language(HCL), which strikes a good balance between declarativeness and level of abstraction.