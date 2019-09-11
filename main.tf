locals {
  tags = {
    Environment = var.environment
    Project = var.project
  }
}


// Geneate an ID when an environment is initialised
resource "random_id" "server" {
  keepers = {
    id = var.db_subnet_group_name
  }

  byte_length = 8
}

#------------------------------
# Cluster
#------------------------------
resource "aws_rds_cluster" "default" {
  
  cluster_identifier = var.identifier_prefix != "" ? format("%s-cluster", var.identifier_prefix) : format("%s-%s-cluster-aurora", var.environment, var.project)
  availability_zones = var.azs
  engine             = var.engine

  engine_version                      = var.engine-version
  master_username                     = var.username
  master_password                     = var.password
  final_snapshot_identifier           = "${var.final_snapshot_identifier}-${element(random_id.server.*.hex,0)}"
  skip_final_snapshot                 = var.skip_final_snapshot
  backup_retention_period             = var.backup_retention_period
  preferred_backup_window             = var.preferred_backup_window
  preferred_maintenance_window        = var.preferred_maintenance_window
  port                                = var.port
  db_subnet_group_name                = var.db_subnet_group_name
  vpc_security_group_ids              = var.security_groups
  snapshot_identifier                 = var.snapshot_identifier
  storage_encrypted                   = var.storage_encrypted
  kms_key_id                          = var.kms_key_id
  apply_immediately                   = var.apply_immediately
  db_cluster_parameter_group_name     = var.db_cluster_parameter_group_name
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  deletion_protection                 = var.deletion_protection
  tags = merge(var.tags,local.tags)
}

#------------------------------
# Nodes
#------------------------------
resource "aws_rds_cluster_instance" "cluster_instance_0" {
  depends_on = ["aws_iam_role_policy_attachment.rds-enhanced-monitoring-policy-attach"]
  identifier                   = var.identifier_prefix != "" ? format("%s-node-0", var.identifier_prefix) : format("%s-%s-aurora-node-0", var.environment, var.project)
  cluster_identifier           = aws_rds_cluster.default.id
  engine                       = var.engine
  engine_version               = var.engine-version
  instance_class               = var.instance_type
  publicly_accessible          = var.publicly_accessible
  db_subnet_group_name         = var.db_subnet_group_name
  db_parameter_group_name      = var.db_parameter_group_name
  preferred_maintenance_window = var.preferred_maintenance_window
  apply_immediately            = var.apply_immediately
  monitoring_role_arn          = "${join("", aws_iam_role.rds-enhanced-monitoring.*.arn)}"
  monitoring_interval          = var.monitoring_interval
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  promotion_tier               = 0
  performance_insights_enabled = var.performance_insights_enabled
  tags = merge(var.tags,local.tags)
}

resource "aws_rds_cluster_instance" "cluster_instance_n" {
  depends_on                   = ["aws_rds_cluster_instance.cluster_instance_0"]
  count                        = var.replica_scale_enabled ? var.replica_scale_min : var.replica_count
  engine                       = var.engine
  engine_version               = var.engine-version
  identifier                   = var.identifier_prefix != "" ? format("%s-node-%d", var.identifier_prefix, count.index + 1) : format("%s-%s-aurora-node-%d", var.environment, var.project, count.index + 1)
  cluster_identifier           = element(aws_rds_cluster.default.*.id,0)
  instance_class               = var.instance_type
  publicly_accessible          = var.publicly_accessible
  db_subnet_group_name         = var.db_subnet_group_name
  db_parameter_group_name      = var.db_parameter_group_name
  preferred_maintenance_window = var.preferred_maintenance_window
  apply_immediately            = var.apply_immediately
  monitoring_role_arn          = "${join("", aws_iam_role.rds-enhanced-monitoring.*.arn)}"
  monitoring_interval          = var.monitoring_interval
  auto_minor_version_upgrade   = var.auto_minor_version_upgrade
  promotion_tier               = count.index + 1
  performance_insights_enabled = var.performance_insights_enabled
  tags = merge(var.tags,local.tags)
}


#------------------------------
# IAM role 
#------------------------------
data "aws_iam_policy_document" "monitoring-rds-assume-role-policy" {
  count = var.enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds-enhanced-monitoring" {
  count              = var.monitoring_interval > 0 ? 1 : 0
  name_prefix        = "rds-enhanced-mon-${var.environment}-${var.project}-"
  assume_role_policy = element(data.aws_iam_policy_document.monitoring-rds-assume-role-policy.*.json,0)
}

resource "aws_iam_role_policy_attachment" "rds-enhanced-monitoring-policy-attach" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = element(aws_iam_role.rds-enhanced-monitoring.*.name,0)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

#------------------------------
# Autoscaling 
#------------------------------
resource "aws_appautoscaling_target" "autoscaling" {
  count              = var.replica_scale_enabled ? 1 : 0
  max_capacity       = var.replica_scale_max
  min_capacity       = var.replica_scale_min
  resource_id        = "cluster:${aws_rds_cluster.default.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"
}

resource "aws_appautoscaling_policy" "autoscaling" {
  count              = var.replica_scale_enabled ? 1 : 0
  depends_on         = ["aws_appautoscaling_target.autoscaling"]
  name               = "target-metric"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "cluster:${aws_rds_cluster.default.cluster_identifier}"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  service_namespace  = "rds"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    scale_in_cooldown  = var.replica_scale_in_cooldown
    scale_out_cooldown = var.replica_scale_out_cooldown
    target_value       = var.replica_scale_cpu
  }
}

#------------------------------
# Cloudwatch Alarms
#------------------------------

resource "aws_cloudwatch_metric_alarm" "alarm_rds_DatabaseConnections_writer" {
  count               = var.cw_alarms ? 1 : 0
  alarm_name          = "${aws_rds_cluster.default.id}-alarm-rds-writer-DatabaseConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cw_eval_period_connections
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Sum"
  threshold           = var.cw_max_conns
  alarm_description   = "RDS Maximum connection Alarm for ${aws_rds_cluster.default.id} writer"
  alarm_actions       = [var.cw_sns_topic]
  ok_actions          = [var.cw_sns_topic]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.default.id
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_rds_DatabaseConnections_reader" {
  count               = var.cw_alarms && var.replica_count > 0 ? 1 : 0
  alarm_name          = "${aws_rds_cluster.default.id}-alarm-rds-reader-DatabaseConnections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cw_eval_period_connections
  metric_name         = "DatabaseConnections"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.cw_max_conns
  alarm_description   = "RDS Maximum connection Alarm for ${aws_rds_cluster.default.id} reader(s)"
  alarm_actions       = [var.cw_sns_topic]
  ok_actions          = [var.cw_sns_topic]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.default.id
    Role                = "READER"
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_rds_CPU_writer" {
  count               = var.cw_alarms ? 1 : 0
  alarm_name          = "${aws_rds_cluster.default.id}-alarm-rds-writer-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cw_eval_period_cpu
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.cw_max_cpu
  alarm_description   = "RDS CPU Alarm for ${aws_rds_cluster.default.id} writer"
  alarm_actions       = [var.cw_sns_topic]
  ok_actions          = [var.cw_sns_topic]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.default.id
    Role                = "WRITER"
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_rds_CPU_reader" {
  count               = var.cw_alarms && var.replica_count > 0 ? 1 : 0
  alarm_name          = "${aws_rds_cluster.default.id}-alarm-rds-reader-CPU"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cw_eval_period_cpu
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.cw_max_cpu
  alarm_description   = "RDS CPU Alarm for ${aws_rds_cluster.default.id} reader(s)"
  alarm_actions       = [var.cw_sns_topic]
  ok_actions          = [var.cw_sns_topic]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.default.id
    Role                = "READER"
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_rds_replica_lag" {
  count               = var.cw_alarms && var.replica_count > 0 ? 1 : 0
  alarm_name          = "${aws_rds_cluster.default.id}-alarm-rds-reader-AuroraReplicaLag"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cw_eval_period_replica_lag
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Maximum"
  threshold           = var.cw_max_replica_lag
  alarm_description   = "RDS CPU Alarm for ${aws_rds_cluster.default.id}"
  alarm_actions       = [var.cw_sns_topic]
  ok_actions          = [var.cw_sns_topic]

  dimensions = {
    DBClusterIdentifier = aws_rds_cluster.default.id
    Role                = "READER"
  }
}