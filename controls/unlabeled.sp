locals {
  unlabeled_sql = <<EOT
    select
      self_link as resource,
      case
        when labels is not null then 'ok'
        else 'alarm'
      end as status,
      case
        when labels is not null then title || ' has labels.'
        else title || ' has no labels.'
      end as reason,
      __DIMENSIONS__
    from
      __TABLE_NAME__
  EOT
}

locals {
  unlabeled_sql_project  = replace(local.unlabeled_sql, "__DIMENSIONS__", "project")
  unlabeled_sql_location = replace(local.unlabeled_sql, "__DIMENSIONS__", "location, project")
}

benchmark "unlabeled" {
  title       = "Unlabeled"
  description = "Unlabeled resources are difficult to monitor and should be identified and remediated."
  children = [
    control.bigquery_dataset_unlabeled,
    control.bigquery_job_unlabeled,
    control.bigquery_table_unlabeled,
    control.compute_disk_unlabeled,
    control.compute_forwarding_rule_unlabeled,
    control.compute_image_unlabeled,
    control.compute_instance_unlabeled,
    control.compute_snapshot_unlabeled,
    control.dns_managed_zone_unlabeled,
    control.sql_database_instance_unlabeled,
    control.storage_bucket_unlabeled
  ]
}

control "bigquery_dataset_unlabeled" {
  title       = "BigQuery datasets should be labeled"
  description = "Check if BigQuery datasets have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_bigquery_dataset")
}

control "bigquery_job_unlabeled" {
  title       = "BigQuery jobs should be labeled"
  description = "Check if BigQuery jobs have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_bigquery_job")
}

control "bigquery_table_unlabeled" {
  title       = "BigQuery tables should be labeled"
  description = "Check if BigQuery tables have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_bigquery_table")
}

control "compute_disk_unlabeled" {
  title       = "Compute disks should be labeled"
  description = "Check if Compute disks have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_compute_disk")
}

control "compute_forwarding_rule_unlabeled" {
  title       = "Compute forwarding rules should be labeled"
  description = "Check if Compute forwarding rules have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_compute_forwarding_rule")
}

control "compute_image_unlabeled" {
  title       = "Compute images should be labeled"
  description = "Check if Compute images have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_compute_image")
}

control "compute_instance_unlabeled" {
  title       = "Compute instances should be labeled"
  description = "Check if Compute instances have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_compute_instance")
}

control "compute_snapshot_unlabeled" {
  title       = "Compute snapshots should be labeled"
  description = "Check if Compute snapshots have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_compute_snapshot")
}

control "dns_managed_zone_unlabeled" {
  title       = "DNS managed zones should be labeled"
  description = "Check if DNS managed zones have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_dns_managed_zone")
}

control "sql_database_instance_unlabeled" {
  title       = "SQL database instances should be labeled"
  description = "Check if Sql database instances have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_sql_database_instance")
}

control "storage_bucket_unlabeled" {
  title       = "Storage buckets should be labeled"
  description = "Check if Storage buckets have at least 1 label."
  sql         = replace(local.unlabeled_sql_location, "__TABLE_NAME__", "gcp_storage_bucket")
}
