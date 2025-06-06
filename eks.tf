resource "aws_eks_cluster" "eks" {
  name     = "${local.env}-eks"
  role_arn = aws_iam_role.master.arn
  version  = "1.28"

  vpc_config {
    subnet_ids = [aws_subnet.pub_sub1.id, aws_subnet.pub_sub2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
    aws_subnet.pub_sub1,
    aws_subnet.pub_sub2,
  ]
}


resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.eks.name}"
  }

  depends_on = [aws_eks_cluster.eks]
}
