# Generate a random password
resource "random_password" "db_password" {
  length  = 16
  special = true
}

# Store password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name = "${var.project}-rds-postgres-password"
}

resource "aws_secretsmanager_secret_version" "db_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = jsonencode({
    username = "postgresadmin"
    password = random_password.db_password.result
  })
}

# Retrieve and decode the secret
locals {
  db_secret = jsondecode(aws_secretsmanager_secret_version.db_secret_version.secret_string)
}


# Create security group to allow only EKS node access
resource "aws_security_group" "postgres_sg" {
  name        = "postgres-sg"
  description = "Allow PostgreSQL access from EKS nodes"
  vpc_id      = var.aws_vpc_id

  ingress {
    from_port                = 5432
    to_port                  = 5432
    protocol                 = "tcp"
    security_groups          = [var.eks_node_group_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create DB subnet group
resource "aws_db_subnet_group" "default" {
  name       = "${var.project}-subnet-group"
  subnet_ids = [var.private_subnet_a, var.private_subnet_b]

  tags = {
    Name = "${var.project} subnet group"
  }
}

# Create the PostgreSQL RDS instance
resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "17.4"
  instance_class         = "db.t3.micro"   # Free tier eligible
  identifier             = "${var.project}-postgres-db"
  username               = local.db_secret.username
  password               = local.db_secret.password
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]

  backup_retention_period = 7
  skip_final_snapshot     = true
  publicly_accessible     = false
  multi_az                = false
  storage_type            = "gp2"
}
