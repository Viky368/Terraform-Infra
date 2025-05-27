resource "null_resource" "download_policy" {
  provisioner "local-exec" {
    command = "curl -s -o alb-ingress-policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
  }

  triggers = {
    always_run = timestamp()
  }
}

resource "aws_iam_policy" "alb_extended" {
  name   = "alb-ingress-extra"
  policy = file("${path.module}/alb-ingress-policy.json")
}




module "alb_ingress_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "alb-ingress-controller-irsa"

  oidc_providers = {
    main = {
      provider_arn = data.aws_iam_openid_connect_provider.oidc.arn
      namespace_service_accounts = [
        "kube-system:aws-load-balancer-controller"
      ]
    }
  }

  depends_on = [null_resource.download_policy,aws_eks_cluster.eks]
}


resource "aws_iam_role_policy_attachment" "alb_irsa_attachment" {
  role       = module.alb_ingress_irsa.iam_role_name
  policy_arn = aws_iam_policy.alb_extended.arn

  depends_on = [ module.alb_ingress_irsa, aws_iam_policy.alb_extended]
}


resource "kubernetes_service_account" "lb_controller_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.alb_ingress_irsa.iam_role_arn
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.eks.name
  }

  set {
    name  = "region"
    value = "us-east-1"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value =  kubernetes_service_account.lb_controller_sa.metadata[0].name
  }

  set {
    name  = "vpcId"
    value = aws_vpc.vpc.id
  }

    depends_on = [
        kubernetes_service_account.lb_controller_sa,
        aws_eks_cluster.eks
    ]
 
}