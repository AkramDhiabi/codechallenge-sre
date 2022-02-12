resource "aws_docdb_cluster" "superb_cluster" {
  cluster_identifier      = "${local.prefix}-superb-cluster"
  engine                  = "docdb"
  master_username         = data.aws_ssm_parameter.superb-username.value
  master_password         = data.aws_ssm_parameter.superb-password.value
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  availability_zones      = ["${data.aws_region.current.name}a", "${data.aws_region.current.name}b"]
}

resource "aws_docdb_cluster_instance" "superb_instance" {
  identifier         = data.aws_ssm_parameter.superb-dbname.value
  cluster_identifier = aws_docdb_cluster.superb_cluster.id
  instance_class     = "db.t3.medium"
}

resource "aws_ssm_parameter" "superb_endpoint" {
  name  = "/backend/mongo/dbendpoint"
  type  = "SecureString"
  value = "mongodb://${data.aws_ssm_parameter.superb-username.value}:${data.aws_ssm_parameter.superb-password.value}@${aws_docdb_cluster_instance.superb_instance.endpoint}:27017/${data.aws_ssm_parameter.superb-dbname.value}"
}

data "aws_ssm_parameter" "superb-dbname" {
  name = "/backend/mongo/dbname"
}

data "aws_ssm_parameter" "superb-username" {
  name = "/backend/mongo/username"
}

data "aws_ssm_parameter" "superb-password" {
  name = "/backend/mongo/password"
}