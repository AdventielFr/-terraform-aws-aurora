output "cluster_endpoint" {
  description ="The 'writer' endpoint for the cluster"
  value = "${join("", aws_rds_cluster.default.*.endpoint)}"
}

output "all_instance_endpoints_list" {
  description = "Comma separated list of all DB instance endpoints running in cluster"
  value = ["${concat(aws_rds_cluster_instance.cluster_instance_0.*.endpoint, aws_rds_cluster_instance.cluster_instance_n.*.endpoint)}"]
}


output "reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
  value = "${join("", aws_rds_cluster.default.*.reader_endpoint)}"
}

output "cluster_identifier" {
  description ="The ID of the RDS Cluster"
  value = "${join("", aws_rds_cluster.default.*.id)}"
}

output "password" {
  description = "The Master DB password"
  value = local.password
}

variable "username" {
  description = "The Master DB username"
  value = var.username
}
