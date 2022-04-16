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
  ssl_policy        = "ELBSecurityPolicy-2015-05"
  certificate_arn   = var.acm_certificate_arn
  default_action {
    target_group_arn = aws_alb_target_group.alb.arn
    type             = "forward"
  }
}

#ターゲットグループ
resource "aws_alb_target_group" "alb" {
  name        = "${var.input.app_name}-tg"
  target_type = "ip"
  port        = 6565
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    interval            = 30
    path                = "/"
    port                = 6565
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
    matcher             = 200
  }
  depends_on = [
    aws_alb.default
  ]
}

resource "aws_lb_listener_rule" "default" {
  # ルールを追加するリスナー
  listener_arn = aws_lb_listener.https.arn

  # 受け取ったトラフィックをターゲットグループへ受け渡す
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.id
  }

  # ターゲットグループへ受け渡すトラフィックの条件
  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}
