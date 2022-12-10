resource "aws_s3_bucket" "orthbucket" {
  bucket = "${var.resource_prefix}-orthbucket"

  force_destroy = true # remaining object does not stop bucket from being deleted
  tags          = merge(var.resource_tags, { Name = "${var.resource_prefix}-orthbucket" })
}

resource "aws_s3_bucket_versioning" "orthbucket_versioning" {
  bucket = aws_s3_bucket.orthbucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "test" {
  bucket = aws_s3_bucket.orthbucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.custom_key_arn
      sse_algorithm     = "aws:kms"
    }
  }

}

resource "aws_s3_bucket_public_access_block" "orthbucketblockpublicaccess" {
  bucket                  = aws_s3_bucket.orthbucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.orthbucket] # explicit dependency to avoid errors on conflicting conditional operation
}

# Ref https://aws.amazon.com/blogs/security/how-to-restrict-amazon-s3-bucket-access-to-a-specific-iam-role/
# Each IAM entity (user or role) has a defined aws:userid variable. 

resource "aws_s3_bucket_policy" "orthbucketpolicy" {
  bucket = aws_s3_bucket.orthbucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.resource_prefix}-OrthBucketPolicy"
    Statement = [
      {
        Sid       = "DenyExceptRootAccnt"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.orthbucket.arn,
          "${aws_s3_bucket.orthbucket.arn}/*",
        ]
        Condition = {
          StringNotLike = {
            "aws:userId" = [
              "${data.aws_iam_role.instance_role.unique_id}:*", # instance role
              "${data.aws_caller_identity.current.account_id}", # root user
              "${data.aws_caller_identity.current.user_id}"     # deployment user
            ]
          }
        }
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.orthbucketblockpublicaccess]
}

## VPC endpoint is declared in the VPC module

resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "${var.resource_prefix}-orthweb-logging"
  force_destroy = true
  tags          = merge(var.resource_tags, { Name = "${var.resource_prefix}-logging" })
}
resource "aws_s3_bucket_versioning" "orthweb_logging_versioning" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging_sse" {
  bucket = aws_s3_bucket.logging_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.custom_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "orthwebloggingbucketblockpublicaccess" {
  bucket                  = aws_s3_bucket.logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  depends_on              = [aws_s3_bucket.logging_bucket] # explicit dependency to avoid errors on conflicting conditional operation
}


resource "aws_s3_bucket_policy" "orthweb_logging_policy" {
  bucket = aws_s3_bucket.logging_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${var.resource_prefix}-OrthwebLoggingBucketPolicy"
    Statement = [
      {
        Sid       = "DenyExceptRootAccnt"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.logging_bucket.arn,
          "${aws_s3_bucket.logging_bucket.arn}/*",
        ]
        Condition = {
          StringNotLike = {
            "aws:userId" = [
              "${data.aws_caller_identity.current.account_id}", # root user
              "${data.aws_caller_identity.current.user_id}"     # deployment user
            ]
          }
        }
      },
      {
        "Sid" : "AWSLogDeliveryWrite",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : "s3:PutObject",
        "Resource" : "${aws_s3_bucket.logging_bucket.arn}/*",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}",
            "s3:x-amz-acl" : "bucket-owner-full-control"
          },
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      },
      {
        "Sid" : "AWSLogDeliveryAclCheck",
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "delivery.logs.amazonaws.com"
        },
        "Action" : "s3:GetBucketAcl",
        "Resource" : "${aws_s3_bucket.logging_bucket.arn}",
        "Condition" : {
          "StringEquals" : {
            "aws:SourceAccount" : "${data.aws_caller_identity.current.account_id}"
          },
          "ArnLike" : {
            "aws:SourceArn" : "arn:aws:logs:${data.aws_region.this.name}:${data.aws_caller_identity.current.account_id}:*"
          }
        }
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.orthwebloggingbucketblockpublicaccess]
}

resource "aws_s3_bucket_logging" "example" {
  bucket = aws_s3_bucket.orthbucket.id

  target_bucket = aws_s3_bucket.logging_bucket.id
  target_prefix = "orthbucket_accesslog/"
}
