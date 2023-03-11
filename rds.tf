// Create db subnet group
resource "aws_db_subnet_group" "subnet_group" {
  name       = "subnet_group"
  subnet_ids = ["${aws_subnet.web_public_subnet1.id}", "${aws_subnet.web_public_subnet2.id}"]

  tags = var.project_name
}

// Create parameter group
resource "aws_db_parameter_group" "custom_pg" {
  name   = "rdsmysql"
  family = "mysql5.7"

  parameter {
    name  = "autocommit"
    value = "1"
  }
}

// Create RDS db instance
resource "aws_db_instance" "rds" {
  allocated_storage      = 10
  name                   = var.db_name
  engine                 = var.configuration.database.engine
  engine_version         = var.configuration.database.engine_version
  instance_class         = var.configuration.database.instance_class
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.custom_pg.name
  skip_final_snapshot    = var.configuration.database.skip_final_snapshot

  tags = var.project_name
}