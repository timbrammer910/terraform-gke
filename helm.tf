resource "helm_release" "kubeview" {

  name       = "kubeview"
  repository = "https://benc-uk.github.io/kubeview/charts"
  chart      = "kubeview"

  values = [
    file("${path.module}/kubeview-values.yaml")
  ]

}

resource "helm_release" "newrelic" {

  name = "newrelic-bundle"
  repository = "https://helm-charts.newrelic.com"
  chart = "nri-bundle"
  namespace = kubernetes_namespace.newrelic.metadata[0].name

  set {
    name  = "global.licenseKey"
    value = "efe224a34367f95a6fda79d198d83a557d68NRAL"
  }

  set {
    name  = "global.cluster"
    value = "gcp-cluster"
  }

  set {
    name  = "newrelic-infrastructure.privileged"
    value = "true"
  }

  set {
    name  = "ksm.enabled"
    value = "true"
  }

  set {
    name  = "prometheus.enabled"
    value = "true"
  }

  set {
    name  = "kubeEvents.enabled"
    value = "true"
  }

  set {
    name  = "logging.enabled"
    value = "true"
  }

  depends_on = [
    kubernetes_namespace.newrelic
  ]

}

resource "helm_release" "demo-app" {
  
  name       = "demo-app"
  chart      = "${path.module}/demo-app-chart"

  # values = [
  #   file("${path.module}/demo-app-values.yaml")
  # ]

  // Hack to trigger reinstall if chart
  // files are updated by passing in an
  // unused trigger value equal to the
  // null resources output id.
  set {
    name  = "trigger"
    value = tostring(null_resource.chart-update.id)
    type  = "string"
  }
}

resource "null_resource" "chart-update" {
  triggers = {
    chart = sha1(join("", [for f in fileset("${path.module}/demo-app-chart", "**"): filesha1("${path.module}/demo-app-chart/${f}")]))
  }
}