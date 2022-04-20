#ECSクラスタの定義
resource "aws_ecs_cluster" "default" {
  name = "${var.input.app_name}-ecs-cluster"
}

data "template_file" "default" {
  template = file("./module/ecs/container_definitions.json")
  vars = {
    APP_NAME = var.input.app_name
  }
}

#タスク定義
resource "aws_ecs_task_definition" "default" {
  family                   = var.input.app_name #タスク定義名のプレフィックス
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = data.template_file.default.rendered
  execution_role_arn       = module.ecs_task_execution_role.iam_role_arn
}

#ECSタスク実行IAMロールの定義
module "ecs_task_execution_role" {
  source     = "../iam"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}

#AmazonECSTaskExecutionRolePolicyの参照
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#ECSタスク実行IAMロールのポリシードキュメントの定義
data "aws_iam_policy_document" "ecs_task_execution" {
  source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy.policy] #既存ポリシーの継承 
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

# #ECS Execロールの作成
# module "ecs_exec_role" {
#   source     = "../iam"
#   name       = "ecs-task-execution"
#   identifier = "ecs-tasks.amazonaws.com"
#   policy     = data.aws_iam_policy_document.ecs_task_execution.json
# }

# #AmazonECSTaskExecutionRolePolicyの参照
# data "aws_iam_policy" "ecs_task_execution_role_policy" {
#   arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

# #ECSタスク実行IAMロールのポリシードキュメントの定義
# data "aws_iam_policy_document" "ecs_task_execution" {
#   source_policy_documents = [data.aws_iam_policy.ecs_task_execution_role_policy.policy] #既存ポリシーの継承 
#   statement {
#     effect    = "Allow"
#     actions   = ["ssm:GetParameters", "kms:Decrypt"]
#     resources = ["*"]
#   }
# }

#サービス定義
resource "aws_ecs_service" "default" {
  name                              = "${var.input.app_name}-ecs-service"
  cluster                           = aws_ecs_cluster.default.arn
  task_definition                   = aws_ecs_task_definition.default.arn
  desired_count                     = 2 #維持するタスク数
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  health_check_grace_period_seconds = 60 #起動に時間がかかるとヘルスチェック通らなくなるので0以上に
  network_configuration {
    assign_public_ip = false
    security_groups  = [module.ecs_sg.security_group_id]
    subnets          = var.subnets
  }
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.input.app_name
    container_port   = 80
  }
  lifecycle {
    ignore_changes = [task_definition] #リソースの初回作成時を除き変更を無視する
  }
}

#CloudWatch Logsの定義
resource "aws_cloudwatch_log_group" "for_ecs" {
  name              = "/ecs/${var.input.app_name}"
  retention_in_days = 180 #ログ保有期間
}

#sg
module "ecs_sg" {
  source      = "../sg"
  name        = "${var.input.app_name}-ecs-sg"
  vpc_id      = var.vpc_id
  port        = 80
  cidr_blocks = [var.vpc_cidr_block]
}

#ECR
resource "aws_ecr_repository" "default" {
  name                 = "${var.input.app_name}-ecr-repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}
