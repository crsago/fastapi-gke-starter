variable "project_id"   { type = string }
variable "region"       { type = string }
variable "location"     { type = string }
variable "cluster_name" { type = string  default = "hello-private-gke" }
variable "node_type"    { type = string  default = "e2-standard-2" }
variable "node_count"   { type = number  default = 2 }
variable "artifact_repo"{ type = string  default = "apps" }
