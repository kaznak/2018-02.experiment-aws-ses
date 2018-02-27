# lambda -*- Mode: HCL; -*-

# Variables
# # https://www.terraform.io/docs/configuration/variables.html
variable "strip_attached_function" {
  default = "ses_s3-strip_attached-s3"
}

# # https://www.terraform.io/docs/configuration/locals.html
locals {
  strip_attached_function_file = "${path.module}/../pkg/${var.strip_attached_function}.zip"
}

# Function
# # https://www.terraform.io/docs/providers/aws/r/lambda_function.html
resource "aws_lambda_function" "strip_attached" {
  depends_on = ["aws_iam_role.lambda_s3"]
  provider   = "aws.tokyo"

  function_name = "${var.strip_attached_function}"
  role          = "${aws_iam_role.lambda_s3.arn}"

  runtime = "python3.6"
  handler = "split-attach.lambda_handler"

  filename         = "${local.strip_attached_function_file}"
  source_code_hash = "${base64sha256(file("${local.strip_attached_function_file}"))}"
}

# Role
# # https://www.terraform.io/docs/providers/aws/r/iam_role.html
resource "aws_iam_role" "lambda_s3" {
  depends_on = ["aws_s3_bucket.default"]
  provider   = "aws.tokyo"
  name       = "lambda_${var.strip_attached_function}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# # https://www.terraform.io/docs/providers/aws/r/iam_role_policy.html
resource "aws_iam_role_policy" "lambda_s3" {
  provider   = "aws.tokyo"
  name = "lambda_s3"
  role = "${aws_iam_role.lambda_s3.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": "arn:aws:s3:::${aws_s3_bucket.default.id}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
EOF
}

# Trigger
# # https://www.terraform.io/docs/providers/aws/r/lambda_permission.html
resource "aws_lambda_permission" "allow_bucket" {
  provider = "aws.tokyo"

  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.strip_attached.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.default.arn}"
}

# # https://www.terraform.io/docs/providers/aws/r/s3_bucket_notification.html
resource "aws_s3_bucket_notification" "bucket_notification" {
  provider = "aws.tokyo"

  bucket = "${aws_s3_bucket.default.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.strip_attached.arn}"
    events              = ["s3:ObjectCreated:Put"]
    filter_prefix       = "working_mail/"
  }
}
