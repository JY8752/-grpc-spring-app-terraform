#alb
resource "aws_alb" "default" {
  name               = "${var.input.app_name}-alb"
  load_balancer_type = "application"
  internal           = false
  idle_timeout       = 60
  # enable_deletion_protection = true
  subnets = var.subnets
  access_logs {
    bucket  = aws_s3_bucket.alb_log.id
    enabled = true
  }
  security_groups = [
    module.http_sg.security_group_id,
    module.https_sg.security_group_id
  ]
}

#albログバケット
resource "aws_s3_bucket" "alb_log" {
  bucket = "${var.input.app_name}-alb-log-bucket"
}

resource "aws_s3_bucket_lifecycle_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  rule {
    id     = "alb access log"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 180
    }
  }
}

resource "aws_s3_bucket_policy" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id
  policy = data.aws_iam_policy_document.alb_log.json
}

data "aws_iam_policy_document" "alb_log" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.alb_log.id}/*"]
    principals {
      type        = "AWS"
      identifiers = ["582318560864"]
    }
  }
}

#sg
module "http_sg" {
  source      = "../sg"
  name        = "${var.input.app_name}-alb-http-sg"
  vpc_id      = var.vpc_id
  port        = 80
  cidr_blocks = ["0.0.0.0/0"]
}

module "https_sg" {
  source      = "../sg"
  name        = "${var.input.app_name}-alb-https-sg"
  vpc_id      = var.vpc_id
  port        = 443
  cidr_blocks = ["0.0.0.0/0"]
}
