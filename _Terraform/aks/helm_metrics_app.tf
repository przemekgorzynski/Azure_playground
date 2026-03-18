resource "helm_release" "prometheus_metrics_app" {
  name             = "prometheus-metrics-app"
  chart            = "../Helm/metrics_app"
  namespace        = "metrics"
  create_namespace = true

  values = [
    yamlencode({
      image = {
        repository = "quay.io/brancz/prometheus-example-app"
        tag        = "v0.5.0"
      }
      service = {
        port = 8080
      }
      metrics = {
        path     = "/metrics"
        interval = "30s"
      }
      servicemonitor = {
        enabled = false
      }
    })
  ]
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}
