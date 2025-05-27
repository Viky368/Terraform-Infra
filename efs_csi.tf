#####################################
# IAM Role for EFS CSI Driver via IRSA
#####################################
module "efs_csi_eks_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name = "efs_csi"

  # Configure the role to be assumed by the EFS CSI driver's service account in the kube-system namespace.
  oidc_providers = {
    main = {
      provider_arn               = data.aws_iam_openid_connect_provider.oidc.arn
      namespace_service_accounts = ["kube-system:efs-csi-controller-sa"]
    }
  }

}

resource "aws_iam_role_policy_attachment" "efs_csi_policy_attachment" {
  role       = module.efs_csi_eks_role.iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

###################################
# Deploy AWS EFS CSI Driver via Helm
###################################
resource "helm_release" "efs_csi_driver" {
  name        = "aws-efs-csi-driver"
  namespace   = "kube-system"
  repository  = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart       = "aws-efs-csi-driver"
  version     = "2.5.0"   # Update to the desired chart version
  force_update = true

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    type  = "string"
    value = module.efs_csi_eks_role.iam_role_arn
  }

 depends_on = [module.efs_csi_eks_role]
}

###################################
# Create a StorageClass using EFS CSI Driver
###################################
resource "kubernetes_storage_class_v1" "storageclass_efs" {
  depends_on = [helm_release.efs_csi_driver, module.efs_csi_eks_role, module.efs]
  metadata {
    name = "efs-sc"
    annotations = {
      # Optionally, you can make this the default StorageClass by setting the value to "true"
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }

  storage_provisioner    = "efs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"

  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId     = module.efs.id
    uid=    "1000" 
    gid=    "1000"
    directoryPerms   =  "750"  # Replace with your actual EFS file system ID if necessary
  }
}
 

