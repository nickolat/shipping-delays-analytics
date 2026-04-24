# EXPOSURE LAYER

# APIs
locals {
  exposure_project_api = [
    "iam.googleapis.com",
    "stackdriver.googleapis.com",
    "cloudfunctions.googleapis.com",
    "cloudsql.googleapis.com",
    "storage.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}

# Enable APIs
resource "google_project_service" "exposure_project_api" {
  for_each = toset(local.exposure_project_api)
  project  = google_project.exposure_project.project_id
  service  = each.key
}

# Create a Google Cloud Project for the Exposure layer
resource "google_project" "exposure_project" {
  name            = "Exposure Layer"
  project_id      = "exposure-layer"
  org_id          = var.organization.id
  billing_account = var.billing_account_id
}

# Storage bucket for function
resource "google_storage_bucket" "exposure_bucket_function" {
  name     = "exposure-bucket-function"
  location = var.location.region
  project  = google_project.exposure_project.project_id
}

# Note: it is necessary to add cloud function code to folder
resource "google_storage_bucket_object" "exposure_object_function" {
  name   = "index.zip"
  bucket = google_storage_bucket.exposure_bucket_function.name
  source = "./code"
}

# Cloud Functions function
resource "google_cloudfunctions_function" "exposure_function" {
  name    = "exposure-function"
  runtime = "python311"
  project = google_project.exposure_project.project_id
  region  = var.location.region

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.exposure_bucket_function.name
  source_archive_object = google_storage_bucket_object.exposure_object_function.name
  trigger_http          = true
  entry_point           = "predict"

  environment_variables = {
    EXTERNAL_API_URL = var.external_api_url
    TEAM_DE_EMAIL     = var.team_de_email
    TEAM_MARK_EMAIL     = var.team_mark_email
  }
}

# Cloud SQL
resource "google_sql_database" "exposure_cloudsql" {
  name     = "exposure-cloudsql"
  instance = google_sql_database_instance.exposure_cloudsql_instance.name
}

# Cloud SQL instance
resource "google_sql_database_instance" "exposure_cloudsql_instance" {
  name             = "exposure-cloudsql-instance"
  region           = var.location.region
  database_version = "POSTGRES_15"
  settings {
    tier = "db-standard-2"

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }
  deletion_protection = "true"
}

# Cloud SQL IAM Users (exposure, consumption, Power BI)
resource "google_sql_user" "exposure_cloudsql_iam_users" {
  for_each = {
    exposure    = google_service_account.exposure_service_account.email
    consumption = google_service_account.consumption_service_account.email
    pbi         = google_service_account.exposure_service_account_pbi.email
  }

  name     = trimsuffix(each.value, ".gserviceaccount.com")
  instance = google_sql_database_instance.exposure_cloudsql_instance.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
}

# Exposure Service Account
resource "google_service_account" "exposure_service_account" {
  account_id = "exposure-service-account"
  project    = google_project.exposure_project.project_id
}

# Exposure (Power BI) service account
resource "google_service_account" "exposure_service_account_pbi" {
  account_id = "exposure-service-account-pbi"
  project    = google_project.exposure_project.project_id
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "exposure_function_iam_member" {
  project        = google_project.exposure_project.project_id
  region         = var.location.region
  cloud_function = google_cloudfunctions_function.exposure_function.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.consumption_service_account.email}"
}

# Grant storage read access to the service account
resource "google_storage_bucket_iam_binding" "exposure_bucket_iam_binding_0" {
  bucket = google_storage_bucket.exposure_bucket_function.name
  role   = "roles/storage.objectViewer"

  members = [
    "serviceAccount:${google_service_account.exposure_service_account.email}",
  ]
}

# Grant necessary permissions to the exposure service account
resource "google_project_iam_member" "exposure_service_account_permissions" {
  project = google_project.exposure_project.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.exposure_service_account.email}"
}

# SMTP: Create secrets for sensitive information
resource "google_secret_manager_secret" "smtp_credentials" {
  secret_id = "smtp-credentials"
  project   = google_project.exposure_project.project_id

  replication {
    automatic = true
  }
}

# Grant access to secrets for the exposure service account
resource "google_secret_manager_secret_iam_member" "exposure_secret_access" {
  project   = google_project.exposure_project.project_id
  secret_id = google_secret_manager_secret.smtp_credentials.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.exposure_service_account.email}"
}
