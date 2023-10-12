provider "google" {
  project = var.project_id
  region  = var.location
}

# Set GKE version_prefix
data "google_container_engine_versions" "west1b" {
  provider       = google-beta
  location       = var.location
  project        = var.project_id
  version_prefix = "1.27.3-gke.100"
}

# GKE cluster
resource "google_container_cluster" "dev_cluster" {
  name     = "${var.gke_cluster_name}"
  location = var.location
  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  
  # Use google_container_engine_versions for set min_master_version
  min_master_version = data.google_container_engine_versions.west1b.latest_master_version
 
  # Create an VPC-native cluster and let GKE choose the IP ranges.
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = ""
    services_ipv4_cidr_block = ""

  }

  monitoring_config {
    managed_prometheus {
      enabled = false
    }
  }
}

# Separately Managed Node Pool
resource "google_container_node_pool" "dev_cluster_nodes" {
  name       = "${google_container_cluster.dev_cluster.name}-node-pool"
  location   = var.location
  cluster    = google_container_cluster.dev_cluster.name
  node_count = 2
  node_config {
    preemptible  = true
    machine_type = "e2-standard-4"
    tags         = ["gke-node", "${google_container_cluster.dev_cluster.name}"]

    oauth_scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }

  management {
    auto_repair  = false
    auto_upgrade = true
  }

}

data "google_client_config" "provider" {}

resource "local_file" "token" {
    content  = data.google_client_config.provider.access_token
    filename = "token-${var.gke_cluster_name}"
}

resource "local_file" "ca_cert" {
    content  = base64decode(
      google_container_cluster.dev_cluster.master_auth[0].cluster_ca_certificate
    )
    filename = "ca-${var.gke_cluster_name}.pem"
}

resource "local_file" "endpoint" {
    content = google_container_cluster.dev_cluster.endpoint
    filename = "endpoint-${var.gke_cluster_name}"
}
