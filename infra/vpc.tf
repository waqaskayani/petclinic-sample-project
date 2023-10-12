module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "${var.environment}-vpc"
    cidr = var.vpc_cidr

    azs             = local.azs
    private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k)]
    public_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k+100)]

    enable_nat_gateway = true
    single_nat_gateway = var.enable_single_NAT

    private_subnet_tags_per_az  = local.private_subnet_az_tags
    public_subnet_tags_per_az   = local.public_subnet_az_tags
    default_route_table_tags    = local.default_rt_az_tags
    private_route_table_tags    = local.private_rt_az_tags
    public_route_table_tags     = local.public_rt_az_tags
    nat_gateway_tags            = local.nat_tags

    tags = merge(
        { 
            "Name" = "${var.environment}-vpc" 
        },
        var.common_tags
    )
}

resource "aws_security_group" "ec2_sg" {
    name        = "ec2-sg-${var.environment}"
    description = "Allow inbound traffic to EC2 instances from ALB."
    vpc_id      = module.vpc.vpc_id

    ingress {
        description      = "Application traffic from ALB"
        from_port        = 9966
        to_port          = 9966
        protocol         = "tcp"
        security_groups  = [ aws_security_group.alb_sg.id ]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge(
        { 
            "Name" = "ec2-sg-${var.environment}"
        },
        var.common_tags
    )
}

resource "aws_security_group" "instance_connect_sg" {
    name        = "instance-connect-sg-${var.environment}"
    description = "Allow inbound traffic to from Instance Connect endpoints."
    vpc_id      = module.vpc.vpc_id

    ingress {
        description      = "SSH from Instance connect endpoint IPs."
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["3.16.146.0/29"]
    }

    ingress {
        description      = "SSH from inside VPC."
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [ var.vpc_cidr ]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge(
        { 
            "Name" = "instance-connect-sg-${var.environment}"
        },
        var.common_tags
    )
}

resource "aws_security_group" "alb_sg" {
    name        = "alb-sg-${var.environment}"
    description = "Allow inbound traffic to ALB instances from Internet."
    vpc_id      = module.vpc.vpc_id

    ingress {
        description      = "Https from public"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        description      = "Http from public"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge(
        { 
            "Name" = "alb-sg-${var.environment}"
        },
        var.common_tags
    )
}


resource "aws_security_group" "codebuild_sg" {
    name        = "codebuild-sg-${var.environment}"
    description = "Allow traffic for CodeBuild to access resources."
    vpc_id      = module.vpc.vpc_id

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge(
        { 
            "Name" = "codebuild-sg-${var.environment}"
        },
        var.common_tags
    )
}

resource "aws_security_group" "database_sg" {
    name        = "db-sg-${var.environment}"
    description = "Allow traffic for Database."
    vpc_id      = module.vpc.vpc_id

    ingress {
        description      = "MySQL from EC2"
        from_port        = 3306
        to_port          = 3306
        protocol         = "tcp"
        security_groups  = [ aws_security_group.ec2_sg.id ]
    }

    ingress {
        description      = "MySQL from CodeBuild"
        from_port        = 3306
        to_port          = 3306
        protocol         = "tcp"
        security_groups  = [ aws_security_group.codebuild_sg.id ]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = "-1"
        cidr_blocks      = ["0.0.0.0/0"]
        ipv6_cidr_blocks = ["::/0"]
    }

    tags = merge(
        { 
            "Name" = "db-sg-${var.environment}"
        },
        var.common_tags
    )
}
