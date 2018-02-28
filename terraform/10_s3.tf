# S3 -*- Mode: HCL; -*-

variable "bucket-suffix" {
  type    = "string"
  default = "80enw6ogha" # tokyo
}

# # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html
resource "aws_s3_bucket" "default" {
  provider = "aws.tokyo"

  bucket = "${var.ProjectName}-${var.bucket-suffix}"
  acl    = "private"

  tags {
    Name      = "${var.ProjectName}"
    Project   = "${var.ProjectName}"
    Terraform = "true"
  }
}

# # https://www.terraform.io/docs/providers/aws/r/s3_bucket_policy.html
resource "aws_s3_bucket_policy" "default" {
  provider = "aws.tokyo"

  bucket = "${aws_s3_bucket.default.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ses.amazonaws.com"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.default.bucket}/*"
    } 
  ]
}
POLICY
}
