resource "google_compute_network" "vpc_network" {
  name    = var.appname
  project = var.project_id

  auto_create_subnetworks = false
}