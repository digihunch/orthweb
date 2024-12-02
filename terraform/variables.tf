variable "pubkey_data" {
  description = "Public key content for the EC2 instance to authorize. If the key isn't stored in a local file."
  type        = string
  default     = null
  sensitive   = true
  nullable    = true
}
variable "pubkey_path" {
  type        = string
  description = "Path to file that stores the SSH public key for the EC2 instance to authorize."
  default     = "~/.ssh/id_rsa.pub"
  nullable    = true

  validation {
    condition     = var.pubkey_path == null || var.pubkey_path == "" || fileexists(var.pubkey_path)
    error_message = "If pubkey_path is specified, it must be a valid file path"
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
  })
  default = {
    vpc_cidr              = "172.17.0.0/16"
    scu_cidr              = "0.0.0.0/0"
    az_count              = 2
    public_subnet_pfxlen  = 24
    private_subnet_pfxlen = 22
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
variable "CommonTags" {
  description = "Tags to apply for every resource by default"
  type        = map(string)
  default = {
    Environment = "Dev"
    Owner       = "info@digihunch.com"
  }
}
variable "DeploymentOptions" {
  description = "Deployment Options for Orthac app configuration"
  type        = map(string)
  default = {
    InstanceType = "t3.medium" # EBS-optimized instance type
  }
}
