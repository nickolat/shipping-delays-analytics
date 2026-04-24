# MANIPULATION LAYER

# APIs
locals {
  manipulation_project_api = [
    "iam.googleapis.com",
    "dataflow.googleapis.com",
    "compute.googleapis.com",
    "storage.googleapis.com",
    "cloudscheduler.googleapis.com",
    "stackdriver.googleapis.com"
  ]
}

# Enable APIs
resource "google_project_service" "manipulation_project_api" {
  for_each = toset(local.manipulation_project_api)
  project  = google_project.manipulation_project.project_id
  service  = each.key
}

# Create a Google Cloud Project for the Manipulation layer
resource "google_project" "manipulation_project" {
  name            = "Manipulation Layer"
  project_id      = "manipulation-layer"
  org_id          = var.organization.id
  billing_account = var.billing_account_id
}

# Dataflow
resource "google_dataflow_flex_template_job" "manipulation_dataflow" {
  provider = google-beta
  name     = "manipulation-dataflow"
  region   = var.location.region
  project  = google_project.manipulation_project.project_id

  # Here I assume to have a json template in which there is the configuration of the
  # Dataflow component
  container_spec_gcs_path = "${google_storage_bucket.manipulation_bucket.url}/templates/template.json"
  parameters = {
    inputBucket    = google_storage_bucket.landing_bucket.url
    serviceAccount = google_service_account.manipulation_service_account.email
  }
}

# Create a GCS bucket for storing Dataflow templates
resource "google_storage_bucket" "manipulation_bucket" {
  name     = "manipulation-bucket"
  project  = google_project.manipulation_project.project_id
  location = var.location.region
}


## Service Account and IAM

# Create a Manipulation service account
resource "google_service_account" "manipulation_service_account" {
  account_id = "manipulation-service-account"
  project    = google_project.manipulation_project.project_id
}

# Dataflow Worker role (project-level)
resource "google_project_iam_member" "dataflow_worker_role" {
  project = google_project.manipulation_project.project_id
  role    = "roles/dataflow.worker" # for running Dataflow jobs
  member  = "serviceAccount:${google_service_account.manipulation_service_account.email}"
}


# Grant storage read access to the service account (for templates)
resource "google_storage_bucket_iam_binding" "manipulation_bucket_iam_binding" {
  bucket = google_storage_bucket.manipulation_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.manipulation_service_account.email}",
  ]
}

# Grant read access to the landing bucket
resource "google_storage_bucket_iam_binding" "landing_bucket_iam_binding_read" {
  bucket = google_storage_bucket.landing_bucket.name
  role   = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.manipulation_service_account.email}",
  ]
}


### Cloud Scheduler

# Service account for Cloud Scheduler
resource "google_service_account" "scheduler_service_account" {
  account_id   = "scheduler-sa"
  display_name = "Cloud Scheduler Service Account"
  project      = google_project.manipulation_project.project_id
}

# IAM binding for Scheduler to invoke Dataflow
resource "google_project_iam_member" "scheduler_dataflow_invoker" {
  project = google_project.manipulation_project.project_id
  role    = "roles/dataflow.admin"
  member  = "serviceAccount:${google_service_account.scheduler_service_account.email}"
}

# IAM binding for Scheduler to invoke Cloud Functions
resource "google_project_iam_member" "scheduler_function_invoker" {
  project = google_project.exposure_project.project_id
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_service_account.email}"
}

# Scheduler job for Dataflow (every 15 minutes)
resource "google_cloud_scheduler_job" "dataflow_scheduler" {
  name             = "trigger-dataflow-job"
  description      = "Triggers Dataflow job every 15 minutes"
  schedule         = "*/15 * * * *"
  time_zone        = "CET"
  attempt_deadline = "320s"
  project          = google_project.manipulation_project.project_id
  region           = var.location.region

  http_target {
    http_method = "POST"
    uri         = "https://dataflow.googleapis.com/v1b3/projects/${google_project.manipulation_project.project_id}/locations/${var.location.region}/flexTemplates:launch"

    oauth_token {
      service_account_email = google_service_account.scheduler_service_account.email
    }

    body = base64encode(jsonencode({
      launch_parameter: {
        jobName: "scheduled-dataflow-job-${formatdate("YYYYMMDDhhmmss", timestamp())}",
        containerSpecGcsPath: google_dataflow_flex_template_job.manipulation_dataflow.container_spec_gcs_path,
        parameters: {
          inputBucket: google_storage_bucket.landing_bucket.url,
          serviceAccount: google_service_account.manipulation_service_account.email
        }
      }
    }))
  }

  depends_on = [google_project_service.manipulation_project_api]
}


# Scheduler job for Cloud Function (daily at 5:00 PM)
resource "google_cloud_scheduler_job" "function_scheduler" {
  name             = "trigger-report-function"
  description      = "Triggers report generation function daily at 5:00 PM"
  schedule         = "0 17 * * *"
  time_zone        = "CET"
  attempt_deadline = "320s"
  project          = google_project.exposure_project.project_id
  region           = var.location.region

  http_target {
    http_method = "POST"
    uri         = "https://${var.location.region}-${google_project.exposure_project.project_id}.cloudfunctions.net/${google_cloudfunctions_function.exposure_function.name}"

    oauth_token {
      service_account_email = google_service_account.scheduler_service_account.email
    }

    body = base64encode(jsonencode({
      data: {
        action: "generate_report",
        recipient: var.team_mark_email
      }
    }))
  }

  depends_on = [google_project_service.manipulation_project_api]
}
