// file: variables.tf

variable "domain_name" {
  description = "the domain name"
}

variable "vpc_name" {
  description = "name of the VPC"
  default     = "cloud"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.10.0.0/16"
}

variable "internal_subnets" {
  type        = "list"
  description = "list of subnet CIDR blocks that are not publicly acceessibly"
  default     = ["10.11.160.0/20", "10.11.176.0/20", "10.11.192.0/20"]
}

variable "external_subnets" {
  type        = "list"
  description = "list of subnet CIDR blocks that are publicly acceessibly"
  default     = []
}

variable "availability_zones" {
  type        = "list"
  description = "a list of EC2 availability zones"
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}
