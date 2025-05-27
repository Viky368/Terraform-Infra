locals {
  mounttargets={
    for idx, subnet_id in var.subnetids: "mount-${idx}"=>{
        subnet_id=subnet_id
    }
  }
}

data "aws_subnet" "efs_subnets"{
    for_each= toset(var.subnetids)
    id= each.value
}

module "efs" {
  source = "terraform-aws-modules/efs/aws"

  # File system
  name           = "efs-test"
  creation_token = "efs-test-token"

  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }


  # Mount targets / security group
  mount_targets = local.mounttargets

  security_group_description = "Example EFS security group"
  security_group_vpc_id      = aws_vpc.vpc.id
  security_group_rules = {
    vpc = {
      # relying on the defaults provdied for EFS/NFS (2049/TCP + ingress)
      description = "NFS ingress from VPC private subnets"
      cidr_blocks = [for subnets in data.aws_subnet.efs_subnets: subnets.cidr_block]
    }
  }

  # Access point(s)


  # Backup policy
  enable_backup_policy = true


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}