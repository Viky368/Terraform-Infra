
# resource "null_resource" "helm_repo_init" {
#   provisioner "local-exec" {
#     command = <<EOT
#       helm repo add bitnami https://charts.bitnami.com/bitnami
#       helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
#       helm repo update
#     EOT
#   }
# }

# resource "helm_release" "postgresql" {
#   name       = "db"
#   namespace  = "default"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "postgresql"
#   version    = "12.5.6"

#   set {
#     name  = "auth.postgresPassword"
#     value = "mysecretpassword"
    
#   }

#   set {
#     name  = "architecture"
#     value = "replication"
#   }

#   set {
#     name  = "readReplicas.replicaCount"
#     value = "2"
#   }

#   set {
#     name  = "primary.persistence.enabled"
#     value = "true"
#   }

#   set {
#     name  = "primary.persistence.size"
#     value = "8Gi"
#   }

#   set {
#     name  = "primary.resources.requests.memory"
#     value = "512Mi"
#   }

#   set {
#     name  = "primary.resources.requests.cpu"
#     value = "250m"
#   }
# }