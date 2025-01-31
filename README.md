# Orthweb - Orthanc Solution on AWS
<a href="https://www.orthanc-server.com/"><img style="float" align="right" src="docs/assets/images/orthanc_logo.png"></a>


[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](https://aws.amazon.com/amazon-linux-2)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?&logo=nginx&logoColor=white)](https://nginx.org/en/index.html)
![Keycloak](https://img.shields.io/badge/Keycloak-4D4D4D?logo=keycloak&logoColor=white&style=flat)

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Amazon EC2](https://img.shields.io/badge/Amazon%20EC2-F90?logo=amazonec2&logoColor=white&style=flat)](https://aws.amazon.com/ec2/)
[![Amazon S3](https://img.shields.io/badge/Amazon%20S3-569A31?logo=amazons3&logoColor=white&style=flat)](https://aws.amazon.com/s3/)
[![Amazon RDS](https://img.shields.io/badge/Amazon%20RDS-527FFF?logo=amazonrds&logoColor=white&style=flat)](https://aws.amazon.com/rds/postgresql/)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Latest Release](https://img.shields.io/github/v/release/digihunch/orthweb)](https://github.com/digihunch/orthweb/releases/latest) 

## Overview

The **[Orthweb](https://github.com/digihunch/orthweb)** project helps imaging IT staff build an **[Orthanc](https://www.orthanc-server.com/)** solution on AWS. The project addresses the cloud foundation and configuration management to host Orthanc. Follow to the [documentation](https://digihunch.github.io/orthweb/) for instructions and architecture discussions.

Orthanc handles sensitive data and must operate on a secure cloud platform. Typically, large organizations can afford specialized IT resources to build enterprise-scale cloud foundations. This cloud foundation is known as a [landing zone](https://www.digihunch.com/2022/12/landing-zone-in-aws/). Each department in the organization is allocated with a segment of the landing zone (e.g. an VPC), to deploys their own applications. 

In reality, many Orthanc users are small entities (e.g. startups, research groups, independent clinics, etc) without an overarching cloud strategy. They need a secure and scalable cloud foundation to leverage Orthanc. To fill this gap, **Orthweb** project was [created](https://www.digihunch.com/2020/11/medical-imaging-web-server-deployment-pipeline/) to propose a cloud-based Orthanc solution, to address the cloud foundation and configuration management.

<img align="middle" src="docs/assets/images/Overview.png">
<br/><br/>

For cloud foundation, **Orthweb** project uses **Terraform** template (an infrastructure-as-code technology) provisions its own self-contained infrastrcture stack in a single AWS account. It does not rely upon an established network infrastructure platform. The network infrastructure layer provisioned in this project contains a single VPC with multiple subnets, along with required endpoints. The infrastructure layer also contains encryption keys, managed database service and S3 storage. The infrastrcture footprint is small but secure. It aims to comply with regulatory requirements such as HIPPA. However, regulatory auditing is the responsibility of the Orthanc adopter. For configuration management, **Orthweb** leverages cloud-init [user data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) and `makefile` to configure the servers upon initialization. The artifact to install **Orthanc** is stored in the [orthanc-config](https://github.com/digihunchinc/orthanc-config) repository. 
<br/><br/>

The project architecture also takes into account other operational aspects, such as high availability, resiliency and automation in the configuration of **Orthanc** application with Docker, using the official [Orthanc image](https://hub.docker.com/r/orthancteam/orthanc). For those considering hosting Orthanc on Kubernetes, check out our sister project [Korthweb](https://github.com/digihunch/korthweb).

## Partners
<a href="https://www.yorku.ca/health"><img align="left" src="docs/assets/images/yorku-logo.jpg" style="width: 20%;"></a> <br><br>

**[York MRI Facility](https://mri.info.yorku.ca/)**