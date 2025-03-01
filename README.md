# Orthweb - Orthanc Solution on AWS
<a href="https://www.orthanc-server.com/"><img style="float" align="right" src="docs/assets/images/orthanc_logo.png" width="200"></a>


[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](https://aws.amazon.com/amazon-linux-2)
[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Nginx](https://img.shields.io/badge/nginx-%23009639.svg?&logo=nginx&logoColor=white)](https://nginx.org/en/index.html)
[![Keycloak](https://img.shields.io/badge/Keycloak-4D4D4D?logo=keycloak&logoColor=white&style=flat)](https://www.keycloak.org/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Amazon EC2](https://img.shields.io/badge/Amazon%20EC2-F90?logo=amazonec2&logoColor=white&style=flat)](https://aws.amazon.com/ec2/)
[![Amazon S3](https://img.shields.io/badge/Amazon%20S3-569A31?logo=amazons3&logoColor=white&style=flat)](https://aws.amazon.com/s3/)
[![Amazon RDS](https://img.shields.io/badge/Amazon%20RDS-527FFF?logo=amazonrds&logoColor=white&style=flat)](https://aws.amazon.com/rds/postgresql/)

## Overview

The **[Orthweb](https://github.com/digihunch/orthweb)** project automates the creation of a cloud-based mini-[PACS](https://en.wikipedia.org/wiki/Picture_archiving_and_communication_system) based on **[Orthanc](https://www.orthanc-server.com/)** and Amazon Web Services (AWS). The project artifact addresses the cloud foundation and configuration management, and enables adopters to host the Orthanc software as a service ([SaaS](https://en.wikipedia.org/wiki/Software_as_a_service)). To get started, follow the [documentation](https://digihunch.github.io/orthweb/). 💪 Let's automate medical imaging!

Imaging systems handling sensitive data must operate on secure platforms. Typically, large organizations dedicate specialized IT resources to build their enterprise-scale cloud foundations. This cloud foundation, also known as a [landing zone](https://www.digihunch.com/2022/12/landing-zone-in-aws/), addresses security and scalability. Each line of business of the large organization is allocated with a segment (e.g. an VPC) in the landing zone, to deploy their own applications.

However, many Orthanc adopters are small teams without overarching cloud strategies from their parent organizations. They are startups, research groups, independent clinics, and so on. To leverage Orthanc capabilities, they need simple cloud foundations that are equally secure and scalable. To close this gap, we proposed and implemnted a cloud-based Orthanc solution: the [**Orthweb** project](https://www.digihunch.com/2020/11/medical-imaging-web-server-deployment-pipeline/). 

  ![Diagram](docs/assets/images/Overview.png)

To build the foundation fast, **Orthweb** project uses **Terraform** template (an [infrastructure-as-code](https://en.wikipedia.org/wiki/Infrastructure_as_code) technology) to provision a self-contained infrastrcture stack in a single AWS account, without relying upon established network infrastructure. The infrastructure layer provisioned in this project contains a single VPC with multiple subnets, along with optional VPC endpoints. The infrastructure layer also contains encryption keys, managed database service and S3 storage.

The **Orthweb** project also streamlines the configuration of Orthanc solution, by proposing a paradign for Orthanc configuration management. The project leverages cloud-init [user data](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html) and `makefile` to configure the servers during the server's initialization process. The artifact to install **Orthanc** is stored in a separate repository for adopters to fork and customize. The [orthanc-config](https://github.com/digihunchinc/orthanc-config) repository is a good example.
<br/><br/>

The project orchestrates the application containers with Docker daemon on EC2 instances. Technical users can expect to build a cloud-based mini-PACS in one hour with rich feature, scalability and security. For those considering hosting Orthanc on Kubernetes, check out the sister project [Korthweb](https://github.com/digihunch/korthweb).

## Partners
<a href="https://www.yorku.ca/health"><img align="left" src="docs/assets/images/yorku-logo.jpg" style="width: 20%;"></a> <br><br>

**[York MRI Facility](https://mri.info.yorku.ca/)**