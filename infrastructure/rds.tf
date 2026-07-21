resource "aws_db_subnet_group" "grocery" {
  name       = "${var.app_name}-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids

  tags = { Name = "${var.app_name}-db-subnet-group" }
}

resource "aws_db_instance" "postgres" {
  identifier     = "${var.app_name}-db"
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.grocery.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Woche 5: "Die RDS-Instanz sollte privat sein" - no public IP, only
  # reachable from the EC2 security group via the rule in security_groups.tf.
  publicly_accessible = false

  backup_retention_period = 3
  skip_final_snapshot     = true # fine for a bootcamp project; set false + add final_snapshot_identifier for anything real

  tags = { Name = "${var.app_name}-db" }
}
