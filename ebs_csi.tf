data "tls_certificate" "oidc" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  depends_on = [ aws_eks_cluster.eks ]
}

# Create IAM OIDC provider
resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  tags = {
    Name        = "${aws_eks_cluster.eks.name}-oidc"
    Environment = "dev"
  }
}


 module "ebs_csi_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "ebs-csi-driver"

  oidc_providers = {
    main = {
      provider_arn               = aws_iam_openid_connect_provider.eks_oidc.arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  depends_on = [ aws_eks_cluster.eks ]

}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_attach" {
  role       = module.ebs_csi_eks_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

####################################
# Enable AWS EBS CSI Driver Add-on
####################################
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = module.ebs_csi_eks_role.iam_role_arn

  depends_on = [ aws_eks_cluster.eks ]
}

# ###################################
# # Deploy AWS EBS CSI Driver via Helm
# ###################################
# resource "helm_release" "ebs_csi_driver" {  
#   name       = "aws-ebs-csi-driver"
#   namespace  = "kube-system"
#   repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
#   chart      = "aws-ebs-csi-driver"
#   force_update = true

#   set {
#     name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     type  = "string"
#     value = module.ebs_csi_eks_role.iam_role_arn
#   }
# }

###################################
# Create a StorageClass using gp2
###################################
resource "kubernetes_storage_class_v1" "storageclass_gp2" {
  
  metadata {
    name = "gp2-encrypted"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "Immediate"

  parameters = {
    type      = "gp2"
    encrypted = "true"
  }
  depends_on = [ null_resource.update_kubeconfig, module.ebs_csi_eks_role  ]
}

