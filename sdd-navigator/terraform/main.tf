provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "sdd_navigator" {
  metadata {
    name = "sdd-navigator"
    labels = {
      name = "sdd-navigator"
    }
  }
}

resource "helm_release" "sdd_navigator" {
  name       = "sdd-navigator"
  namespace  = kubernetes_namespace.sdd_navigator.metadata[0].name
  chart      = "../helm/sdd-navigator"
  
  set {
    name  = "api.replicaCount"
    value = var.environment == "prod" ? "3" : "1"
  }
  
  set {
    name  = "postgresql.primary.persistence.size"
    value = var.environment == "prod" ? "50Gi" : "10Gi"
  }
  
  values = [
    file("../helm/sdd-navigator/values-${var.environment}.yaml")
  ]
}

variable "environment" {
  description = "Environment (dev/staging/prod)"
  default     = "dev"
}