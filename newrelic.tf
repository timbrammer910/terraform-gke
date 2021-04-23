# data "newrelic_entity" "cluster" {
#   name = "gcp-cluster"
# }

resource "newrelic_one_dashboard" "gke-cluster" {
  name = "GKE Cluster"

  page {
    name = "GKE Cluster"

    widget_billboard {
      title  = "Kubernetes Deployments"
      row    = 1
      column = 1

      nrql_query {
        query = "SELECT uniqueCount(deploymentName) AS Deployments FROM K8sDeploymentSample WHERE clusterName = 'gcp-cluster'"
      }
    }

    widget_bullet {
      title  = "Current Memory Usage"
      row    = 1
      column = 5

      nrql_query {
        query = "SELECT uniqueCount(entityId) * average(memoryWorkingSetBytes) as 'Memory usage' FROM K8sNodeSample WHERE clusterName = 'gcp-cluster'"
      }
      limit = "16532021253.756851"
    }

    widget_bar {
      title  = "Memory Usage Stats"
      row    = 1
      column = 10

      nrql_query {
        query = "FROM K8sNodeSample SELECT average(allocatableMemoryUtilization) AS 'Memory %' WHERE clusterName = 'gcp-cluster' TIMESERIES"
      }
    }
  }
}