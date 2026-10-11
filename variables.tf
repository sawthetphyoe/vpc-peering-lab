variable "aws_region" {
  description = "AWS region for the VPC peering lab"
  type        = string
  default     = "ap-southeast-1"
}

variable "service_port" {
  description = "TCP port for fake-service"
  type        = number
  default     = 9090
}

variable "service_ami_id" {
  description = "Shared custom AMI containing fake-service and systemd"
  type        = string
}

variable "service_instance_type" {
  description = "EC2 instance type compatible with the x86_64 AMI"
  type        = string
  default     = "t3.micro"
}

variable "vpc_cidrs" {
  description = "Non-overlapping IPv4 CIDR blocks for the three VPCs"
  type = object({
    customer_profile = string
    account          = string
    statement        = string
  })
}

variable "subnet_cidrs" {
  description = "IPv4 CIDR block for each service subnet, within its VPC"
  type = object({
    customer_profile = string
    account          = string
    statement        = string
  })
}

variable "customer_profile_ingress_cidr" {
  description = "IPv4 CIDR allowed to call the public customer-profile service"
  type        = string
  default     = "0.0.0.0/0"
}
