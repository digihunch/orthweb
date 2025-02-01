
## Overview
Since we execute Terraform commands locally to drive the deployment, we also store Terraform states locally. Advanced Terraform users may choose to managed Terraform platform such as Terraform Cloud or Scalr, which is beyond the scope of this document. 

Now we can start deploying Orthanc. From your command terminal, go to the [`terraform`](https://github.com/digihunch/orthweb/tree/main/terraform) directory, and run `terraform` commands from this directory.

## Terraform Init
First, initialize terraform template with this command:
```sh
terraform init
```
The command initializes Terraform template, including pulling external modules and download providers. Successful initialization should report the following line: 

```
Terraform has been successfully initialized!
```

After initialization, terraform creates `.terraform` directory to store the pulled modules and providers.

## Terraform Plan
We plan the deployment with this command:

```sh
terraform plan
```

The is command projects the changes that will be applied to AWS. It will print out the resources and what changes Terraform will make.

If you're running this command for the first time, Terraform will flag all resources as to be created. If you're running the command with a change of Terraform template, it will only mark the prospective changes. 

At the end of the result, it will summarize the actions to take, for example:
```
Plan: 3 to add, 4 to change, 3 to destroy.
```
If the plan fails, check the code and state file.

## Terraform Apply

If the plan looks good, we can apply the deployment plan:
```
terraform apply
```
Then, you need to say `yes` to the prompt. Terraform kicks off the deployment.  

During deployment, Terraform provider interacts with your AWS account to provision the resources. Some critical resources takes much longer than others due to sheer size. For example, the database alone takes 15 minutes. The EC2 instances also takes a few minutes because of the bootstrapping process that configures Orthanc application. The entire deployment process can take as long as 30 minutes. To fask track the progress, you parrallelize the deployment with flags such as `-parallelism=3`. 

## Review Output

Upon successful deployment, the screen should print out four entries. They are explained in the table below:

|key|example value|protocol|purpose|
|--|--|--|--|
|**server_dns**|ec2-15-156-192-145.ca-central-1.compute.amazonaws.com, ec2-99-79-73-88.ca-central-1.compute.amazonaws.com (HTTPS and DICOM TLS)|HTTPS/DICOM-TLS|Business traffic: HTTPS on port 443 and DICOM-TLS on port 11112. Reachable from the Internet.|
|**host_info**|Primary:i-02d92d2c1c046ea62    Secondary:i-076b93808575da71e|SSH|For management traffic. |
|**s3_bucket**|wealthy-lemur-orthbucket.s3.amazonaws.com|HTTPS-S3| For orthanc to store and fetch images. Access is restricted.|
|**db_endpoint**|wealthy-lemur-orthancpostgres.cqfpmkrutlau.us-east-1.rds.amazonaws.com:5432|TLS-POSTGRESQL| For orthanc to index data. Access is restricted.|

Once the screen prints the output, the EC2 instances may still take a couple extra minutes in the background to finish  configuring Orthanc. We can start validation as per the steps outlined in the next section. 

If applicable, deploy the custom application traffic management

## Terraform State
Terraform keeps a local file `terraform.tfstate` for the last known state of the deployed resources, known as the state file. This file is critical for the ongoing maintanance of the deployed resources.

Ad hoc changes to the resources created by Terraform are not registered in the state file. These changes, often referred to as configuration drift, are very likely to cause issues when the Terraform managed resources are updated or deleted. In general, manual changes to Terraform managed resources should be avoided. Changes should be first registered in the Terraform template and applied via the `terraform apply` command.

## Cost Estimate

Below is a per-day estimate of cost (in USD) of the infrastructure based on default configuration. 

| AWS Service   | Standing Cost |
| :---------------- | :------: |
| Relational Database |  $3.6   |
| EC2-Instances |  $2.2   |
| VPC |  $0.6   |
| Key Management Service |  $0.13   |
| EC2-Other |  $0.12   |
| Secrets Manager |  $0.12   |
| S3 |  $0.13   |
| <b>Total daily cost</b> |  <b>$7</b>   |

Note, the numbers does not include data processing charges such as images stored to and retrieved from S3, or data moved in and out of the Internet Gateway, etc. AWS has a comprehensive [pricing calculator](https://calculator.aws/#/) and [saving plans](https://aws.amazon.com/savingsplans/).

## Clean up
After the validation is completed, it is important to remember this step to stop incurring on-going cost.

You can delete all the resources with `destroy` command:
```
terraform destroy
```
The command should report that all resources are deleted.
