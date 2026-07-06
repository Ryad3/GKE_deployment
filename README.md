# GKE Deployment — Learning Monorepo

A hands-on learning project: deploy a **Go application** on a **Google Kubernetes Engine (GKE)** cluster, backed by a **managed database**, with the whole stack living in a single monorepo — while applying production-grade quality standards along the way.

> ⚠️ **Work in progress.** This repo grows incrementally as a learning exercise. Right now it contains the Terraform infrastructure scaffolding; the Go app, Kubernetes manifests, and managed database come next. See the [Roadmap](#roadmap).

## Goals

- Provision GCP infrastructure as code with **Terraform**, split into small, single-responsibility layers.
- Run a containerized **Go** service on **GKE**.
- Connect it to a **managed database** (e.g. Cloud SQL).
- Keep everything reproducible: pinned tool versions, remote state, no secrets in git.
- Treat it like real work: clear structure, conventions, and documentation.

## Tech Stack

| Concern            | Choice                                  |
| ------------------ | --------------------------------------- |
| Infrastructure     | Terraform (`~> 1.9`), Google provider `~> 6.0` |
| Cloud              | Google Cloud Platform (GKE)             |
| State backend      | Google Cloud Storage (GCS), one prefix per layer |
| Tooling / versions | [mise](https://mise.jdx.dev/)           |
| Application        | Go *(coming soon)*                      |
| Database           | Managed DB, e.g. Cloud SQL *(coming soon)* |

## Repository Layout

```
.
├── .mise.toml                     # Pinned tools (gcloud, terraform) + tasks + KUBECONFIG
└── terraform/
    ├── layers/                    # Independently applied Terraform layers (separate state)
    │   ├── backend.hcl.example    # Shared partial backend config (copy to backend.hcl)
    │   ├── network/               # ✅ VPC + subnet with secondary ranges (pods/services)
    │   ├── cluster/               # 🚧 GKE cluster (scaffolded)
    │   └── machine/               # 🚧 Node pool / compute (scaffolded)
    └── module/                    # 🚧 Reusable Terraform modules (future)
```

### Why layers?

Each layer under `terraform/layers/` has its **own state file** (a distinct `prefix` in the same GCS bucket). This keeps blast radius small, lets layers be applied independently, and makes dependencies explicit — downstream layers read upstream outputs through a `terraform_remote_state` data source rather than sharing one giant state.

Current dependency direction: `network` → `cluster` → `machine`.

## Prerequisites

- A GCP project with billing enabled.
- A **GCS bucket** to hold Terraform state (created out-of-band, before the first `init`).
- [mise](https://mise.jdx.dev/) installed (manages `gcloud` and `terraform` versions).
- `gcloud` authenticated (see below).

## Getting Started

### 1. Install tooling

```bash
mise install          # installs gcloud + terraform at the pinned versions
```

### 2. Authenticate to GCP

```bash
mise run gcp-auth     # runs: gcloud auth login + gcloud auth application-default login
```

### 3. Configure the state backend

The `backend` block cannot use variables, so the bucket is passed as a **partial backend config** at init time. Copy the example and set your bucket:

```bash
cp terraform/layers/backend.hcl.example terraform/layers/backend.hcl
# edit backend.hcl -> bucket = "your-tfstate-bucket"
```

`backend.hcl` is git-ignored. Each layer keeps its own `prefix` hardcoded in its `provider.tf`.

### 4. Configure layer variables

Each layer ships a `terraform.tfvars.example`. Copy it and fill in your values:

```bash
cd terraform/layers/network
cp terraform.tfvars.example terraform.tfvars
# edit project_id, region, zone, appname
```

`terraform.tfvars` files are git-ignored — only the `.example` is committed.

### 5. Apply the network layer

```bash
cd terraform/layers/network
terraform init -backend-config=../backend.hcl
terraform plan
terraform apply
```

Apply subsequent layers (`cluster`, then `machine`) the same way, in dependency order.

> Changing `backend.hcl` after a first init? Re-run with `terraform init -reconfigure`.

## Conventions

- **State**: one GCS prefix per layer; never share state across layers.
- **Secrets & env values**: only `*.example` files are committed. Real `*.tfvars` and `backend.hcl` are git-ignored.
- **Tool versions**: pinned in `.mise.toml` — no "works on my machine".
- **Commits**: [Conventional Commits](https://www.conventionalcommits.org/).

## Current Status

- ✅ **`network`** — VPC (`google_compute_network`) + subnet with secondary IP ranges for GKE pods and services.
- 🚧 **`cluster`** — provider/variables scaffolded; GKE cluster resource to be written.
- 🚧 **`machine`** — provider/variables scaffolded; node pool / compute to be written.
- ⬜ **Go application** — not started.
- ⬜ **Kubernetes manifests** — not started.
- ⬜ **Managed database** — not started.

## Roadmap

- [ ] Add outputs to `network` (network id, subnet id, secondary range names).
- [ ] Write the `cluster` layer: `google_container_cluster` consuming network outputs via remote state.
- [ ] Write the `machine` layer: managed node pool.
- [ ] Provision a managed database (Cloud SQL) and wire connectivity.
- [ ] Add the Go application (source, Dockerfile, CI).
- [ ] Add Kubernetes manifests / deployment workflow.
- [ ] Extract shared logic into `terraform/module/`.

---

*Personal learning project — deliberately built step by step.*
