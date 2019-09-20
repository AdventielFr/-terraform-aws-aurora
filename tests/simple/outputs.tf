output "cluster_endpoint" {
  description = "The 'writer' endpoint for the cluster"
  value       = module.rds.cluster_endpoint
}

output "all_instance_endpoints_list" {
  description = "Comma separated list of all DB instance endpoints running in cluster"
  value       = module.rds.all_instance_endpoints_list
}

output "reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
  value       = module.rds.reader_endpoint
}

output "cluster_identifier" {
  description = "The ID of the RDS Cluster"
  value       = module.rds.cluster_identifier
}

output "password" {
  description = "The Db password to connect with 'SupermanVsSpiderman' user"
  value = module.rds.password
}