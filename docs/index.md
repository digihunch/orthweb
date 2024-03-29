# Orthweb - Orthanc on AWS
<a href="https://www.orthanc-server.com/"><img style="float" align="right" src="assets/images/orthanc_logo.png"></a>

[![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?logo=docker&logoColor=white)](https://www.docker.com/)
[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Postgres](https://img.shields.io/badge/postgres-%23316192.svg?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![envoybadge](https://img.shields.io/badge/envoyproxy-%23ac6199.svg?logo=envoyproxy&logoColor=white)](https://www.envoyproxy.io/)
[![Linux](https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black)](https://aws.amazon.com/amazon-linux-2)
[![AWS](https://img.shields.io/badge/AWS-%23FF9900.svg?logo=amazon-aws&logoColor=white)](https://portal.aws.amazon.com/)

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Latest Release](https://img.shields.io/github/v/release/digihunch/orthweb)](https://github.com/digihunch/orthweb/releases/latest) 


**[Orthweb](https://github.com/digihunch/orthweb)** helps imaging IT administrators operationalize **[Orthanc](https://www.orthanc-server.com/)** on AWS. It proposes a self-contained architecture, and accelerates the deployment of it. Bring your own AWS account, and **Orthweb** help you set up Orthanc server in half an hour, ready to serve HTTP and DICOM traffic.

The **[Orthweb](https://github.com/digihunch/orthweb)** project proposes an architecture that involves numerous underlying cloud resources in AWS (e.g. VPC, subnets, Secret Manager, RDS, S3) with security, automation and high availability in consideration. **Orthweb** orchestrate these resources with Infrastructure as Code in Terraform.

On top of the infrastructre, **Orthweb** also automatically configures the hosting of **Orthanc** application with Docker, using the [Orthanc image](https://hub.docker.com/r/osimis/orthanc) released by [Osimis](https://www.osimis.io/). For those who need to host Orthanc on Kubernetes, check out Orthweb's sister project [Korthweb](https://github.com/digihunch/korthweb).

This guide first discusses the usecases. Then it walks through the deployment steps, and provides guidance on system validation. Lastly, it discusses the architecture and the rationales. 
