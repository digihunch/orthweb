data "aws_caller_identity" "current" {
  # no arguments
}

resource "aws_kms_key" "s3key" {
  description             = "This key is used to encrypt bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "orthbucket" {
  bucket = "orthbucket${random_id.randsuffix.hex}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}
# Ref https://aws.amazon.com/blogs/security/how-to-restrict-amazon-s3-bucket-access-to-a-specific-iam-role/
# Each IAM entity (user or role) has a defined aws:userid variable. 

resource "aws_s3_bucket_policy" "orthbucketpolicy" {
  bucket = aws_s3_bucket.orthbucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id = "OrthBucketPolicy"
    Statement = [
      {
        Sid = "DenyExceptRootAccnt"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.orthbucket.arn,
          "${aws_s3_bucket.orthbucket.arn}/*",
        ]
        Condition = {
          StringNotLike = {
            "aws:userId" = [
              "${aws_iam_role.inst_role.unique_id}:*",               # instance role
              "${data.aws_caller_identity.current.account_id}",      # root user
              "${data.aws_caller_identity.current.user_id}"          # deployment user
            ]
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_public_access_block" "orthbucketblockpublicaccess" {
  bucket = aws_s3_bucket.orthbucket.id
  block_public_acls = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}
