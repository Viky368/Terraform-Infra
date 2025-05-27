# locals{
# subnet_ids = [aws_subnet.pub_sub1.id, aws_subnet.pub_sub2.id, aws_subnet.priv_sub1.id, aws_subnet.priv_sub2.id]
# depends_on = [ aws_eks_cluster.eks ]
# }



# resource "aws_security_group" "efs" {
#   name        = "efs-sg"
#   description = "Security group for EFS file system"
#   vpc_id      = aws_vpc.vpc.id  # Adjust to your VPC resource

#   # Egress rule: allow all outbound traffic
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "efs-sg"
#   }
# }

# # Create a security group rule to allow inbound NFS (TCP 2049) traffic from the same security group
# resource "aws_security_group_rule" "efs_inbound_nfs" {
#   type                     = "ingress"
#   from_port                = 2049
#   to_port                  = 2049
#   protocol                 = "tcp"
#   security_group_id        = aws_security_group.efs.id
#   source_security_group_id = aws_security_group.node.id  # Allows traffic from any instance in this SG
#   description              = "Allow NFS traffic (TCP 2049) from within the same security group"

#     depends_on = [ aws_security_group.node ]
# }


# resource "aws_efs_file_system" "efs" {
#   creation_token   = "dify"
#   performance_mode = "generalPurpose"
#   encrypted        = true
# }

# resource "aws_efs_mount_target" "mount_targets" {
#   for_each      = toset(local.subnet_ids)
#   file_system_id = aws_efs_file_system.efs.id
#   subnet_id      = each.value
#   security_groups = [
#     aws_security_group.efs.id
#   ]
# }
