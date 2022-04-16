#sg
module "documentdb_sg" {
  source      = "../sg"
  name        = "${var.input.app_name}-documentdb-sg"
  vpc_id      = var.vpc_id
  port        = "27017"
  cidr_blocks = ["0.0.0.0/0"]
}

#password
resource "random_password" "password" {
  length  = 16
  special = false
}

#docdbクラスター
resource "aws_docdb_cluster" "default" {
  cluster_identifier      = "${var.input.app_name}-docdb-cluster" #クラスター識別子
  engine                  = "docdb"
  master_username         = var.input.docdb_username
  master_password         = random_password.password.result #あとで変える必要あり
  backup_retention_period = 1                               #バックアップ保持期間
  deletion_protection     = false                           #削除保護
  apply_immediately       = false                           #クラスターの変更を直ちに変更するかどうか
  port                    = 27017
  db_subnet_group_name    = aws_docdb_subnet_group.default.name
}

#docdbインスタンス
resource "aws_docdb_cluster_instance" "default" {
  count              = 2
  identifier         = "${var.input.app_name}-docdb-cluster-instance-${count.index}"
  cluster_identifier = aws_docdb_cluster.default.id
  instance_class     = "db.t4g.medium"
}

#docdbサブネット
resource "aws_docdb_subnet_group" "default" {
  name        = "${var.input.app_name}-docdb-subnet-group"
  description = "Allowed subnets for DB cluster instances"
  subnet_ids  = var.subnets
}
