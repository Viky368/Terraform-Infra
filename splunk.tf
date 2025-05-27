resource "helm_release" "splunk_operator" {
  name             = "splunk-operator"
  namespace        = "splunk"
  create_namespace = true

  repository = "https://splunk.github.io/splunk-operator"
  chart      = "splunk-operator"
  version    = "2.8.0" # Change if newer available

  values = []
}