resource "google_compute_network" "vpc_network" {
  name = var.appname

  auto_create_subnetworks = false
}