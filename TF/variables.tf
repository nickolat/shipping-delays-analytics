variable "billing_account_id" {
  description = "The ID of the billing account"
  type    = string
  default = "XXXXXX-XXXXXX-XXXXXX"
}

variable "organization" {
  description = "Organization details"
  type = object({
    domain = string
    id     = number
  })
  default = {
    domain = "projectwork.test"
    id     = 000000000000
  }
}

variable "location" {
  description = "Location settings for resources"
  type = object({
    region       = string
    multi_region = string
  })
  default = {
    region       = "europe-west1"
    multi_region = "EU"
  }
}

variable "external_api_url" {
  description = "URL of the external API for sending data to the third-party monitoring console"
  type        = string
  default     = "https://api.externalservice.com/v1/data"
}

variable "team_de_email" {
  description = "Email address for Data Engineers team to receive the data pipeline report"
  type        = string
  default     = "team-de@example.com"
}

variable "team_mark_email" {
  description = "Email address for Marketing team to receive the daily forecast report"
  type        = string
  default     = "team-mark@example.com"
}


