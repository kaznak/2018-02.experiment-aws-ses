# SES -*- Mode: HCL; -*-

variable "Admin_mail_addr" {
  type = "string"
  default = "admin@example.com"
}

variable "Working_mail_addr" {
  type = "string"
  default = "working@example.com"
}

# # https://www.terraform.io/docs/providers/aws/r/ses_active_receipt_rule_set.html
resource "aws_ses_active_receipt_rule_set" "default" {
  provider = "aws.oregon"

  depends_on = [ "aws_ses_receipt_rule_set.default" ]

  rule_set_name = "${var.ProjectName}"
}

# # https://www.terraform.io/docs/providers/aws/r/ses_receipt_rule_set.html
resource "aws_ses_receipt_rule_set" "default" {
  provider = "aws.oregon"
  rule_set_name = "${var.ProjectName}"
}

# # https://www.terraform.io/docs/providers/aws/r/ses_receipt_rule.html
resource "aws_ses_receipt_rule" "admin_mail" {
  provider = "aws.oregon"

  depends_on = [ "aws_s3_bucket_policy.default" ]

  name          = "admin_mail"
  rule_set_name = "${aws_ses_receipt_rule_set.default.rule_set_name}"
  recipients    = [ "${var.Admin_mail_addr}" ]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name = "${aws_s3_bucket.default.bucket}"
    object_key_prefix = "${var.Admin_mail_addr}"
    position    = 1
  }
}

# # https://www.terraform.io/docs/providers/aws/r/ses_receipt_rule.html
resource "aws_ses_receipt_rule" "working_mail" {
  provider = "aws.oregon"

  depends_on = [ "aws_s3_bucket_policy.default" ]

  name          = "working_mail"
  rule_set_name = "${aws_ses_receipt_rule_set.default.rule_set_name}"
  recipients    = [ "${var.Working_mail_addr}" ]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name = "${aws_s3_bucket.default.bucket}"
    object_key_prefix = "${var.Working_mail_addr}"
    position    = 1
  }
}
