resource "aws_db_instance" "app_database" {
    identifier           = "rds-mysql-${var.environment}"
    allocated_storage    = var.database_storage

    engine                     = "mysql"
    auto_minor_version_upgrade = false
    engine_version             = var.database_engine_version
    db_name                    = aws_ssm_parameter.db_name.value

    instance_class         = var.database_instance_class
    db_subnet_group_name   = aws_db_subnet_group.app_subnet_group.name
    publicly_accessible    = var.database_public_accessibility
    vpc_security_group_ids = [ aws_security_group.database_sg.id ]

    username             = aws_ssm_parameter.db_user.value
    password             = random_password.password.result
    multi_az             = var.enable_multi_az
    skip_final_snapshot  = true
    apply_immediately    = true
    storage_encrypted    = true

    deletion_protection  = var.database_deletion_protection

    tags = merge(
            { 
                "Name" = "rds-mysql-${var.environment}"
            },
            var.common_tags
    )
}

resource "aws_db_subnet_group" "app_subnet_group" {
    name       = "rds-mysql-${var.environment}-subnet-group"
    subnet_ids = module.vpc.private_subnets

    tags = merge(
            { 
                "Name" = "rds-mysql-${var.environment}-subnet-group"
            },
            var.common_tags
    )
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
