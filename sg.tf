resource "aws_security_group" "node" {
  name        = "${local.env}-eks-node-sg"
  description = "Allow NodePort traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "SSH access to public"
    from_port   = 22
    to_port    = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow NodePort access for NGINX"
    from_port   = 30000  # ✅ Change this to match your NodePort
    to_port     = 30000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Change to restrict access if needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${local.env}-eks-node-sg"
  }
}

# ✅ Additional Rule for Allowing All NodePorts (30000-32767)
resource "aws_security_group_rule" "allow_all_nodeports" {
  type              = "ingress"
  from_port         = 30000
  to_port           = 32767
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Adjust if needed for security
  security_group_id = aws_security_group.node.id
}

# ✅ Additional Rule for Future HTTP/S Traffic (Optional)
resource "aws_security_group_rule" "allow_http_https" {
  type              = "ingress"
  from_port         = 80
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]  # Adjust to allow only trusted IPs
  security_group_id = aws_security_group.node.id
}
