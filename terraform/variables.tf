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
      var.ec2_config.PublicKeyPath == null || var.ec2_config.PublicKeyPath == "" ||
      can(regex("^(ssh-rsa|ssh-ed25519) [A-Za-z0-9+/=]+( [^ ]+)?$", file(var.ec2_config.PublicKeyPath)))
    )
    error_message = "If provided, the file must exist and contain a valid RSA (ssh-rsa) or ED25519 (ssh-ed25519) public key in OpenSSH format."
  }
  validation {
    condition = (
      var.ec2_config.PublicKeyData == null || var.ec2_config.PublicKeyData == "" || can(regex("^(ssh-rsa|ssh-ed25519) [A-Za-z0-9+/=]+( [^ ]+)?$", var.ec2_config.PublicKeyData))
    )
    error_message = "If provided, var.ec2_config.PublicKeyData must be in a valid OpenSSH format (starting with 'ssh-rsa' or 'ssh-ed25519')."
  }
}

variable "network_config" {
  description = "Networking Configuration\n vpn_client_cidr: set to a non-conflicting CIDR of at least /22 to configure client VPN. Otherwise leave blank or null to not configure client VPN."
  type = object({
    vpc_cidr              = string
    dcm_cli_cidrs         = list(string)
    web_cli_cidrs         = list(string)
    az_count              = number
    public_subnet_pfxlen  = number
    private_subnet_pfxlen = number
    interface_endpoints   = list(string)
    vpn_client_cidr       = string
    vpn_cert_cn_suffix    = string
    vpn_cert_valid_days   = number
  })
  default = {
    vpc_cidr              = "172.17.0.0/16"
    dcm_cli_cidrs         = ["0.0.0.0/0"]
    web_cli_cidrs         = ["0.0.0.0/0"]
    az_count              = 2
    public_subnet_pfxlen  = 24
    private_subnet_pfxlen = 22
    interface_endpoints   = []
    vpn_client_cidr       = ""
    vpn_cert_cn_suffix    = "vpn.digihunch.com"
    vpn_cert_valid_days   = 3650
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
    condition = alltrue([
      for cidr in var.network_config.web_cli_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Input variable network_config.web_cli_cidrs must be a list of valid IPv4 CIDRs."
  }
  validation {
    condition = alltrue([
      for cidr in var.network_config.dcm_cli_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "Input variable network_config.dcm_cli_cidrs must be a list of valid IPv4 CIDRs."
  }
  validation {
    condition     = var.network_config.az_count >= 1 && var.network_config.az_count <= 3
    error_message = "Input variable network_config.az_count must be a numeric value between 1, 2 or 3"
  }
  validation {
    condition     = var.network_config.vpn_client_cidr == null || var.network_config.vpn_client_cidr == "" || can(cidrhost(var.network_config.vpn_client_cidr, 32))
    error_message = "Input variable network_config.vpn_client_cidr must be either empty or a valid IPv4 CIDR with at least /22 range."
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
  type = object({
    ConfigRepo     = string
    SiteName       = string
    InitCommand    = string
    EnableCWLog    = bool
    CWLogRetention = number
  })
  default = {
    ConfigRepo     = "https://github.com/digihunchinc/orthanc-config.git" # configuration repo to clone.
    SiteName       = null
    InitCommand    = "pwd && echo Custom Init Command (e.g. make aws)" # Command to run from config directory.
    EnableCWLog    = true
    CWLogRetention = 3 # CloudWatch Log group Retention days -1 to disable
  }
  validation {
    condition     = contains([0, 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653], var.deployment_options.CWLogRetention)
    error_message = "The value of deployment_options.CWLogRetention must be one of the following integers: -1,0,1,3,5,7,14,30,60,90,120,150,180,365,400,545,731,1096."
  }
}
