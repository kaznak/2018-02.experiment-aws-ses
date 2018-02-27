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
