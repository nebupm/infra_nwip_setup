#########################################################
# This module enables VPC Flow Logs to **CloudWatch** (7 days retention) 
# and **S3** (with lifecycle: Standard -> Glacier -> Expire).
#########################################################
# Variables
#########################################################
variable "traffic_type" {
  type    = string
  default = "ALL"
}

variable "vpcflowlog_enabled" {
  type    = bool
  default = true
}

#########################################################
# IAM Role for VPC Flow Logs
#########################################################
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "vpcFlowLogsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  role = aws_iam_role.vpc_flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.s3_bucket_vpc_flow_logs[0].arn,
          "${aws_s3_bucket.s3_bucket_vpc_flow_logs[0].arn}/*"
        ]
      }
    ]
  })
}

#########################################################
# CloudWatch Log Group
#########################################################
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  count             = var.vpcflowlog_enabled ? 1 : 0
  name              = "vpc-flowlog-cloudwatch-group"
  retention_in_days = 7
}

resource "aws_flow_log" "to_cloudwatch" {
  count                = var.vpcflowlog_enabled ? 1 : 0
  vpc_id               = aws_vpc.this_vpc.id
  traffic_type         = var.traffic_type
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs[0].arn
  log_destination_type = "cloud-watch-logs"
  iam_role_arn         = aws_iam_role.vpc_flow_logs_role.arn
}


#########################################################
# S3 Bucket for Storing Flow Logs.
#########################################################
resource "aws_s3_bucket" "s3_bucket_vpc_flow_logs" {
  count         = var.vpcflowlog_enabled ? 1 : 0
  bucket        = "vpc-flow-logs-${aws_vpc.this_vpc.id}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "block" {
  count  = var.vpcflowlog_enabled ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket_vpc_flow_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = var.vpcflowlog_enabled ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket_vpc_flow_logs[0].id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_server_side_encryption_configuration" "sse" {
  count  = var.vpcflowlog_enabled ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket_vpc_flow_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  count  = var.vpcflowlog_enabled ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket_vpc_flow_logs[0].id

  rule {
    id     = "glacier-transition-expiration"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }
}

resource "aws_flow_log" "to_s3" {
  count = var.vpcflowlog_enabled ? 1 : 0

  vpc_id               = aws_vpc.this_vpc.id
  traffic_type         = var.traffic_type
  log_destination      = aws_s3_bucket.s3_bucket_vpc_flow_logs[0].arn
  log_destination_type = "s3"

  destination_options {
    file_format                = "parquet"
    hive_compatible_partitions = true
    per_hour_partition         = true
  }
}
