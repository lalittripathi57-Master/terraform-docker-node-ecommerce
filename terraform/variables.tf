variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "dockerhub_username" {
  description = "Docker Hub username containing the five public images"
  type        = string
}

variable "ssh_public_key" {
  description = "Optional SSH public key content. Leave empty to skip SSH key creation."
  type        = string
  default     = ""
}

variable "admin_cidr" {
  description = "CIDR allowed to SSH. Set to your public IP/32."
  type        = string
  default     = "0.0.0.0/0"
}
