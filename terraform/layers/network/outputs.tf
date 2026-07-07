output "network_id" {
  description = "Self-link/ID of the VPC network"
  value       = google_compute_network.vpc_network.id
}

output "network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "subnet_id" {
  description = "Self-link/ID of the GKE subnet"
  value       = google_compute_subnetwork.gke_subnet.id
}

output "subnet_name" {
  description = "Name of the GKE subnet"
  value       = google_compute_subnetwork.gke_subnet.name
}

output "pods_range_name" {
  description = "Secondary range name for GKE pods"
  value       = local.pods_range_name
}

output "services_range_name" {
  description = "Secondary range name for GKE services"
  value       = local.services_range_name
}
