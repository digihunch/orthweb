# Orthweb - Orthanc on AWS
<a href="https://www.orthanc-server.com/"><img style="float" align="right" src="docs/assets/images/orthanc_logo.png"></a>

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![envoybadge](https://img.shields.io/badge/envoyproxy-%23ac6199.svg?logo=envoyproxy&logoColor=white)](https://www.envoyproxy.io/)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](https://aws.amazon.com/amazon-linux-2)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?logo=amazon-aws&logoColor=white)](https://portal.aws.amazon.com/)
[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Latest Release](https://img.shields.io/github/v/release/digihunch/orthweb)](https://github.com/digihunch/orthweb/releases/latest) 
## Overview

**[Orthweb](https://github.com/digihunch/orthweb)** helps imaging IT administrators operationalize **[Orthanc](https://www.orthanc-server.com/)** on AWS. It proposes a self-contained architecture, and accelerates the deployment of it. Bring your own AWS account, and **Orthweb** help you set up Orthanc server in half an hour, ready to serve HTTP and DICOM traffic.

The **[Orthweb](https://github.com/digihunch/orthweb)** project proposes an architecture that involves numerous underlying cloud resources in AWS (e.g. VPC, subnets, Secret Manager, RDS, S3) with security, automation and high availability in consideration. **Orthweb** orchestrate these resources with Infrastructure as Code in Terraform.

The Infrastructure as Code is scanned by Checkov to ensure compliance. Here is the summary of current compliance status as reported by BridgeCrew:

| Benchmark | Description |
| ----------- | --------- |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/digihunch/orthweb/general)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=digihunch%2Forthweb&benchmark=INFRASTRUCTURE+SECURITY) | Infrastructure Security Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/digihunch/orthweb/cis_aws)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=digihunch%2Forthweb&benchmark=CIS+AWS+V1.2) | Center for Internet Security, AWS Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/digihunch/orthweb/nist)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=digihunch%2Forthweb&benchmark=NIST-800-53) | National Institute of Standards and Technology Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/digihunch/orthweb/iso)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=digihunch%2Forthweb&benchmark=ISO27001) | Information Security Management System, ISO/IEC 27001 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/digihunch/orthweb/soc2)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=digihunch%2Forthweb&benchmark=SOC2) | Service Organization Control 2 Compliance |
| [![Infrastructure Tests](https://www.bridgecrew.cloud/badges/github/digihunch/orthweb/hipaa)](https://www.bridgecrew.cloud/link/badge?vcs=github&fullRepo=digihunch%2Forthweb&benchmark=HIPPA) | Health Insurance Portability and Accountability Compliance |

On top of the infrastructre, **Orthweb** also automatically configures the hosting of **Orthanc** application with Docker, using the [Orthanc image](https://hub.docker.com/r/osimis/orthanc) released by [Osimis](https://www.osimis.io/). For those who need to host Orthanc on Kubernetes, check out Orthweb's sister project [Korthweb](https://github.com/digihunch/korthweb).

The [Orthweb documentation](https://digihunch.github.io/orthweb/) includes a step-by-step guide for deployment and more details about the architecture.
