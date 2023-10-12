resource "aws_ssm_parameter" "db_host" {
    name        = "/${var.environment}/database/host"
    type        = "SecureString"
    value       = aws_db_instance.app_database.address
}

resource "aws_ssm_parameter" "db_password" {
    name        = "/${var.environment}/database/password"
    type        = "SecureString"
    value       = random_password.password.result
}

resource "aws_ssm_parameter" "db_user" {
    name        = "/${var.environment}/database/user"
    type        = "SecureString"
    value       = "root"
}

resource "aws_ssm_parameter" "db_name" {
    name        = "/${var.environment}/database/db_name"
    type        = "SecureString"
    value       = "petclinic"
}
