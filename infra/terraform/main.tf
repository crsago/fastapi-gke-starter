terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = var.artifact_repo
  description   = "App images"
  format        = "DOCKER"
}

resource "google_container_cluster" "gke" {
  name     = var.cluster_name
  location = var.location

  release_channel { channel = "REGULAR" }
  networking_mode = "VPC_NATIVE"

  remove_default_node_pool = true
  initial_node_count       = 1

  enable_legacy_abac = false

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  ip_allocation_policy {}

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "primary" {
  name       = "${var.cluster_name}-pool"
  cluster    = google_container_cluster.gke.id
  location   = var.location
  node_count = var.node_count

  node_config {
    machine_type = var.node_type
    disk_size_gb = 50
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    tags         = ["gke-${var.cluster_name}"]
    metadata = { disable-legacy-endpoints = "true" }
  }

  management { auto_repair = true, auto_upgrade = true }
}
