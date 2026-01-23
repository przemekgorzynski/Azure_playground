resource "helm_release" "log_app" {
  name             = "log-app"
  chart            = "../helm/logging_app"
  namespace        = "logs"
  create_namespace = true

  values = [
    yamlencode({
      image = {
        repository = "python"
        tag        = "3.12-slim"
      }

      service = {
        port = 8080
      }

      logMessage  = "Hello from logginapp!"
      logInterval = 5

      metrics = {
        path     = "/metrics"
        interval = "15s"
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
