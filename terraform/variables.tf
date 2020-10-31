variable "depkey" {
  type = string
  default = "yi_cs"
}
variable "depregion" {
  type = string
  default = "us-east-1"
}

variable "amilut" {
  type = map
  default = {
    "us-east-1" = "ami-0fc61db8544a617ed"
    "us-west-1" = "ami-09a7fe78668f1e2c0"
    "ap-southeast-2" = "ami-08fdde86b93accf1c"
  }
}
