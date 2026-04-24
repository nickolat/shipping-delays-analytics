# CONSUMPTION LAYER

# APIs
locals {
  consumption_project_api = [
    "iam.googleapis.com",
    "stackdriver.googleapis.com",
    "containers.googleapis.com",
    "compute.googleapis.com",
  ]
}

# Enable APIs
resource "google_project_service" "consumption_project_api" {
  for_each = toset(local.consumption_project_api)
  project  = google_project.consumption_project.project_id
  service  = each.key
}

# Create a Google Cloud Project for the Consumption layer
resource "google_project" "consumption_project" {
  name            = "Consumption Layer"
  project_id      = "consumption-layer"
  org_id          = var.organization.id
  billing_account = var.billing_account_id
}

# GKE cluster
resource "google_container_cluster" "consumption_gke_cluster" {
  name     = "consumption-gke-cluster"
  location = var.location.region
  project  = google_project.consumption_project.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

# GKE node pool
resource "google_container_node_pool" "consumption_gke_node_pool" {
  name       = "consumption-gke-node-pool"
  location   = var.location.region
  cluster    = google_container_cluster.consumption_gke_cluster.name
  node_count = 3
  project    = google_project.consumption_project.project_id

  node_config {
    machine_type = "n2-standard-2"

    service_account = google_service_account.consumption_service_account.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Consumption Service Account
resource "google_service_account" "consumption_service_account" {
  account_id = "consumption-service-account"
  project    = google_project.consumption_project.project_id
}