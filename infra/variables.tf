variable "environment" {
    default = "dev"
    type = string
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"  
    type = string
}

variable "az_count" {
    default = 2
    type = string  
}

variable "enable_single_NAT" {
    default = true
    type = bool
}

variable "repository_id" {
    default = ""
    type = string
}

variable "repository_branch" {
    default = "main"
    type = string
}

variable "instance_type" {
    default = "t3a.micro"
    type = string
}

variable "pem_key_name" {
    default = "ec2-key-pair"
    type = string
}

variable "alb_delete_protection" {
    default = false
    type = bool  
}

variable "domain_record" {
    default = ""
    type = string
}

variable "hosted_zone_id" {
    default = ""
    type = string
}

variable "database_storage" {
    default = 20
    type = number  
}

variable "database_engine_version" {
    default = "8.0.33"
    type = string
}

variable "enable_multi_az" {
    default = false
    type = bool
}

variable "database_instance_class" {
    default = "db.t3.small"
    type = string
}

variable "database_deletion_protection" {
    default = false
    type = bool
}

variable "database_public_accessibility" {
    default = false
    type = bool
}

variable "common_tags" {
    description = "Common tags to be applied to all resources"
    type        = map(string)
    default = {
        "Environment" = "dev"
        "ManagedBy"   = "Terraform"
        "CreatedBy"   = "Waqas"
    }
}
