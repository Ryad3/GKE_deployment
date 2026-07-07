locals {
  subnet_cidr         = "10.1.0.0/26"
  pods_range_name     = "cluster-pod-ip-range"
  pods_cidr           = "10.0.0.0/16"
  services_range_name = "cluster-service-ip-range"
  services_cidr       = "10.2.0.0/25"
}

resource "google_compute_subnetwork" "gke_subnet" {
  name    = var.appname
  network = google_compute_network.vpc_network.id
  region  = var.region

  ip_cidr_range = local.subnet_cidr

  secondary_ip_range {
    range_name    = local.pods_range_name
    ip_cidr_range = local.pods_cidr
  }

  secondary_ip_range {
    range_name    = local.services_range_name
    ip_cidr_range = local.services_cidr
  }
}
