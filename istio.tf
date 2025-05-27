# # Create the namespace for Istio and its addons.
# resource "kubernetes_namespace" "istio" {
#   metadata {
#     name = "istio-system"
#   }
# }

# # Define the Istio chart repository.
# locals {
#   istio_repo = "https://istio-release.storage.googleapis.com/charts"
# }

# # Install the Istio base chart (CRDs and common resources).
# resource "helm_release" "istio_base" {
#   name       = "istio-base"
#   repository = local.istio_repo
#   chart      = "base"
#   namespace  = kubernetes_namespace.istio.metadata[0].name
#   version    = ">=1.12.0"    # adjust version as needed
#   timeout          = 120
#   cleanup_on_fail  = true
#   force_update     = false
# }

# # Install the Istio control plane (istiod) with a value override.
# resource "helm_release" "istiod" {
#   name       = "istiod"
#   repository = local.istio_repo
#   chart      = "istiod"
#   namespace  = kubernetes_namespace.istio.metadata[0].name
#   version    = ">=1.12.0"
#   timeout          = 120
#   cleanup_on_fail  = true
#   force_update     = false

#   set {
#     name  = "meshConfig.accessLogFile"
#     value = "/dev/stdout"
#   }

#   depends_on = [helm_release.istio_base]
# }

# # Optionally, install the Istio ingress gateway.
# resource "helm_release" "istio_ingress" {
#   name       = "istio-ingress"
#   repository = local.istio_repo
#   chart      = "gateway"
#   namespace  = kubernetes_namespace.istio.metadata[0].name
#   version    = ">=1.22.0"
#   timeout          = 500
#   cleanup_on_fail  = true
#   force_update     = false

#   depends_on = [helm_release.istiod]
# }

# # Install Kiali using its official Helm chart.
# # First, note that Kiali’s chart repository is different.
# resource "helm_release" "kiali" {
#   name       = "kiali-server"
#   repository = "https://kiali.org/helm-charts"
#   chart      = "kiali-server"
#   namespace  = kubernetes_namespace.istio.metadata[0].name
#   version    = "1.89.0"  # adjust version as needed
#   timeout          = 120
#   cleanup_on_fail  = true
#   force_update     = false

#   # For demonstration, this configuration sets anonymous authentication.
#   set {
#     name  = "auth.strategy"
#     value = "anonymous"
#   }

#   # Optionally, you can override additional values as needed.
#   # For example, if you want to expose Kiali via a LoadBalancer,
#   # you might add:
#   #
#   set {
#     name  = "service.type"
#     value = "LoadBalancer"
#   }

#   depends_on = [helm_release.istiod]
# }


# # Apply the Istio Prometheus add-on manifest.
# resource "null_resource" "prometheus_addon" {
#   provisioner "local-exec" {
#     command = "kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.12/samples/addons/prometheus.yaml"
#   }
#   depends_on = [helm_release.istiod]
# }