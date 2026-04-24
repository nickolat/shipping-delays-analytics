# DATA LAKE LAYER

# APIs
locals {
  lake_project_api = [
    "iam.googleapis.com",
    "bigquery.googleapis.com",
    "storage.googleapis.com",
    "stackdriver.googleapis.com"
  ]
}

# Enable APIs
resource "google_project_service" "lake_project_api" {
  for_each = toset(local.lake_project_api)
  project  = google_project.lake_project.project_id
  service  = each.key
}

# Create a Google Cloud Project for the Lake layer
resource "google_project" "lake_project" {
  name            = "Lake Layer"
  project_id      = "lake-layer"
  org_id          = var.organization.id
  billing_account = var.billing_account_id
}

# L0 (Cloud Storage)
resource "google_storage_bucket" "lake_l0_bucket" {
  name     = "lake-l0-bucket"
  location = var.location.region
  project  = google_project.lake_project.project_id
  uniform_bucket_level_access = true
}

# L1 (BigQuery)
resource "google_bigquery_dataset" "lake_l1_dataset" {
  dataset_id = "lake_l1_dataset"
  location   = var.location.region
  project    = google_project.lake_project.project_id

  access {
    role          = "OWNER"
    user_by_email = google_service_account.manipulation_service_account.email
  }
}

# L2 (BigQuery)
resource "google_bigquery_dataset" "lake_l2_dataset" {
  dataset_id = "lake_l2_dataset"
  location   = var.location.region
  project    = google_project.lake_project.project_id

  access {
    role          = "OWNER"
    user_by_email = google_service_account.manipulation_service_account.email
  }

  access {
    role          = "READER"
    user_by_email = google_service_account.consumption_service_account.email
  }
}

# IAM for L0 (read and write)
resource "google_storage_bucket_iam_binding" "lake_bucket_iam_binding_0" {
  bucket = google_storage_bucket.lake_l0_bucket.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.manipulation_service_account.email}",
  ]
}

