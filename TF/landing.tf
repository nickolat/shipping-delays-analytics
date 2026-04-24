# LANDING LAYER

# Required APIs
locals {
  landing_project_api = [
    "iam.googleapis.com",
    "pubsub.googleapis.com",
    "storage.googleapis.com",
    "stackdriver.googleapis.com"
  ]
}

# Enable APIs
resource "google_project_service" "landing_project_api" {
  for_each = toset(local.landing_project_api)
  project  = google_project.landing_project.project_id
  service  = each.key
}

# Create a Google Cloud Project for the landing layer
resource "google_project" "landing_project" {
  name            = "Landing Layer"
  project_id      = "landing-layer"
  org_id          = var.organization.id
  billing_account = var.billing_account_id
}

### Components

# Create a Storage Bucket
resource "google_storage_bucket" "landing_bucket" {
  name     = "shipment-landing-bucket"
  location = var.location.region
  project  = google_project.landing_project.project_id
  uniform_bucket_level_access = true
}


# Note: starting from version 4.78.0 Terraform supports ingestion of data
# from a topic to a Google Cloud Storage bucket

# Create a Pub/Sub Topic for receiving shipment data
resource "google_pubsub_topic" "shipment_topic" {
  name    = "shipment-topic"
  project = google_project.landing_project.project_id
}

# Pub/Sub subscription for Cloud Storage
resource "google_pubsub_subscription" "shipment_subscription" {
  name = "shipment-subscription"
  topic = google_pubsub_topic.shipment_topic.name
  project = google_project.landing_project.project_id

  cloud_storage_config {
    bucket = google_storage_bucket.landing_bucket.name
    max_duration = "300s"
  }

}

## Service Account and IAM

# Create a service account for Pub/Sub to Cloud Storage operations
resource "google_service_account" "pubsub_to_gcs_sa" {
  account_id   = "pubsub-to-gcs-sa"
  display_name = "Pub/Sub to Cloud Storage Service Account"
  project      = google_project.landing_project.project_id
}

# Grant the service account permission to write to the Cloud Storage bucket
resource "google_storage_bucket_iam_member" "pubsub_gcs_writer" {
  bucket = google_storage_bucket.landing_bucket.name
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_service_account.pubsub_to_gcs_sa.email}"
}

# Grant the service account permission to publish to the Pub/Sub topic
resource "google_pubsub_topic_iam_member" "pubsub_publisher" {
  project = google_project.landing_project.project_id
  topic   = google_pubsub_topic.shipment_topic.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.pubsub_to_gcs_sa.email}"
}

# Grant the data manipulation service account permission to read from the Cloud Storage bucket
resource "google_storage_bucket_iam_member" "data_reader" {
  bucket = google_storage_bucket.landing_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.manipulation_service_account.email}"
}



