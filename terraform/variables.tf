variable "ec2_config" {
  description = "Configuration Options for EC2 instances"
  type        = map(string)
  default = {
    InstanceType  = "t3.medium" # must be an EBS-optimized instance type with amd64 CPU architecture.
    PublicKeyData = null
    PublicKeyPath = "~/.ssh/id_rsa.pub"
  }
  validation {
    condition     = (var.ec2_config.PublicKeyData != null && var.ec2_config.PublicKeyData != "") || (var.ec2_config.PublicKeyPath != null && var.ec2_config.PublicKeyPath != "")
    error_message = "Must specify one of ec2_config.PublicKeyData and ec2_config.PublicKeyPath."
  }
  validation {
    condition = (
      var.ec2_config.PublicKeyPath == null || var.ec2_config.PublicKeyPath == "" || (fileexists(var.ec2_config.PublicKeyPath) &&
      can(regex("^(ssh-rsa|ssh-ed25519) [A-Za-z0-9+/=]+( [^ ]+)?$", file(var.ec2_config.PublicKeyPath))))
    )
    error_message = "If provided, the file must exist and contain a valid RSA (ssh-rsa) or ED25519 (ssh-ed25519) public key in OpenSSH format."
  }
  #validation {
  #  condition     = var.ec2_config.PublicKeyPath == null || var.ec2_config.PublicKeyPath == "" || fileexists(var.ec2_config.PublicKeyPath)
  #  error_message = "If ec2_config.PublicKeyPath is specified, it must be a valid file path"
  #}
  validation {
    condition = (
      var.ec2_config.PublicKeyData == null || var.ec2_config.PublicKeyData == "" || can(regex("^(ssh-rsa|ssh-ed25519) [A-Za-z0-9+/=]+( [^ ]+)?$", var.ec2_config.PublicKeyData))
    )
    error_message = "If provided, var.ec2_config.PublicKeyData must be in a valid OpenSSH format (starting with 'ssh-rsa' or 'ssh-ed25519')."
  }
}

variable "network_config" {
  description = "Networking Configuration"
  type = object({
    vpc_cidr              = string
    scu_cidr              = string
    az_count              = number
    public_subnet_pfxlen  = number
    private_subnet_pfxlen = number
    interface_endpoints   = list(string)
  })
  default = {
    vpc_cidr              = "172.17.0.0/16"
    scu_cidr              = "0.0.0.0/0"
    az_count              = 2
    public_subnet_pfxlen  = 24
    private_subnet_pfxlen = 22
    interface_endpoints   = []
    # For all management traffic on private route: ["kms","secretsmanager","ec2","ssm","ec2messages","ssmmessages"]
    # For secrets and keys on private route: ["kms","secretsmanager"]
    # For all management traffic via Internet (lowest cost): []
    # View available options: https://docs.aws.amazon.com/vpc/latest/privatelink/aws-services-privatelink-support.html#vpce-view-available-services
  }
  validation {
    condition     = can(cidrhost(var.network_config.vpc_cidr, 32))
    error_message = "Input variable network_config.vpc_cidr must be a valid IPv4 CIDR."
  }
  validation {
    condition     = can(cidrhost(var.network_config.scu_cidr, 0))
    error_message = "Input variable network_config.scu_cidr must be a valid IPv4 CIDR."
  }
  validation {
    condition     = var.network_config.az_count >= 1 && var.network_config.az_count <= 3
    error_message = "Input variable network_config.az_count must be a numeric value between 1, 2 or 3"
  }
}
variable "provider_tags" {
  description = "Tags to apply for every resource by default"
  type        = map(string)
  default = {
    environment = "dev"
    owner       = "info@digihunch.com"
  }
  validation {
    condition     = contains(["prd", "dev", "tst", "stg"], var.provider_tags.environment)
    error_message = "The environment code must be one of: prd, dev, tst, or stg"
  }
}
variable "deployment_options" {
  description = "Deployment Options for Orthac app configuration"
  type        = map(string)
  default = {
    ConfigRepo  = "https://github.com/digihunchinc/orthanc-config.git" # configuration repo to clone.
    SiteName    = null
    InitCommand = "pwd && echo Custom Init Command Here"
  }
}
