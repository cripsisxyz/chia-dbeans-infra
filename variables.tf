variable "project_id" {
  type = string
}

variable "location" {
  description = "GCP region or zone"
  type        = string
}

variable "gke_cluster_name" {
  type = string
  default = "dev-cluster"
}
