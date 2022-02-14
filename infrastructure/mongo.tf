resource "aws_security_group" "superb_db" {
  description = "Access for the superb db"
  name        = "${local.prefix}-superb-db"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_docdb_cluster_parameter_group" "superb_pg" {
  family      = "docdb4.0"
  name        = "superb-pg"
  description = "Superb docdb cluster parameter group"

  parameter {
    name  = "tls"
    value = "disabled"
  }
}

resource "aws_docdb_subnet_group" "superb_sg" {
  name       = "superb-sg"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  tags = local.common_tags
}

resource "aws_docdb_cluster" "superb_cluster" {
  cluster_identifier              = "${local.prefix}-superb-cluster"
  engine                          = "docdb"
  master_username                 = data.aws_ssm_parameter.superb_username.value
  master_password                 = data.aws_ssm_parameter.superb_password.value
  backup_retention_period         = 5
  db_subnet_group_name            = aws_docdb_subnet_group.superb_sg.name
  db_cluster_parameter_group_name = aws_docdb_cluster_parameter_group.superb_pg.name
  skip_final_snapshot             = true
  vpc_security_group_ids          = [aws_security_group.superb_db.id]

  tags = local.common_tags
}

resource "aws_docdb_cluster_instance" "superb_instance" {
  identifier         = data.aws_ssm_parameter.superb_dbname.value
  cluster_identifier = aws_docdb_cluster.superb_cluster.id
  instance_class     = "db.t3.medium"

  tags = local.common_tags
}

# create superb db-endpoint secret
resource "aws_ssm_parameter" "superb_endpoint" {
  name  = "/backend/mongo/dbendpoint"
  type  = "SecureString"
  value = "mongodb://${data.aws_ssm_parameter.superb_username.value}:${data.aws_ssm_parameter.superb_password.value}@${aws_docdb_cluster_instance.superb_instance.endpoint}:27017/${data.aws_ssm_parameter.superb_dbname.value}"
}

data "aws_ssm_parameter" "superb_dbname" {
  name = "/backend/mongo/dbname"
}

data "aws_ssm_parameter" "superb_username" {
  name = "/backend/mongo/username"
}

data "aws_ssm_parameter" "superb_password" {
  name = "/backend/mongo/password"
}