<p align="center">
  <table>
    <tr>
      <td style="text-align: center; vertical-align: middle;"><img src="_docs/logo_aws.jpg"/></td>
      <td style="text-align: center; vertical-align: middle;"><img src="_docs/logo_adv.jpg"/></td>
    </tr> 
  <table>
</p>

# AWS ECS Aurora Terraform module

The purpose of this module is to create an AWS Aurora cluster


## Inputs / Outputs

### Inputs

| Name | Description | Type | Default |
|------|-------------|:----:|:-----:|
| apply\_immediately | Determines whether or not any DB modifications are applied immediately, or during the maintenance window | bool | false |
| auto\_minor\_version\_upgrade | Determines whether minor engine upgrades will be performed automatically in the maintenance window | bool | true |
| backup\_retention\_period | How long to keep backups for (in days) | number | 7 |
| cw\_alarms | Whether to enable CloudWatch alarms - requires `cw\_sns\_topic` is specified | bool | false |
| cw\_eval\_period\_connections | Evaluation period for the DB connections alarms | number | 1 |
| cw\_eval\_period\_cpu | Evaluation period for the DB CPU alarms | number | 2 |
| cw\_eval\_period\_replica\_lag | Evaluation period for the DB replica lag alarm | number | 5 |
| cw\_max\_conns | Connection count beyond which to trigger a CloudWatch alarm | number | 500 |
| cw\_max\_cpu | CPU threshold above which to alarm | number | 85 |
| cw\_max\_replica\_lag | Maximum Aurora replica lag in milliseconds above which to alarm | number | 2000 |
| cw\_sns\_topic | An SNS topic to publish CloudWatch alarms to | string | "" |
| db\_cluster\_parameter\_group\_name | The name of a DB Cluster parameter group to use | string | "default.aurora5.6" |
| db\_parameter\_group\_name | The name of a DB parameter group to use | string | "default.aurora5.6" |
| db\_subnet\_group\_name | The database Subnet group Name | string | n/a |
| deletion\_protection | If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false. | bool | true |
| enabled | Whether the database resources should be created | bool | true |
| enabled\_cloudwatch\_logs\_exports | The enable cloudwath log export | list(string) | \[\] |
| engine | Aurora database engine type, currently aurora, aurora-mysql or aurora-postgresql | string | "aurora" |
| engine-version | Aurora database engine version. | string | "5.6.10a" |
| environment | The environment | string | n/a |
| final\_snapshot\_identifier | The name to use when creating a final snapshot on cluster destroy, appends a random 8 digits to name to ensure it's unique too. | string | "final" |
| iam\_database\_authentication\_enabled | Whether to enable IAM database authentication for the RDS Cluster | bool | false |
| identifier\_prefix | The Prefix for cluster and instance identifier | string | "" |
| instance\_type | The Instance type to use | string | "db.t2.small" |
| kms\_key\_id | The ARN for the KMS encryption key. When specifying kms\_key\_id, storage\_encrypted needs to be set to true. | string | "" |
| monitoring\_interval | The interval (seconds) between points when Enhanced Monitoring metrics are collected | number | 0 |
| password | The Master DB password | string | "" |
| performance\_insights\_enabled | Whether to enable Performance Insights | bool | false |
| port | The port on which to accept connections | number | 3306 |
| preferred\_backup\_window | When to perform DB backups | string | "02:00-03:00" |
| preferred\_maintenance\_window | When to perform DB maintenance | string | "sun:05:00-sun:06:00" |
| project | The project name | string | n/a |
| publicly\_accessible | Whether the DB should have a public IP address | bool | false |
| replica\_count | Number of reader nodes to create.  If `replica\_scale\_enable` is `true`, the value of `replica\_scale\_min` is used instead. | number | 0 |
| replica\_scale\_cpu | CPU usage to trigger autoscaling at | number | 70 |
| replica\_scale\_enabled | Whether to enable autoscaling for RDS Aurora (MySQL) read replicas | bool | false |
| replica\_scale\_in\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale in | number | 300 |
| replica\_scale\_max | Maximum number of replicas to allow scaling for | number | 2 |
| replica\_scale\_min | Maximum number of replicas to allow scaling for | number | 1 |
| replica\_scale\_out\_cooldown | Cooldown in seconds before allowing further scaling operations after a scale out | number | 300 |
| security\_groups | VPC Security Group IDs | list(string) | n/a |
| skip\_final\_snapshot | Should a final snapshot be created on cluster destroy | string | "false" |
| snapshot\_identifier | DB snapshot to create this database from | string | "" |
| storage\_encrypted | Specifies whether the underlying storage layer should be encrypted | bool | true |
| subnets | List of subnet IDs to use | list(string) | n/a |
| tags | The tags for all resources | map | {} |
| username | The Master DB username | string | n/a |
| username | The Master DB username | string | "root" |

### Outputs

| Name | Description |
|------|-------------|
| all\_instance\_endpoints\_list | Comma separated list of all DB instance endpoints running in cluster |
| cluster\_endpoint | The 'writer' endpoint for the cluster |
| cluster\_identifier | The ID of the RDS Cluster |
| password | The Master DB password |
| reader\_endpoint | A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas |

## Usage

`````

----------------------------
# RDS module
#----------------------------
module "sample" {
  source = "git::https://github.com/AdventielFr/terraform-aws-aurora.git?ref=1.0.0"
  engine                              = "aurora-postgresql"
  engine-version                      = "10.7"
  name                                = "dev-sample-db"
  environment                         = "dev"
  project                             = "sample"
  subnets                             = [
    xxx,
    xxx
  ]
  azs                                 = [
    xxx,
    xxx
  ]
  replica_count                       = 0
  db_subnet_group_name                = [
    xxx,
    xxx
  ]
  security_groups                     = [
    xxx,
    xxx
  ]
  instance_type                       = "t2.small"
  username                            = "superuser"
  password                            = local.db_password
  backup_retention_period             = 10
  final_snapshot_identifier           = "dev-sample-db-snapshot"
  storage_encrypted                   = true
  apply_immediately                   = true
  monitoring_interval                 = 10
  cw_alarms                           = true
  enabled_cloudwatch_logs_exports     = []
  iam_database_authentication_enabled = false
}

`````
