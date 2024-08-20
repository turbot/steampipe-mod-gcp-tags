variable "label_limit" {
  type        = number
  description = "Number of labels allowed on a resource. GCP allows up to 64 labels per resource."
  default     = 60
}

locals {
  limit_sql = <<-EOQ
    with analysis as (
      select
        self_link,
        title,
        cardinality(array(select jsonb_object_keys(labels))) as num_label_keys,
        location,
        project,
        _ctx
      from
        __TABLE_NAME__
    )
    select
      self_link as resource,
      case
        when num_label_keys > $1::integer then 'alarm'
        else 'ok'
      end as status,
      title || ' has ' || num_label_keys || ' label(s).' as reason
      ${local.tag_dimensions_sql}
      ${local.common_dimensions_sql}
    from
      analysis
  EOQ
}

benchmark "limit" {
  title       = "Limit"
  description = "The number of labels on each resource should be monitored to avoid hitting the limit unexpectedly."
  children = [
    control.bigquery_dataset_label_limit,
    control.bigquery_job_label_limit,
    control.bigquery_table_label_limit,
    control.bigtable_instance_label_limit,
    control.compute_disk_label_limit,
    control.compute_forwarding_rule_label_limit,
    control.compute_image_label_limit,
    control.compute_instance_label_limit,
    control.compute_snapshot_label_limit,
    control.dataproc_cluster_label_limit,
    control.dns_managed_zone_label_limit,
    control.pubsub_subscription_label_limit,
    control.pubsub_topic_label_limit,
    control.sql_database_instance_label_limit,
    control.storage_bucket_label_limit
  ]

  tags = merge(local.gcp_labels_common_tags, {
    type = "Benchmark"
  })
}

control "bigquery_dataset_label_limit" {
  title       = "BigQuery datasets should not exceed label limit"
  description = "Check if the number of labels on BigQuery datasets do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_bigquery_dataset")
  param "label_limit" {
    default = var.label_limit
  }
}

control "bigquery_job_label_limit" {
  title       = "BigQuery jobs should not exceed label limit"
  description = "Check if the number of labels on BigQuery jobs do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_bigquery_job")
  param "label_limit" {
    default = var.label_limit
  }
}

control "bigquery_table_label_limit" {
  title       = "BigQuery tables should not exceed label limit"
  description = "Check if the number of labels on BigQuery tables do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_bigquery_table")
  param "label_limit" {
    default = var.label_limit
  }
}

control "compute_disk_label_limit" {
  title       = "Compute disks should not exceed label limit"
  description = "Check if the number of labels on Compute disks do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_compute_disk")
  param "label_limit" {
    default = var.label_limit
  }
}

control "compute_forwarding_rule_label_limit" {
  title       = "Compute forwarding rules should not exceed label limit"
  description = "Check if the number of labels on Compute forwarding rules do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_compute_forwarding_rule")
  param "label_limit" {
    default = var.label_limit
  }
}

control "compute_image_label_limit" {
  title       = "Compute images should not exceed label limit"
  description = "Check if the number of labels on Compute images do not exceed the limit."
  sql         = <<-EOQ
    with analysis as (
      select
        self_link,
        title,
        cardinality(array(select jsonb_object_keys(labels))) as num_label_keys,
        location,
        project
      from
        gcp_compute_image
      where
        source_project = project
    )
    select
      self_link as resource,
      case
        when num_label_keys > $1::integer then 'alarm'
        else 'ok'
      end as status,
      title || ' has ' || num_label_keys || ' label(s).' as reason,
      location,
      project
    from
      analysis
  EOQ
  param "label_limit" {
    default = var.label_limit
  }
}

control "compute_instance_label_limit" {
  title       = "Compute instances should not exceed label limit"
  description = "Check if the number of labels on Compute instances do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_compute_instance")
  param "label_limit" {
    default = var.label_limit
  }
}

control "compute_snapshot_label_limit" {
  title       = "Compute snapshots should not exceed label limit"
  description = "Check if the number of labels on Compute snapshots do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_compute_snapshot")
  param "label_limit" {
    default = var.label_limit
  }
}

control "dns_managed_zone_label_limit" {
  title       = "DNS managed zones should not exceed label limit"
  description = "Check if the number of labels on DNS managed zones do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_dns_managed_zone")
  param "label_limit" {
    default = var.label_limit
  }
}

control "sql_database_instance_label_limit" {
  title       = "SQL database instances should not exceed label limit"
  description = "Check if the number of labels on SQL database instances do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_sql_database_instance")
  param "label_limit" {
    default = var.label_limit
  }
}

control "storage_bucket_label_limit" {
  title       = "Storage buckets should not exceed label limit"
  description = "Check if the number of labels on Storage buckets do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_storage_bucket")
  param "label_limit" {
    default = var.label_limit
  }
}

control "bigtable_instance_label_limit" {
  title       = "Bigtable instances should not exceed label limit"
  description = "Check if the number of labels on Bigtable instances do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_bigtable_instance")
  param "label_limit" {
    default = var.label_limit
  }
}

control "dataproc_cluster_label_limit" {
  title       = "Dataproc clusters should not exceed label limit"
  description = "Check if the number of labels on Dataproc clusters do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_dataproc_cluster")
  param "label_limit" {
    default = var.label_limit
  }
}

control "pubsub_subscription_label_limit" {
  title       = "Pub/Sub subscriptions should not exceed label limit"
  description = "Check if the number of labels on Pub/Sub subscriptions do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_pubsub_subscription")
  param "label_limit" {
    default = var.label_limit
  }
}

control "pubsub_topic_label_limit" {
  title       = "Pub/Sub topics should not exceed label limit"
  description = "Check if the number of labels on Pub/Sub topics do not exceed the limit."
  sql         = replace(local.limit_sql, "__TABLE_NAME__", "gcp_pubsub_topic")
  param "label_limit" {
    default = var.label_limit
  }
}
