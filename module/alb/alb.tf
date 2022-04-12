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
    module.https_sg.security_group_id,
    module.grpc_sg.security_group_id,
  ]

  tags = {
    Name = "${var.input.app_name}-alb"
  }
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
    resources = ["${aws_s3_bucket.alb_log.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [local.alb_account_id]
    }
  }
}

#バケットが空でないと削除できないのでdestroyトリガーに削除実行
resource "null_resource" "default" {
  triggers = {
    bucket = aws_s3_bucket.alb_log.bucket
  }
  depends_on = [
    aws_s3_bucket.alb_log
  ]
  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rm s3://${self.triggers.bucket} --recursive"
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

module "grpc_sg" {
  source      = "../sg"
  name        = "${var.input.app_name}-alb-grpc-sg"
  vpc_id      = var.vpc_id
  port        = 6565
  cidr_blocks = ["0.0.0.0/0"]
}

#ALBリスナー
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_alb.default.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_alb.default.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    type = "fixed-response" #固定のHTTPレスポンス応答
    fixed_response {
      content_type = "text/plain"
      message_body = "これは「HTTPS」です"
      status_code  = "200"
    }
  }
}

# resource "aws_lb_listener" "grpc" {
#     load_balancer_arn = aws_alb.default.arn
#   port              = "6565"
#   protocol          = "HTTPS"
#   default_action {
#     type = "fixed-response" #固定のHTTPレスポンス応答
#   }
# }
