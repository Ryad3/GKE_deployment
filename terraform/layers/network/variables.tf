variable "project_id" {
  description = "GCP project ID the network resources are created in"
  type        = string
}

variable "region" {
  description = "GCP region hosting the subnet"
  type        = string
}

variable "zone" {
  description = "Default GCP zone for the google provider"
  type        = string
}

variable "appname" {
  description = "Application name, used to name the VPC and subnet"
  type        = string
}
