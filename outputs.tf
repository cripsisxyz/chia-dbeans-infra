output "location" {
  value       = var.location
  description = "GCloud Region or Zone"
}

output "project_id" {
  value       = var.project_id
  description = "GCloud Project ID"
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.dev_cluster.*.name
  description = "GKE Cluster Name"
}

output "kubernetes_cluster_host" {
  value       = google_container_cluster.dev_cluster.*.endpoint
  description = "GKE Cluster Host"
}
output "stable_channel_version" {
  value = data.google_container_engine_versions.west1b.release_channel_default_version["STABLE"]
}