The solution was tested on Mac and Linux. The instructions are based on Mac or Linux. Use the solution on Windows at your own risk. There are also several ways to adjust the steps to work with managed Terraform environment (e.g. Terraform Cloud). For simplicity, this documentation assumes that you work from a command terminal.

## Prerequisite

In your command terminal, install the required packages:

* Make sure **[awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)** is installed and [configured](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure) so you can connect to your AWS account with as your IAM user (using `Access Key ID` and `Secret Access Key` with administrator privilege). If you will need to SSH to the EC2 instance, you also need to install [session manager plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html);
* Make sure **Terraform CLI** is [installed](https://learn.hashicorp.com/tutorials/terraform/install-cli). In the Orthweb template, Terraform also uses your IAM credential to [authenticate into AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#shared-credentials-file). 

Then, use Git to pull the repostory:
```sh
git clone https://github.com/digihunch/orthweb.git
```
Before running terraform command, enter the `orthweb` directory as current working directory.


## Additional Steps

Take the preparatory steps below if you need to inspect or troubleshoot the Orthanc deployment. Otherwise, skip to the next section to start Installation.

### Secure SSH access
There are two ways to SSH to the EC2 instances. To use your own choice of command terminal, you must configure your [RSA key pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) on the EC2 instances. Alternatively, without your own RSA key pair, you may use web-based command terminal provided by Session Manager in AWS console.

### Use your own command terminal

You need to [create your RSA key pair](https://help.dreamhost.com/hc/en-us/articles/115001736671-Creating-a-new-Key-pair-in-Mac-OS-X-or-Linux). Your public key will be stored as file `~/.ssh/id_rsa.pub` on MacOS or Linux by default. Here is how the template determines what to send to EC2 as authorized public key:

1. If you specify public key data in the input variable `pubkey_data`, then it will added as authorized public key when the EC2 instances are created.
2. If `pubkey_data` is not specified, then it looks for the file path specified in input variable `pubkey_path` for public key
3. If `pubkey_path` is not specified, then it uses default public key path `~/.ssh/id_rsa.pub` and pass the public key
4. If no file is found at the default public key path, then the template will not send a public key. The EC2 instances to be provisioned will not have an authorized public key. Your only option to SSH to the instance is using AWS web console.

Terraform template picks up environment variable prefixed with `TF_VAR_` and pass them in as Terraform's [input variable](https://developer.hashicorp.com/terraform/language/values/variables#environment-variables) without the prefix in the name. For example, if you set environment as below before running `terraform init`, then Terraform will pick up the value for input variables `pubkey_data` and `pubkey_path`:
```sh
export
TF_VAR_pubkey_data="mockpublickeydatawhichissuperlongdonotputyourprivatekeyherepleaseabcxyzpubkklsss"
TF_VAR_pubkey_path="/tmp/mykey.pub"
```

Your SSH client works in tandem with session-manager-plugin. You can add the following section to your local SSH configuration file (i.e. `~/.ssh/config`) so it allows the session manager proxies the SSH session for hostnames matching `i-*` and `mi-*`.

```
host i-* mi-*
    ProxyCommand sh -c "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters 'portNumber=%p'"
    IdentityFile ~/.ssh/id_rsa
    User ec2-user
```
Then you will be able to directly ssh to an instance by its instance ID, even if the instance does not have a public IP. It will use Linux user `ec2-user`, whose public key has been pre-loaded authorized public key.

### Use web-based terminal

Orthweb automaically configures the permission required for EC2 instances to connect to AWS system manager.

Log on to AWS console, from `AWS System Manager` in your region, on the left-hand pannel, under `Node Management`, select `Fleet Manager`. You should see your instances listed. Select the Node by the name, select `Node actions` and then `Start terminal session` (under `Connect`). It will take you to a web-based command console and logged in as `ssm-user`. You can switch to our `ec2-user` with sudo commands:
```bash
sh-4.2$ sudo -s
[root@ip-172-27-3-138 bin]# su - ec2-user
Last login: Wed Nov 23 22:02:57 UTC 2022 from localhost on pts/0
[ec2-user@ip-172-27-3-138 ~]$
```

Both mechanisms are enabled by default in the Terraform template.

## Custom deployment options
This project comes with working default but you can customize it in certain ways, by modifying the variable file `terraform.tfvars`. The variables are self-explanatory and defined in `variables.tf` file. 

|variable|description|
|--|--|
|**network_config**| Adjust the networking configuration (e.g. CIDRs, sizing) and specify interface endpoints to enable if required.|
|**provider_tags**| Adjust the resource tags to apply to every resources deployed through the Terraform template |
|**deployment_options**| Adjust the deployment specification. For example, use a different instance size, configuration repo, and have your own site name|

If you use BYO DNS name, make sure to set the **SiteName** correctly. The value of site name, if set, is used in several configuration files for Orthanc. If it is set incorrectly, you will not be able to browse the orthanc Site correctly. 
