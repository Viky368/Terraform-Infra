locals {
  env="dev"
}


variable "subnetids" {
  description = "List of subnet IDs for EFS mount targets"
  type        = list(string)
  default     = [
    "subnet-05bb9c5953b444440",
    "subnet-0f1e2081eb1b9dff8"
  ]
}

variable "region" {
  description = "AWS region where the EKS cluster is deployed"
  type        = string
  default     = "us-east-1"
}