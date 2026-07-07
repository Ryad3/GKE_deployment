# Infrastructure Resources

Inventory of every Terraform-managed resource in this repo, grouped by layer.
Kept in sync as layers evolve. Status legend: ✅ implemented · 🚧 planned.

Layers apply in order: `network` → `cluster` → `machine`.
Each layer has its own GCS state (`terraform/state/<layer>`) and reads upstream
layers through `terraform_remote_state` data sources.

---

## Layer: `network` ✅

| Terraform address | Type | Purpose |
| --- | --- | --- |
| `google_compute_network.vpc_network` | VPC network | Custom-mode VPC (`auto_create_subnetworks = false`). |
| `google_compute_subnetwork.gke_subnet` | Subnetwork | Regional subnet for GKE. Primary range = **node** IPs; two secondary ranges for pods and services (VPC-native). |

**Outputs consumed downstream:** `network_id`, `network_name`, `subnet_id`,
`subnet_name`, `pods_range_name`, `services_range_name`.

**IP plan**

| Range | Role | CIDR | Local |
| --- | --- | --- | --- |
| Primary | Nodes | `10.1.0.0/26` | `subnet_cidr` |
| Secondary | Pods | `10.0.0.0/16` | `pods_cidr` / `pods_range_name` |
| Secondary | Services | `10.2.0.0/25` | `services_cidr` / `services_range_name` |

---

## Layer: `cluster` 🚧

Provisions the GKE control plane and a **dedicated, least-privilege service
account** for the nodes — never reuse the default Compute Engine SA.

| Terraform address | Type | Purpose |
| --- | --- | --- |
| `google_service_account.gke_nodes` | Service account | Identity attached to the node pool VMs. |
| `google_project_iam_member.gke_nodes[*]` | Project IAM binding | Minimal roles granted to the node SA (see below). |
| `google_container_cluster.primary` | GKE cluster | VPC-native cluster; references network + secondary ranges from the `network` layer via remote state. |

**Node service account — minimal roles**

| Role | Why |
| --- | --- |
| `roles/logging.logWriter` | Ship node/pod logs to Cloud Logging. |
| `roles/monitoring.metricWriter` | Ship metrics to Cloud Monitoring. |
| `roles/monitoring.viewer` | Monitoring agent reads. |
| `roles/stackdriver.resourceMetadata.writer` | Resource metadata for observability. |
| `roles/artifactregistry.reader` | Pull container images from Artifact Registry. |

> Grant additional roles only when a workload actually needs them; prefer
> **Workload Identity** over SA keys for pod-level GCP access.

**Remote state read from `network`:** `network_id`, `subnet_id`,
`pods_range_name`, `services_range_name`.

---

## Layer: `machine` 🚧

| Terraform address | Type | Purpose |
| --- | --- | --- |
| `google_container_node_pool.primary` | Node pool | Managed node pool attached to the cluster, running as the node SA above. |

**Remote state read from `cluster`:** cluster name/location, node SA email.

---

## Not yet layered ⬜

- **Managed database** (Cloud SQL) + private connectivity.
- **Artifact Registry** repository for the Go app image.
- **Workload Identity** bindings for app → GCP access.

---

*Update this file in the same commit as the resource change it documents.*
