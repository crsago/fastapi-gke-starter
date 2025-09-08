output "cluster_name" { value = google_container_cluster.gke.name }
output "location"     { value = google_container_cluster.gke.location }
output "repo_path"    { value = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repo}" }
