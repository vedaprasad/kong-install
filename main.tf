resource "argocd_application" "helm" {
  metadata {
    name      = "kong"
    namespace = "argocd"
  }

  spec {
    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "kong"
    }

    source {
      repo_url        = "https://charts.konghq.com"
      chart           = "kong"
      target_revision = "2.37.0"
      helm {
        release_name = "my-kong"
        values = templatefile("${path.module}/kong-values.yaml",{
          repo = "kong"
        })
      }
    }
      sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      # Only available from ArgoCD 1.5.0 onwards
      sync_options = ["Validate=false"]
      retry {
        limit = "5"
        backoff {
          duration     = "30s"
          max_duration = "2m"
          factor       = "2"
        }
      }
    }
  }
}