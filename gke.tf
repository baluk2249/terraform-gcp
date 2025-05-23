
variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}
variable "gke_num_nodes" {
  default     = 2
  description = "number of gke nodes"
}
data "google_container_engine_versions" "gke_version" {
  location = "us-central1"
  version_prefix = "1.30."
}

resource "google_container_cluster" "primary" {
  name     = "demo-gke"
  location = "us-central1"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

resource "google_container_node_pool" "primary_nodes" {
  name       = google_container_cluster.primary.name
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  
  version = data.google_container_engine_versions.gke_version.release_channel_default_version["STABLE"]
  node_count = var.gke_num_nodes

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = "red-parity-454414-e0"
    }

    # preemptible  = true
    machine_type = "n1-standard-1"
    tags         = ["gke-node", "demo-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}


