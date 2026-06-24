resource "google_compute_subnetwork" "gke_subnet" {
  name    = var.appname
  network = google_compute_network.vpc_network.id

  region = var.region

  ip_cidr_range = "10.1.0.0/26"

  secondary_ip_range {
    range_name    = "cluster-pod-ip-range"
    ip_cidr_range = "10.0.0.0/16"
  }

  secondary_ip_range {
    range_name    = "cluster-service-ip-range"
    ip_cidr_range = "10.2.0.0/25"
  }
}