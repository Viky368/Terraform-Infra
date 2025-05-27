# resource "kubernetes_namespace" "logging" {
#   metadata {
#     name = "logging"
#   }
# }


# resource "helm_release" "elasticsearch" {
#   name       = "elasticsearch"
#   namespace  = kubernetes_namespace.logging.metadata[0].name
#   repository = "https://helm.elastic.co"
#   chart      = "elasticsearch"
#   version    = "7.17.3"

#   set {
#     name  = "replicas"
#     value = "1"
#   }

#   set {
#     name  = "volumeClaimTemplate.storageClassName"
#     value = "gp2" # Or your default
#   }

#   set {
#     name  = "volumeClaimTemplate.resources.requests.storage"
#     value = "30Gi"
#   }
# }


# resource "helm_release" "kibana" {
#   name       = "kibana"
#   namespace  = kubernetes_namespace.logging.metadata[0].name
#   repository = "https://helm.elastic.co"
#   chart      = "kibana"
#   version    = "7.17.3"

#   set {
#     name  = "service.type"
#     value = "LoadBalancer"
#   }

#   set {
#     name  = "elasticsearchHosts"
#     value = "http://elasticsearch-master.logging.svc.cluster.local:9200"
#   }

#   set {
#   name  = "readinessProbe.initialDelaySeconds"
#   value = "60"
# }

# set {
#   name  = "readinessProbe.failureThreshold"
#   value = "10"
# }

#   depends_on = [helm_release.elasticsearch]
# }


# resource "helm_release" "fluent_bit" {
#   name       = "fluent-bit"
#   namespace  = kubernetes_namespace.logging.metadata[0].name
#   repository = "https://fluent.github.io/helm-charts"
#   chart      = "fluent-bit"
#   version    = "0.20.0"

#   set {
#     name  = "backend.type"
#     value = "es"
#   }

#   set {
#     name  = "backend.es.host"
#     value = "elasticsearch-master.logging.svc.cluster.local"
#   }

#   set {
#     name  = "backend.es.port"
#     value = "9200"
#   }

#   set {
#     name  = "backend.es.tls"
#     value = "false"
#   }

#   depends_on = [helm_release.elasticsearch]
# }
