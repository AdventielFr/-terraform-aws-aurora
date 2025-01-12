variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs to use"
}

variable "project" {
  type        = string
  description = " The project name"
}

variable "environment" {
  type        = string
  description = "The environment"
}

variable "identifier_prefix" {
  type        = string
  default     = ""
  description = "The Prefix for cluster and instance identifier"
}

variable "replica_count" {
  type        = number
  default     = 0
  description = "Number of reader nodes to create.  If `replica_scale_enable` is `true`, the value of `replica_scale_min` is used instead."
}

variable "security_groups" {
  type        = list(string)
  description = "VPC Security Group IDs"
}

variable "instance_type" {
  type        = string
  default     = "db.t2.small"
  description = "The Instance type to use"
}

variable "publicly_accessible" {
  type        = bool
  default     = false
  description = "Whether the DB should have a public IP address"
}

variable "username" {
  type        = string
  default     = "root"
  description = "The Master DB username"
}

variable "password" {
  type        = string
  description = "The Master DB password"
  default     = ""
}

variable "final_snapshot_identifier" {
  type        = string
  default     = "final"
  description = "The name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too."
}

variable "skip_final_snapshot" {
  type        = string
  default     = "false"
  description = "Should a final snapshot be created on cluster destroy"
}

variable "backup_retention_period" {
  type        = number
  default     = 7
  description = "How long to keep backups for (in days)"
}

variable "preferred_backup_window" {
  type        = string
  default     = "02:00-03:00"
  description = "When to perform DB backups"
}

variable "preferred_maintenance_window" {
  type        = string
  default     = "sun:05:00-sun:06:00"
  description = "When to perform DB maintenance"
}

variable "port" {
  type        = number
  default     = 3306
  description = "The port on which to accept connections"
}

variable "apply_immediately" {
  type        = bool
  default     = false
  description = "Determines whether or not any DB modifications are applied immediately, or during the maintenance window"
}

variable "monitoring_interval" {
  type        = number
  default     = 0
  description = "The interval (seconds) between points when Enhanced Monitoring metrics are collected"
}

variable "auto_minor_version_upgrade" {
  type        = bool
  default     = true
  description = "Determines whether minor engine upgrades will be performed automatically in the maintenance window"
}

variable "db_parameter_group_name" {
  type        = string
  default     = "default.aurora5.6"
  description = "The name of a DB parameter group to use"
}

variable "db_cluster_parameter_group_name" {
  type        = string
  default     = "default.aurora5.6"
  description = "The name of a DB Cluster parameter group to use"
}

variable "snapshot_identifier" {
  type        = string
  default     = ""
  description = "DB snapshot to create this database from"
}

variable "storage_encrypted" {
  type        = bool
  default     = true
  description = "Specifies whether the underlying storage layer should be encrypted"
}

variable "cw_alarms" {
  type        = bool
  default     = false
  description = "Whether to enable CloudWatch alarms - requires `cw_sns_topic` is specified"
}

variable "cw_sns_topic" {
  type        = string
  default     = ""
  description = "An SNS topic to publish CloudWatch alarms to"
}

variable "cw_max_conns" {
  type        = number
  default     = 500
  description = "Connection count beyond which to trigger a CloudWatch alarm"
}

variable "cw_max_cpu" {
  type        = number
  default     = 85
  description = "CPU threshold above which to alarm"
}

variable "cw_max_replica_lag" {
  type        = number
  default     = 2000
  description = "Maximum Aurora replica lag in milliseconds above which to alarm"
}

variable "cw_eval_period_connections" {
  type        = number
  default     = 1
  description = "Evaluation period for the DB connections alarms"
}

variable "cw_eval_period_cpu" {
  type        = number
  default     = 2
  description = "Evaluation period for the DB CPU alarms"
}

variable "cw_eval_period_replica_lag" {
  type        = number
  default     = 5
  description = "Evaluation period for the DB replica lag alarm"
}

variable "engine" {
  type        = string
  default     = "aurora"
  description = "Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql"
}

variable "engine-version" {
  type        = string
  default     = "5.6.10a"
  description = "Aurora database engine version."
}

variable "replica_scale_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable autoscaling for RDS Aurora (MySQL) read replicas"
}

variable "replica_scale_max" {
  type        = number
  default     = 2
  description = "Maximum number of replicas to allow scaling for"
}

variable "replica_scale_min" {
  type        = number
  default     = 1
  description = "Maximum number of replicas to allow scaling for"
}

variable "replica_scale_cpu" {
  type        = number
  default     = 70
  description = "CPU usage to trigger autoscaling at"
}

variable "replica_scale_in_cooldown" {
  type        = number
  default     = 300
  description = "Cooldown in seconds before allowing further scaling operations after a scale in"
}

variable "replica_scale_out_cooldown" {
  type        = number
  default     = 300
  description = "Cooldown in seconds before allowing further scaling operations after a scale out"
}

variable "performance_insights_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable Performance Insights"
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = false
  description = "Whether to enable IAM database authentication for the RDS Cluster"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "Whether the database resources should be created"
}

variable "tags" {
  description = "The tags for all resources"
  type        = map
  default     = {}
}

variable "db_subnet_group_name" {
  type        = string
  description = "The database Subnet group Name"
}

variable "enabled_cloudwatch_logs_exports" {
  description = "The enable cloudwath log export"
  type        = list(string)
  default     = []
}

variable "kms_key_id" {
  description = "The ARN for the KMS encryption key. When specifying kms_key_id, storage_encrypted needs to be set to true."
  default     = ""
  type        = string
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false."
  default     = true
  type        = bool
}
